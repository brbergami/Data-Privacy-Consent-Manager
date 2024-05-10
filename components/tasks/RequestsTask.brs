sub init()
    m.top.functionName = "makeRequest"
end sub

sub makeRequest()
    request = createObject("roUrlTransfer")
    ' port = createObject("roMessagePort")
    ' request.setMessagePort(port)
    if left(m.top.request.api, 5) = "https"
        request.setCertificatesFile("common:/certs/ca-bundle.crt")
    end if
    requestType = ucase(m.top.request.requesttype)
    request.setRequest(requestType)
    if requestType = "GET"
        queryParams = "?"
        params = m.top.request.payload.keys()
        for each param in params:
            queryParams += param + "=" + m.top.request.payload[param] + "&"
        end for
        queryParams = left(queryParams, len(queryParams) - 1)
        request.setUrl(m.top.request.api + queryParams)
        response = request.getToString()
    else if requestType = "POST"
        request.addHeader("Content-Type", "application/json")
        payload = formatJson(m.top.request.params)
        request.setUrl(m.top.request.api)
        response = request.asyncPostFromString(payload)
        ' message = wait(5000, port)
    end if
    m.top.response = parseJson(response)
    m.top.request = {}
end sub
