sub showConsentWidget()
    m.consentWidget = CreateObject("roSGNode", "ConsentWidget")
    m.global.observeField("consent", "onAcceptButtonSelected")
    showScreen(m.consentWidget)
end sub

sub onAcceptButtonSelected(event as Object)
    closeScreen(m.consentWidget)
end sub
