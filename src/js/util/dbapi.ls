DBAPI_ROOT <- define <[dbapi-root]>


(method, endpoint, data, successCallback, errorCallback) !->
  xhr = new XMLHttpRequest
    ..open method, "#{DBAPI_ROOT}/#{endpoint}", true
    ..addEventListener \load (event) !->
      | 200 <= @status < 300 => successCallback.call this, event
      | otherwise            => errorCallback.call this, event
    ..addEventListener \error errorCallback
    ..addEventListener \abort errorCallback
  if method is \GET
    xhr.setRequestHeader \Accept 'application/json'
  else if method in <[POST PUT]>
    xhr.setRequestHeader \Content-Type 'application/json'
    data = JSON.stringify data
  xhr.send data
