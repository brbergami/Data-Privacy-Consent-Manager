' TDB: scenario when stored differs from actual
sub init()
    m.top.id = "consentWidget"
    m.top.visible = false
    if userGaveConsentPreviously()
        closeWidget()
    else
        checkUnavailableZones()
        createIPApiCall()
        m.userCanConsent = true ' So the checkbox is enabled by default
        setStyle()
        checkUserCanConsent()
        m.top.visible = true
    end if
end sub

sub setStyle()
    m.bg = m.top.findNode("bg")
    m.checklist = m.top.findNode("checklist")
    m.checklistOptions = m.top.findNode("checklistOptions")
    m.title = m.top.findNode("title")
    m.confirmButton = m.top.findNode("confirmButton")

    m.bg.translation = [0, 600]
    m.bg.color = "0x1F2430"
    m.bg.height = 480
    m.bg.width = 1920

    m.checklist.translation = [100, 85]
    m.checklist.content = createObject("roSGNode", "ContentNode")
    checkListItem1 = m.checklist.content.createChild("ContentNode")
    checkListItem1.update({
        title: "To third parties",
        checkedState: false,
        opacity: 1
    }, true)
    checkListItem2 = m.checklist.content.createChild("ContentNode")
    checkListItem2.update({
        title: "Terms and Conditions",
        checkedState: false,
        opacity: 1
    }, true)

    m.title.text = "Data Consent options for "
    m.title.font = "font:MediumBoldSystemFont"
    m.title.translation = [960, 100]

    m.confirmButton.text = "Accept"
    m.confirmButton.iconUri = ""
    m.confirmButton.showFocusFootprint = true
    m.confirmButton.minWidth = 280
    m.confirmButton.focusable = true
    m.confirmButton.translation = [1560, 320]
    m.confirmButton.setFocus(true)
end sub

' Get ZIP Code
sub getZIPCode()
    m.channelStore = createObject("roSGNode", "ChannelStore")
    m.channelStore.observeField("userRegionData", "onUserRegionDataChanges")
    m.channelStore.command = "getUserRegionData"
end sub

sub onUserRegionDataChanges(event as Object)
    region = event.getData()
    m.zipCode = region.zip
end sub

' Get State Code using ZIP Code
sub createIPApiCall()
    m.requestRegion = createObject("roSGNode", "RequestsTask")
    m.requestRegion.observeFieldScoped("response", "onIPApiCallResponse")
    m.requestRegion.request = {
        requesttype: "get"
        api: "http://ip-api.com/json/"
        payload: {}
    }
    m.requestRegion.control = "RUN"
end sub

' Get Restricted zones on static endpoint. Using this locally atm
sub checkUnavailableZones()
    parsedConsentZones = parseJson(readAsciiFile("pkg:/source/consentZones.json"))
    m.cannotConsentZones = parsedConsentZones.cannotConsent
end sub

sub onIPApiCallResponse(event as Object)
    m.requestRegion.unobserveFieldScoped("response")
    m.requestRegion.control = "STOP"
    response = event.getData()
    m.userRegion = response?.region
    m.title.text += m.userRegion
end sub

sub checkUserCanConsent()
    for zones = 0 to m.cannotConsentZones.count()
        if m.cannotConsentZones[zones] = m.userRegion
            m.userCanConsent = false
            for each item in m.checklist.content
                item.checkOnSelect = false
                item.checkedState = true
                item.opacity = 0.5
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
        consent[item.id] = item.checkedState
    end for
    ' move this to a function but m.userRegion does't exists
    ' in order to just set globals when the registry section exists
    m.global.addFields({
        consent: {
            consentOptions: consentOptions,
            userState: m.userRegion
        }
    })
    closeWidget()
end sub

sub closeWidget()
    m.top.close()
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press
        if key = "OK"
            if m.confirmButton.hasFocus()
                handleAccept()
            end if
            handled = true
        else if key = "back"
            closeWidget()
            handled = true
        else if key = "left"
            if m.userCanConsent = true
                m.checklist.setFocus(true)
            end if
            handled = true
        end if
    end if
    return handled
end function
