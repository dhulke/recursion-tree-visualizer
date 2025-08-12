import { Either, error, success } from './lib/either'
import { safeParse, safeStringify } from './static/safe-json'
import { FunctionData, Language, TreeViewerData } from './types'

type RequestBody = {
  lang: Language
  functionData: FunctionData
  options: {
    memoize: boolean
  }
}

// Configuration for API endpoint
const USE_LOCAL_API = process.env.NEXT_PUBLIC_USE_LOCAL_API === 'true'
const PRODUCTION_API_URL = 'https://c1y17h6s33.execute-api.us-east-1.amazonaws.com/production/run'
const LOCAL_API_URL = '/api/run'

const API_ENDPOINT = USE_LOCAL_API ? LOCAL_API_URL : PRODUCTION_API_URL

export const runFunction = async (
  requestBody: RequestBody
): Promise<Either<string, TreeViewerData>> => {
  try {
    const response = await fetch(API_ENDPOINT, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      mode: 'cors',
      body: safeStringify(requestBody),
    })
    
    const responseBody = await response.text()

    if (response.ok) {
      const treeViewerData = safeParse(responseBody) as TreeViewerData
      return success(treeViewerData)
    } else {
      const err = safeParse(responseBody) as { reason: string }
      return error(err.reason || 'Internal server error')
    }
  } catch (e) {
    console.error(e)
    return error('Unexpected error')
  }
}
