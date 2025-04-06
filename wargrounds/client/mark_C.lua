local cooldown = false  
function markTarget(key, keyState)
    if getElementHealth(localPlayer) <= 0 then return end
    if cooldown then return end  
    local player = getLocalPlayer()
    local team = getPlayerTeam(player)
    if team and getTeamName(team) == "REFEREE" then return end
    if not team then return end
    if getElementHealth(player) <= 0 then return end
    if not isPedAiming(player) then return end
    local startX, startY, startZ = getPedTargetStart(player)
    local endX, endY, endZ = getPedTargetEnd(player)
    if not (startX and endX) then return end
    local dirX, dirY, dirZ = endX - startX, endY - startY, endZ - startZ
    local length = math.sqrt(dirX^2 + dirY^2 + dirZ^2)
    if length == 0 then return end
    dirX, dirY, dirZ = dirX / length, dirY / length, dirZ / length
    local extendedX = startX + dirX * 1000
    local extendedY = startY + dirY * 1000
    local extendedZ = startZ + dirZ * 1000
    local hit, hitX, hitY, hitZ = processLineOfSight(startX, startY, startZ, extendedX, extendedY, extendedZ, true, true, true, true, false, false, false, false, localPlayer)
    if not hit then
        hitX, hitY, hitZ = extendedX, extendedY, extendedZ
    end
    triggerServerEvent("createTeamMarker", resourceRoot, startX, startY, startZ, hitX, hitY, hitZ, team)
    cooldown = true
    setTimer(function() cooldown = false end, 5000, 1)
end
bindKey("lalt", "down", markTarget)
function playFirstBloodSound(soundFile)
    local soundElement = playSound(soundFile)  
    if soundElement then
        setSoundVolume(soundElement, 1.0)
    end
end
addEvent("playSoundForClient", true)
addEventHandler("playSoundForClient", resourceRoot, playFirstBloodSound)