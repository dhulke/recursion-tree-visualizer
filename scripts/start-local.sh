#!/bin/bash

# Default ports - use env vars first, then command line args, then defaults
LAMBDA_PORT=${LAMBDA_PORT:-${1:-8080}}
WEB_PORT=${WEB_PORT:-${2:-3003}}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables for tracking
CONTAINER_ID=""
NEXTJS_PID=""

# Show usage if help requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $0 [LAMBDA_PORT] [WEB_PORT]"
    echo ""
    echo "Arguments:"
    echo "  LAMBDA_PORT    Port for Lambda RIE (default: 8080)"
    echo "  WEB_PORT       Port for Next.js dev server (default: 3003)"
    echo ""
    echo "Examples:"
    echo "  $0                           # Use default ports (8080, 3003)"
    echo "  $0 8081                      # Lambda on 8081, Web on 3003"
    echo "  $0 8081 3004                 # Lambda on 8081, Web on 3004"
    echo "  yarn local -- 8081 3004      # Via yarn with arguments"
    echo "  LAMBDA_PORT=8081 yarn local  # Via environment variables"
    exit 0
fi

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}Shutting down services...${NC}"
    
    # Kill Next.js process if running
    if [ ! -z "$NEXTJS_PID" ]; then
        echo -e "${YELLOW}Stopping Next.js (PID: $NEXTJS_PID)...${NC}"
        kill $NEXTJS_PID 2>/dev/null
        wait $NEXTJS_PID 2>/dev/null
    fi
    
    # Stop Docker container if we have the ID
    if [ ! -z "$CONTAINER_ID" ]; then
        echo -e "${YELLOW}Stopping Docker container ($CONTAINER_ID)...${NC}"
        docker stop $CONTAINER_ID 2>/dev/null
    fi
    
    echo -e "${GREEN}All services stopped!${NC}"
    exit 0
}

# Set trap to catch Ctrl+C
trap cleanup SIGINT SIGTERM

echo -e "${GREEN}Starting Recursion Tree Visualizer locally...${NC}"

# Start Lambda container with custom port
echo -e "${YELLOW}Starting Lambda container on port $LAMBDA_PORT...${NC}"
cd ../lambda
PORT=$LAMBDA_PORT npm run locald || {
    echo -e "${RED}Failed to start Lambda container${NC}"
    exit 1
}

# Get the container ID of the most recently started rtv container
CONTAINER_ID=$(docker ps --filter "ancestor=rtv" --format "{{.ID}}" | head -1)

if [ -z "$CONTAINER_ID" ]; then
    echo -e "${RED}Could not find running Lambda container${NC}"
    exit 1
fi

echo -e "${GREEN}Lambda container started with ID: $CONTAINER_ID${NC}"

# Wait for Lambda to be ready
echo -e "${YELLOW}Waiting for Lambda to be ready...${NC}"

# Start Next.js in background
echo -e "${YELLOW}Starting Next.js development server on port $WEB_PORT...${NC}"
cd ../web
LAMBDA_PORT=$LAMBDA_PORT NEXT_PUBLIC_USE_LOCAL_API=true yarn dev --port $WEB_PORT &
NEXTJS_PID=$!

echo -e "${GREEN}Services started!${NC}"
echo -e "${GREEN}Lambda RIE: http://localhost:$LAMBDA_PORT${NC}"
echo -e "${GREEN}Next.js App: http://localhost:$WEB_PORT${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop all services${NC}"

# Wait for Next.js process to finish (or be killed)
wait $NEXTJS_PID

# If we reach here, Next.js exited naturally, so cleanup
cleanup
