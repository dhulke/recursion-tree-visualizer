const LAMBDA_PORT = process.env.LAMBDA_PORT ?? '8080'
const RIE_INVOKE_URL = process.env.RIE_INVOKE_URL ?? 
  `http://localhost:${LAMBDA_PORT}/2015-03-31/functions/function/invocations`

type ApiGatewayProxyResult = {
  statusCode: number
  body: string
  headers?: Record<string, string>
}

export async function POST(request: Request): Promise<Response> {
  const requestJson = await request.json()
  const apiGatewayEvent = { body: JSON.stringify(requestJson) }

  const upstreamResponse = await fetch(RIE_INVOKE_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(apiGatewayEvent),
  })

  const upstreamJson = await upstreamResponse.json() as ApiGatewayProxyResult

  return new Response(upstreamJson.body, {
    status: upstreamJson.statusCode,
    headers: upstreamJson.headers,
  })
}


