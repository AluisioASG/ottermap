type HttpMethod = "GET" | "PUT" | "POST"

interface XhrCallback {
  (this: XMLHttpRequest, event: ProgressEvent): void
}


let DBAPI_ROOT: string


export function setRoot(url: string) {
  DBAPI_ROOT = url
}

export default function request(
  method: HttpMethod,
  endpoint: string,
  data: any,
  successCallback: XhrCallback,
  errorCallback: XhrCallback,
) {
  const xhr = new XMLHttpRequest()
  xhr.open(method, `${DBAPI_ROOT}/${endpoint}`, true)
  xhr.addEventListener("load", event => {
    if (xhr.status <= 200 || xhr.status < 300) {
      successCallback.call(xhr, event)
    } else {
      errorCallback.call(xhr, event)
    }
  })
  xhr.addEventListener("error", errorCallback)
  xhr.addEventListener("abort", errorCallback)
  if (method === "GET") {
    xhr.setRequestHeader("Accept", "application/json")
  } else if (method === "POST" || method === "PUT") {
    xhr.setRequestHeader("Content-Type", "application/json")
    data = JSON.stringify(data)
  }
  xhr.send(data)
}
