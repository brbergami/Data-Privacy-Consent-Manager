sub init()
    m.top.functionName = "makeRequest"
end sub

function makePostRequest(api as String, data as Object) as Void
    postRequest = createObject("roUrlTransfer")
    postRequest.setCertificatesFile("common:/certs/ca-bundle.crt")
    postRequest.initClientCertificates()
    postRequest.setUrl(api)
    postRequest.setRequest("POST")
    postRequest.setMessagePort(createObject("roMessagePort"))
    postRequest.enableEncodings(true)
    postRequest.addHeader("Content-Type", "application/json")
    if type(data) = "roAssociativeArray" or type(data) = "roArray"
        data = formatJson(data)
    end if
    postRequest.setBody(data)
    postRequest.asyncPostFromString()
    response = wait(2000, postRequest.getMessagePort())
    if type(response) = "roUrlEvent"
        validateResponse(response)
    end if
end function

function validateResponse(response as Object) as Void
    if response.getResponseCode() = 200
        responseBody = response.getToString()
        m.top.response = parseJson(responseBody)
    end if
end function
