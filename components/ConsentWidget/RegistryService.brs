function userGaveConsentPreviously() as Boolean
    gaveConsent = false
    registry = createObject("roRegistry")
    sections = registry.getSectionList()
    if sections.count() > 0 and sections.indexOf("privacyConsent") <> -1
         gaveConsent = true
    end if
    return gaveConsent
end function

function getRegistryEntry(key as String) as Dynamic
    section = createObject("roRegistrySection", "privacyConsent")
    if section.exists(key)
        return section.read(key)
    end if
    return invalid
end function

sub setRegistryEntry(key as String, value as String)
    section = createObject("roRegistrySection", "privacyConsent")
    section.write(key, value)
    section.flush()
end sub
