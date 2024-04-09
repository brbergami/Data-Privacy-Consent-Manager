sub init()
    setStyle()
    ' requestZones()
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
