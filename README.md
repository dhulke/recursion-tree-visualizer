<div align="center">
  <img src="./assets/logo.svg" height="100"/>
</div>

<h1 align="center">Recursion Tree Visualizer</h1>

<p align="center">🥇 Winner project of the <a href="https://www.algoexpert.io/swe-project-contests/2020-summer">AlgoExpert SWE Project Contest</a> 🥇</p>

## Overview

Stop drawing recursion trees by hand. Watch the [demo video](https://youtu.be/1f-KeeN8AHs) or check out the [live project](https://recursion.now.sh).

### Folders structure

- `web`: react user interface.
- `lambda`: serverless lambda function to execute user-defined code remotely.

## Local development

### Prerequisites

- [Node.js](https://nodejs.org/) (20.x for web, 14.x for lambda)
- [Docker](https://www.docker.com/) for running the Lambda function
- [Yarn](https://yarnpkg.com/) (recommended) or npm

### Quick Start (Recommended)

The easiest way to run the full project locally is using the provided script:

```bash
# Clone the repository
$ git clone <repository-url>
$ cd recursion-tree-visualizer

# Install web dependencies
$ cd web && yarn install && cd ..

# Install lambda dependencies  
$ cd lambda && npm install && cd ..

# Start both services (Lambda + Next.js)
$ cd web && yarn local
```

This will:
- Build and run the Lambda function on port 8080 using Docker
- Start the Next.js development server on port 3003
- Automatically configure the web app to use the local Lambda
- Clean up Docker containers when you press Ctrl+C

**Access the app at:** http://localhost:3003

### Custom Ports

You can specify custom ports for both services:

```bash
# Lambda on 8081, Web on 3004
$ cd web && yarn local -- 8081 3004

# Or using environment variables
$ cd web && LAMBDA_PORT=8081 WEB_PORT=3004 yarn local
```

### Manual Setup (Advanced)

If you prefer to run services separately:

#### 1. Lambda Function

```bash
$ cd lambda

# Install dependencies
$ npm install

# Build and run with Docker (detached)
$ npm run locald

# Or with custom port
$ PORT=8081 npm run locald

# Test the function
$ curl -XPOST "http://localhost:8080/2015-03-31/functions/function/invocations" \
  -d '{"body":"{\"lang\":\"javascript\",\"functionData\":{\"body\":\"function fibonacci(n) { return n <= 1 ? n : fibonacci(n-1) + fibonacci(n-2); }\",\"params\":[{\"name\":\"n\",\"initialValue\":\"5\"}]},\"options\":{\"memoize\":false}}"}'
```

#### 2. Web Application

```bash
$ cd web

# Install dependencies
$ yarn install

# For local development (uses local Lambda)
$ NEXT_PUBLIC_USE_LOCAL_API=true yarn dev

# For production mode (uses AWS API)
$ yarn dev
```

### Environment Configuration

The web application can run in two modes:

#### Local Development Mode
- Set `NEXT_PUBLIC_USE_LOCAL_API=true`
- Uses local Lambda function via `/api/run` proxy
- Avoids CORS issues

#### Production Mode (Default)
- Uses AWS Lambda endpoint: `https://c1y17h6s33.execute-api.us-east-1.amazonaws.com/production/run`
- No local setup required

### Environment Variables

Create `web/.env.local` for custom configuration:

```env
# Use local Lambda instead of AWS
NEXT_PUBLIC_USE_LOCAL_API=true

# Local Lambda port (for API proxy)
LAMBDA_PORT=8080
```

### Troubleshooting

#### Docker Issues
```bash
# Stop any running containers
$ docker stop $(docker ps -q --filter ancestor=rtv)

# Remove old images
$ docker rmi rtv
```

#### Port Conflicts
```bash
# Check what's using a port
$ lsof -i :8080

# Use different ports
$ cd web && yarn local -- 8081 3004
```

#### Clean Restart
```bash
# Stop all services, clean Docker, and restart
$ docker stop $(docker ps -q --filter ancestor=rtv)
$ cd web && yarn local
```

## Deploy to production

### Lambda

In `terraform` folder:

- create terraform.tfvars file
- run `terraform init`
- run `terraform validate`
- run `terraform plan`
- run `terraform apply`

### Web

Ships `web` on Vercel, setup environment variables.

## Acknowledgements

Thanks to [Drawing Presentable Trees](https://llimllib.github.io/pymag-trees/#foot5) and [Improving Walker's Algorithm to Run in Linear Time](http://dirk.jivas.de/papers/buchheim02improving.pdf) articles I implemented Reingold-Tilford's algorithm to position each node of the tree on a 2D plane in an aesthetically pleasing way.

## Compatibility

For a better experience, I recommend using a chromium-based browser like Chrome or Edge.

## Contact me

- [Twitter](https://twitter.com/brnpapa)

