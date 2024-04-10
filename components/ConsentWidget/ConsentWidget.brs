' TDB: scenario when stored differs from actual
sub init()
    setStyle()
    ' requestZones()
    if userGaveConsentPreviously()
        getRegistryEntry("user")
        ' set in the
        ' dismiss this widget
    else
        checkUnavailableZones()
        getZIPCode()
        createUSPScall()
        checkUserCanConsent()
        m.userCannotConsent = false
    end if
end sub

sub setStyle()
    m.bg = m.top.findNode("bg")
    m.checklist = m.top.findNode("checklist")
    m.checklistOptions = m.top.findNode("checklistOptions")
    m.title = m.top.findNode("title")
    m.confirmButton = m.top.findNode("confirmButton")

    m.bg.translation = [0, 600]
    m.bg.color = "0xF8F9FA"
    m.bg.height = 480
    m.bg.width = 1920

    m.checklist.translation = [20, 20]
    checkListContent = createObject("roSGNode", "ContentNode")
    checkListItem1 = checkListContent.createChild("ContentNode")
    checkListItem1.update({
        title: "thirdParty"
        text: "I give consent to third parties"
        checkedState: false
        opacity: 1
    }, true)
    checkListItem2 = checkListContent.createChild("ContentNode")
    checkListItem2.update({
        title: "tos"
        text: "I accept terms and conditions"
        checkedState: false
        opacity: 1
    }, true)

    m.title.text = "Data Consent options for "
    m.title.font = "MediumBoldSystemFont"
    m.title.translation = [960, 640]

    m.confirmButton.text = "Accept"
    m.confirmButton.focusable = true
end sub

' Get ZIP Code
sub getZIPCode()
    m.channelStore = createObject("roSGNode", "ChannelStore")
    m.channelStore.observeField("userRegionData", "onUserRegionDataChanges")
    m.channelStore.command = "getUserRegionData"
end sub

sub onUserRegionDataChanges(event as Object)
    region = event.getData()
    m.zipCode = region.zipCode
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
sub checkUnavailableZones()
    ' There's a KI with this not being able to read when is in another project folder
    parsedConsentZones = parseJson(readAsciiFile("pkg:/source/consentZones.json"))
    m.cannotConsentZones = parsedConsentZones?.cannotConsent
end sub

sub onUSPScallResponse(event as Object)
    m.requestStateCode.unobserveFieldScoped("response")
    response = event.getData()
    m.USPSCode = response?.state
    m.title.text += m.USPSCode.toStr()
end sub

sub checkUserCanConsent()
    for i = 0 to m.cannotConsentZones.count()
        if m.cannotConsentZones[i] = m.USPSCode
            m.userCannotConsent = true
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
    ' move this to a function but m.USPSCode does't exists
    ' in order to just set globals when the registry section exists
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
