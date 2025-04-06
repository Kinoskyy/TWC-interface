function weather(_, id)
    local id = tonumber(id)
    if id and (id <= 50 and id >= 0) then
        local player = getLocalPlayer()
        local team = getPlayerTeam(player)
        local r, g, b = 31, 8, 255
        if team then
            r, g, b = getTeamColor(team)
        end
        outputChatBox_("You've set your weather to [#FFFFFF" .. id .. "#" .. string.format("%02X%02X%02X", r, g, b) .. "]", r, g, b, true)
        setWeather_(id)

        local datos = xmlLoadFile("config.xml")
        xmlNodeSetAttribute(datos, "weather", id)
        xmlSaveFile(datos)
        xmlUnloadFile(datos)
    end
end
addCommandHandler("w", weather, false, false)
addCommandHandler("weather", weather, false, false)

function time(_, time)
    local time = tonumber(time)
    if time and (time <= 24 and time >= 0) then
        local player = getLocalPlayer()
        local team = getPlayerTeam(player)
        local r, g, b = 31, 8, 255 
        if team then
            r, g, b = getTeamColor(team)
        end
        outputChatBox_("You've set your time to [#FFFFFF" .. time .. "#" .. string.format("%02X%02X%02X", r, g, b) .. "]", r, g, b, true)
        setTime_(time, 0)

        local datos = xmlLoadFile("config.xml")
        xmlNodeSetAttribute(datos, "time", time)
        xmlSaveFile(datos)
        xmlUnloadFile(datos)
    end
end
addCommandHandler("t", time, false, false)
addCommandHandler("time", time, false, false)

function fps(_, fps)
    local fps = tonumber(fps)
    if fps and (fps >= 24 and fps <= 32767) then
        local player = getLocalPlayer()
        local team = getPlayerTeam(player)
        local r, g, b = 31, 8, 255 -- Color por defecto si no tiene equipo
        if team then
            r, g, b = getTeamColor(team)
        end
        outputChatBox_("You've set your FPS limit to [#FFFFFF" .. fps .. "#" .. string.format("%02X%02X%02X", r, g, b) .. "]", r, g, b, true)
        setFPSLimit(fps)

        local datos = xmlLoadFile("config.xml")
        xmlNodeSetAttribute(datos, "fps", fps)
        xmlSaveFile(datos)
        xmlUnloadFile(datos)
    end
end
addCommandHandler("fps", fps, false, false)

addEventHandler("onClientResourceStart", resourceRoot, function()
    local settings = checkSettings()
    setTime_(settings[1], 0)
    setWeather_(settings[2])
    setTimer(setFPSLimit, 3000, 1, settings[3])
end)

function checkSettings()
    if not xmlLoadFile("config.xml") then
        local datos = xmlCreateFile("config.xml", "settings")
        xmlNodeSetAttribute(datos, "time", 12)
        xmlNodeSetAttribute(datos, "weather", 0)
        xmlNodeSetAttribute(datos, "fps", getFPSLimit())
        xmlSaveFile(datos)
        xmlUnloadFile(datos)
        return {12, 0, 60}
    else
        local datos = xmlLoadFile("config.xml")
        local time = xmlNodeGetAttribute(datos, "time")
        local weather = xmlNodeGetAttribute(datos, "weather")
        local fps = xmlNodeGetAttribute(datos, "fps")
        xmlUnloadFile(datos)
        return {time, weather, fps}
    end
end