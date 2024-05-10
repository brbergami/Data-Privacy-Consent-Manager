' Section will be "privacyConsent"
function getRegistry(key as String, section as String) as Dynamic
    if registrySectionExists(section) then return section.read(key)
    return invalid
end function

sub setRegistry(key as String, value as String, section as String)
    sectionObj = createObject("roRegistrySection", section)
    sectionObj.write(key, value)
    sectionObj.flush()
end sub

function registrySectionExists(section as String) as Boolean
    registry = createObject("roRegistry")
    sections = registry.getSectionList()
    result = false
    if sections.count() > 0 and sections.indexOf(section) <> -1
        result = true
    end if
    return result
end function

function keyExistsInSection(key as String, section as String) as Boolean
    sectionObj = createObject("roRegistrySection", section)
    return sectionObj.exists(key)
end function
