local function sendHudEvents(player)
    if not isElement(player) then return end
    local r = getRoundMapInfo()
    if r.modename ~= "lobby" then
        triggerClientEvent(player, "onClientRoundStart", player)
        triggerClientEvent(player, "wgHideDefaultHud", player)
        triggerClientEvent(player, "wgDrawNewHud", player)
    end
end

addEventHandler("onPlayerJoin", root, function()
    setTimer(sendHudEvents, 2500, 1, source)
end)

addEventHandler("onPlayerDamage", root, function(attacker, weapon)
    if isElement(attacker) and getElementType(attacker) == "player" and weapon > 9 then 
        triggerClientEvent(attacker, "updateHitTimes", attacker) 
    end 
end)

addEventHandler("onMapStarting", root, function(m)
    if m.modename == "lobby" then return end
    setTimer(function() 
        triggerClientEvent(root, "wgHideDefaultHud", root)
        for _, v in ipairs(getElementsByType("player")) do 
            if isElement(v) then
                triggerClientEvent(v, "wgDrawNewHud", v) 
            end
        end
    end, 8000, 1)
end)

addEventHandler("onRoundStart", root, function() 
    for _, v in ipairs(getElementsByType("player")) do 
        if isElement(v) then
            setElementData(v, "loaded", true) 
        end
    end 
    triggerClientEvent(root, "wgReceiveHudTimer", root, getTacticsTimer()) 
end)

addEventHandler("onPlayerTeamSelect", root, function() 
    triggerClientEvent(root, "wgFixPlayer", source, source) 
end)

addEventHandler("onPlayerRestored", root, function()
    if not isElement(source) then return end
    triggerClientEvent(source, "wgHideDefaultHud", source)
    triggerClientEvent(source, "wgDrawNewHud", source)
    triggerClientEvent(source, "onClientRoundStart", source)
end)

addEventHandler("onPlayerRoundRespawn", root, function()
    if not isRoundPaused() and isElement(source) then 
        triggerClientEvent(source, "wgHideDefaultHud", source) 
        triggerClientEvent(source, "wgReceiveHudTimer", source, getTacticsTimer()) 
    end
end)

addEventHandler("onPauseToggle", root, function(state) 
    if state == false and isElement(source) then 
        triggerClientEvent(source, "wgReceiveHudTimer", source, getTacticsTimer()) 
    end 
end)

addEventHandler("onPlayerQuit", root, function() 
    triggerClientEvent(root, "wgFixPlayer", source, source) 
end)