sub init()
    m.top.functionName = "makeRequest"
end sub

sub makeRequest()
    request = createObject("roUrlTransfer")
    port = createObject("roMessagePort")
    request.setMessagePort(port)
    if left(m.top.request.api, 5) = "https"
        request.setCertificatesFile("common:/certs/ca-bundle.crt")
        request.initClientCertificates()
        ' request.enableEncodings(true) ' Check this required '
    end if
    request.setRequest(m.top.request.requesttype)
    if m.top.request.requesttype = "get"
        queryParams = "?"
        params = m.top.request.payload.keys()
        for each param in params:
            queryParams += param + "=" + m.top.request.payload[param] + "&"
        end for
        queryParams = right(queryParams, 1)
        request.setUrl(m.top.request.api + queryParams)
        response = request.getToString()
        ' response = request.asyncGetToString() ' TBD '
    else if m.top.request.requesttype = "post"
        request.addHeader("Content-Type", "application/json")
        payload = formatJson(m.top.request.params)
        request.setUrl(m.top.request.api)
        request.asyncPostFromString(payload)
    end if
    message = wait(5000, request)
    m.top.request = {}
    validateResponse(message)
end sub

sub validateResponse(response as Object)
    responseBody = response.getString()
    m.top.response = parseJson(responseBody)
end sub
