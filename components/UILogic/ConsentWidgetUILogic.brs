sub showConsentWidget()
    m.consentWidget = CreateObject("roSGNode", "ConsentWidget")
    m.consentWidget.observeField("close", "onConsentSet")
    showScreen(m.consentWidget)
end sub

sub onConsentSet(event as Object)
    closeScreen(m.consentWidget)
end sub
