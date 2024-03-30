sub initialize() ' Check if this is the correct approach
    getZIPCode()
    createUSPScall()
    createUnavailableZonesCall()
    checkUserCanConsent()
end sub

' Get ZIP Code
sub getZIPCode()
    channelStore = createObject("roSGNode", "ChannelStore")
    m.zipCode = channelStore.getUserRegionData()?.zipCode
end sub

' Get State Code using ZIP Code
sub createUSPScall()
    m.requestStateCode = createObject("roSGNode", "RequestsTask")
    m.requestStateCode.callfunc("makePostRequest", {
        api: "https://api.usps.com/addresses/v1/city-state",
        data: {
            ZIPCode: m.zipCode
        }
    })
    m.requestStateCode.observeFieldScoped("response", "onUSPScallResponse")
end sub

' Get Restricted zones on static endpoint. Using this locally atm
sub createUnavailableZonesCall()
    m.cannotConsentZones = parseJson(readAsciiFile("pkg:/consentZones.json"))?.canConsent
end sub

sub onUSPScallResponse(event as Object)
    m.requestStateCode.unobserveFieldScoped("response")
    response = event.getData()
    m.USPSCode = response?.state
    m.title.text += m.USPSCode.toStr()
end sub

sub checkUserCanConsent()
    for i = 0 in m.cannotConsent.count()
        if m.cannotConsentZones[i] = m.USPSCode
            for each item in m.checklist.content
                item.checkOnSelect = false
                item.checkedState = true
                item.style = {
                    opacity: 0.5
                }
            end for
        end if
    end for
end sub
