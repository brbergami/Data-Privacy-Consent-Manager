sub init()
    m.top.functionName = "makeRequest"
end sub

function makeRequest(api as String, data as Object) as Void
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
    validateResponse(response)
end function

function validateResponse(response) as Void
    responseData = response.getToString()
    if responseData <> invalid and responseData <> ""
        parsedData = parseJson(responseData)
        m.top.response = parsedData
    end if
end function
