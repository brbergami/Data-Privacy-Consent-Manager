sub showConsentWidget()
    m.consentWidget = CreateObject("roSGNode", "ConsentWidget")
    m.global.observeField("consent", "onConsentGiven")
    showScreen(m.consentWidget)
end sub

sub onConsentGiven(event as Object)
    closeScreen(m.consentWidget)
end sub
