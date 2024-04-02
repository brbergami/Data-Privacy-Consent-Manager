sub init()
    m.section = createObject("roRegistrySection", "privacyConsent")
end sub

sub setEntry(key as String, value as String)
    m.section.write(key, value)
    m.section.flush()
end sub

function getEntry(key as String) as Dynamic
    if m.section.exists(key)
        return m.section.read(key)
    end if
    return invalid
end function
