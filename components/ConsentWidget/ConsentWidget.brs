' TDB: scenario when stored differs from actual
sub init()
    m.top.id = "consentWidget"
    m.top.visible = false
    if userGaveConsentPreviously()
        closeWidget()
    else
        checkUnavailableZones()
        createIPApiCall()
        setStyle()
        hookObservers()
        m.userCanConsent = true ' So the checkbox is enabled by default
        m.top.visible = true
    end if
end sub

sub setStyle()
    m.screenMask = m.top.findNode("screenMask")
    m.bg = m.top.findNode("bg")
    m.checklist = m.top.findNode("checklist")
    m.checklistOptions = m.top.findNode("checklistOptions")
    m.separator = m.top.findNode("separator")
    m.title = m.top.findNode("title")
    m.confirmButton = m.top.findNode("confirmButton")

    m.screenMask.color = "0x000000"
    m.screenMask.opacity = 0.8
    m.screenMask.height = 600
    m.screenMask.width = 1920

    m.bg.translation = [0, 600]
    m.bg.color = "0x1F2430"
    m.bg.height = 480
    m.bg.width = 1920

    m.checklist.translation = [150, 120]
    m.checklist.content = createObject("roSGNode", "ContentNode")
    checkListItem1 = m.checklist.content.createChild("ContentNode")
    checkListItem1.update({
        id: "thidParty",
        title: "To third parties",
        checkedState: false,
        opacity: 1
    }, true)
    checkListItem2 = m.checklist.content.createChild("ContentNode")
    checkListItem2.update({
        id: "termsAndConditions",
        title: "Terms and Conditions",
        checkedState: false,
        opacity: 1
    }, true)

    m.separator.translation = [960, 40]
    m.separator.color = "0xD3D3D3"
    m.separator.height = 400
    m.separator.width = 2

    m.title.text = "Data Consent options for "
    m.title.font = "font:MediumBoldSystemFont"
    m.title.translation = [1110, 120]

    m.confirmButton.text = "Accept"
    m.confirmButton.showFocusFootprint = true
    m.confirmButton.minWidth = 280
    m.confirmButton.maxWidth = 280
    m.confirmButton.translation = [1550, 300]
    m.confirmButton.setFocus(true)
end sub

sub hookObservers()
    m.confirmButton.observeField("buttonSelected", "handleAccept")
end sub

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

sub onIPApiCallResponse(event as Object)
    m.requestRegion.unobserveFieldScoped("response")
    m.requestRegion.control = "STOP"
    response = event.getData()
    m.userRegion = response.region
    m.title.text += m.userRegion + " (" + response.city + ")."
    checkUserCanConsent()
end sub

' Get Restricted zones on static endpoint. Using this locally atm
' Then it will be moved to the same repo
sub checkUnavailableZones()
    parsedConsentZones = parseJson(readAsciiFile("pkg:/source/consentZones.json"))
    m.cannotConsentZones = parsedConsentZones.cannotConsent
end sub

sub checkUserCanConsent()
    for zones = 0 to m.cannotConsentZones.count()
        if m.cannotConsentZones[zones] = m.userRegion
            m.userCanConsent = false
            m.checklist.checkOnSelect = false
            m.checklist.checkedState = [true, true]
            m.confirmButton.setFocus(true)
            return
        end if
    end for
    m.checklist.content.getChild(0).setFocus(true)
end sub

sub handleAccept()
    consentOptions = {}
    for each item in m.checklist.content.getChildren(-1, 0)
        consentOptions[item.id] = item.checkedState
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
    m.top.close = true
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if  key = "back"
        closeWidget()
        return true
    else if key = "left"
        if m.userCanConsent = true
            m.checklist.setFocus(true)
            return true
        end if
    else if key = "right" ' This for clarity
        m.confirmButton.setFocus(true)
        return true
    else if key = "up"
        if m.checklist.content.isInFocusChain()
            m.checklist.content.getChild(0).setFocus(true)
            return true
        end if
    else if key = "down"
        if m.checklist.content.isInFocusChain()
            m.checklist.content.getChild(1).setFocus(true)
            return true
        end if
    end if
    return false
end function
