local customCrosshairEnabled = false
local crosshairImage = dxCreateTexture("images/aim_m4.png")

function drawCustomCrosshair()
    if customCrosshairEnabled and crosshairImage then
        local player = localPlayer
        local currentWeapon = getPedWeapon(player)
        if isPedAiming(player) and currentWeapon == 24 then
            local tEnd = Vector3(getPedTargetEnd(player))
            local position = Vector2(getScreenFromWorldPosition(tEnd.x, tEnd.y, tEnd.z))
            if position then
                dxDrawImage(position.x - 13, position.y - 13, 25, 25, crosshairImage, 0, 0, 0, tocolor(255, 255, 255, 255))
            end
        end
    end
end

function isPedAiming(thePedToCheck)
    if isElement(thePedToCheck) then
        if getElementType(thePedToCheck) == "player" or getElementType(thePedToCheck) == "ped" then
            if getPedTask(thePedToCheck, "secondary", 0) == "TASK_SIMPLE_USE_GUN" or isPedDoingGangDriveby(thePedToCheck) then
                return true
            end
        end
    end
    return false
end

function updateCrosshairState()
    local currentWeapon = getPedWeapon(localPlayer)
    if customCrosshairEnabled and isPedAiming(localPlayer) and currentWeapon == 24 then
        setPlayerHudComponentVisible("crosshair", false)
    else
        setPlayerHudComponentVisible("crosshair", true)
    end
end

function toggleCustomCrosshair()
    customCrosshairEnabled = not customCrosshairEnabled

    if not customCrosshairEnabled then
        setPlayerHudComponentVisible("crosshair", true)
    end

    local playerTeam = getPlayerTeam(localPlayer)
    local r, g, b = 255, 255, 255 
    if playerTeam then
        r, g, b = getTeamColor(playerTeam)
    end

    outputChatBox("Custom crosshair " .. (customCrosshairEnabled and "enabled" or "disabled"), r, g, b) end

addCommandHandler("mira", toggleCustomCrosshair)
addEventHandler("onClientRender", root, function()
    if customCrosshairEnabled then
        updateCrosshairState()
        drawCustomCrosshair()
    end
end)