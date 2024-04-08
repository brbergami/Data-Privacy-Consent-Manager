' If user changes region that should be considered
' even when reading from registry

sub initialize() ' Check if this is the correct approach
    getZIPCode()
    createUSPScall()
    createUnavailableZonesCall()
    checkUserCanConsent()
    m.userCannotConsent = false
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
    for i = 0 to m.cannotConsent.count()
        if m.cannotConsentZones[i] = m.USPSCode
            m.userCannotConsent = true
            for each item in m.checklist.content
                item.checkOnSelect = false
                item.checkedState = true
                item.style = {
                    opacity: 0.5
                }
            end for
            m.checklist.isFocusable = false
            m.confirmButton.setFocus(true)
        end if
        return
    end for
    m.checklist.setFocus(true)
end sub

sub handleAccept()
    consentOptions = {}
    for each item in m.checklist.content
        consent[item.id] = item.checked
        consent[item.id] = item.checkedState
    end for
    m.global.addFields({
        consent: {
            consentOptions: consentOptions,
            userState: m.USPSCode
        }
    })
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press
        if key = "OK"
            if m.confirmButton.hasFocus()
                handleAccept()
            end if
            handled = true
        else if key = "left"
            if m.userCannotConsent = false
                m.checklist.setFocus(true)
            end if
            handled = true
        end if
    end if
    return handled
end function
