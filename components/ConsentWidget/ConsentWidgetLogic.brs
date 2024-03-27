' Get ZIP Code
sub getZIPCode()
    ' channelStore = CreateObject("roSGNode", "ChannelStore")
    ' ' Retrieve the user's region data
    ' regionData = channelStore.getUserRegionData()
    ' ' Check if the region data is valid
    ' if regionData <> invalid
    '     ' Access the ZIP code from the region data
    '     userZipCode = regionData.zipCode
    '     print "User ZIP Code: " + userZipCode
    m.requestZIPCode = createObject("HttpRequests")
    m.requestZIPCode.callfunc("makePostRequest", {
        api: "https://api.usps.com/addresses/v1/city-state",
        data: {
            ZIPCode: 30022
        }
    })
    m.requestZIPCode.observeFieldScoped("response", "onUSPScallResponse")
end sub

' Get State Code using ZIP Code
sub createUSPScall()
    ' Make an HTTP request to the USPS API endpoint
    ' request = CreateObject("roUrlTransfer")
    ' request.setUrl("https://api.usps.com/addresses/v1/city-state?ZIPCode=30022")
    ' request.setCertificatesFile("common:/certs/ca-bundle.crt")
    ' response = request.getToString()

    ' ' Parse the API response to extract the state code
    ' if response <> invalid
    '     stateInfo = parseJSON(response)
    '     if stateInfo <> invalid
    '         stateCode = stateInfo.state
    '         ' Use the state code in your SceneGraph application
    '     end if
    ' end if
    m.requestStateCode = createObject("HttpRequests")
    m.requestStateCode.callfunc("makePostRequest", {
        api: "https://api.usps.com/addresses/v1/city-state",
        data: {
            ZIPCode: 30022
        }
    })
    m.requestStateCode.observeFieldScoped("response", "onUSPScallResponse")
end sub

' Get Restricted zones on static endpoint
sub createAvailableZonesCall()
    ' m.requestStateCode = createObject("HttpRequests")
    ' m.requestActualZone.callfunc("makePostRequest", {
    '     api: "", ' When exposing the repo, get the direct url of the JSON file
    '     data: {
    '         ZIPCode: 30022
    '     }
    ' })
    ' m.requestActualZone.observeFieldScoped("response", "onAvailableZonesCallResponse")
    localZonesFile = parseJson(readAsciiFile("pkg:/path/to/your/file.json"))
    m.top.availableZones = localZonesFile
end sub

' ' Handling responses ' '
sub onZIPCodeCallResponse()
    m.requestZIPCode.unobserveFieldScoped("response")
    ' Do something
end sub

sub onUSPScallResponse()
    m.requestStateCode.unobserveFieldScoped("response")
    ' Do something
end sub

sub onAvailableZonesCallResponse()
    m.requestActualZone.unobserveFieldScoped("response")
    ' Do something
end sub
