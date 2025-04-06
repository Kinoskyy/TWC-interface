local screenW, screenH = guiGetScreenSize()
local scaleW, scaleH = screenW/1920, screenH/1080
local fonts = {
    main = dxCreateFont("verdana.ttf", 85),
    medium = dxCreateFont("verdana.ttf", 17),
    large = dxCreateFont("verdana.ttf", 120)
}

local hudState = {
    trueShow = false,
    showMap = false,
    roundLeft = {"Round Starting", "ms"},
    times = {shot = 0, hit = 0, acc = 0},
    teamPlayers = {red = {}, blue = {}}
}

local hudComponents = {"elementlist", "playerlist", "race", "teamlist", "timeleft"}
local hudTimer
local positions = {
    time = {x = screenW * 0.4557, y = screenH * 0.9363, w = screenW * 0.5359, h = screenH * 1.02},
    team1 = {x = screenW * 0.3995, y = screenH * 0.9724, w = screenW * 0.4573, h = screenH * 0.9839},
    team2 = {x = screenW * 0.5373, y = screenH * 0.9724, w = screenW * 0.5941, h = screenH * 0.9839},
    score = {
        team1 = {x = screenW * 1.8021, y = screenH * 0.1844, w = screenW * 0.8535, h = screenH * 0.2089},
        separator = {x = screenW * 0.8549, y = screenH * 0.1875, w = screenW * 0.8708, h = screenH * 0.2089},
        team2 = {x = screenW * 0.8710, y = screenH * 0.1844, w = screenW * 0.9208, h = screenH * 0.2089}
    }
}

addEvent("wgHideDefaultHud", true)
addEvent("wgDrawNewHud", true)
addEvent("wgReceiveHudTimer", true)
addEvent("wgFixPlayer", true)
addEventHandler("wgHideDefaultHud", root, function()
    for _, v in ipairs(hudComponents) do
        showRoundHudComponent(v, false)
    end
end)

addEventHandler("wgDrawNewHud", root, function()
    hudState.show = true
    hudState.roundLeft[1] = isRoundPaused() and "Pause" or hudState.roundLeft[1]
end)

addEventHandler("wgReceiveHudTimer", root, function(ms)
    if not isTimer(hudTimer) and not isRoundPaused() then
        local r = getRoundMapInfo()
        if r.modename ~= "lobby" then
            hudTimer = setTimer(function() end, ms, 1)
        end
    else
        hudState.roundLeft[2] = ms
    end
end)

local function handlePlayerTeamChange(player, teamID)
    if not isElement(player) then return end
    wgFixPlayer(player)
    local teamTable = teamID == "1" and hudState.teamPlayers.red or hudState.teamPlayers.blue
    
    local alreadyInTeam = false
    for _, v in ipairs(teamTable) do
        if v == player then
            alreadyInTeam = true
            break
        end
    end
    
    if not alreadyInTeam then
        table.insert(teamTable, player)
    end
end

addEventHandler("onClientPlayerRoundRespawn", localPlayer, function()
    local team = getPlayerTeam(source)
    if team == getTeamFromID("1") then 
        handlePlayerTeamChange(source, "1")
    elseif team == getTeamFromID("2") then 
        handlePlayerTeamChange(source, "2")
    end
    hudState.show = true
end)

addEventHandler("onClientPlayerGameStatusChange", root, function(oldS)
    local newS = getPlayerGameStatus(source)
    if newS == "Die" then 
        fixPlayer(source)
    elseif newS == "Play" then 
        local team = getPlayerTeam(source)
        if team == getTeamFromID("1") then 
            handlePlayerTeamChange(source, "1")
        elseif team == getTeamFromID("2") then 
            handlePlayerTeamChange(source, "2")
        end
    end
end)

addEventHandler("onClientRoundStart", root, function()
    local r = getRoundMapInfo()
    if r.modename ~= "lobby" then
        hudState.showMap = true
    end
    
    setPlayerHudComponentVisible("clock", false)
    
    hudState.teamPlayers.red = {}
    hudState.teamPlayers.blue = {}
    
    for _, v in ipairs(getPlayersInTeam(getTeamFromID("1"))) do
        if isElement(v) and getPlayerGameStatus(v) == "Play" then
            table.insert(hudState.teamPlayers.red, v)
        end
    end
    
    for _, v in ipairs(getPlayersInTeam(getTeamFromID("2"))) do
        if isElement(v) and getPlayerGameStatus(v) == "Play" then
            table.insert(hudState.teamPlayers.blue, v)
        end
    end
    
    hudState.trueShow = true
end)

addEventHandler("onClientRoundFinish", root, function()
    if isTimer(hudTimer) then killTimer(hudTimer) end
    hudState.teamPlayers.red = {}
    hudState.teamPlayers.blue = {}
    hudState.times = {shot = 0, hit = 0, acc = 0}
    hudState.roundLeft[1] = "Round Starting"
    hudState.show = false
    hudState.showMap = false
end)

addEventHandler("onClientMapStarting", root, function()
    if isTimer(hudTimer) then killTimer(hudTimer) end
    hudState.teamPlayers.red = {}
    hudState.teamPlayers.blue = {}
    hudState.times = {shot = 0, hit = 0, acc = 0}
    hudState.show = false
    hudState.showMap = false
    hudState.trueShow = false
end)

addEventHandler("onClientPauseToggle", root, function(pause)
    if pause then
        hudState.roundLeft[1] = "Pause"
        if isTimer(hudTimer) then
            hudState.roundLeft[2] = getTimerDetails(hudTimer)
            killTimer(hudTimer)
        end
    elseif not isTimer(hudTimer) then
        hudTimer = setTimer(function() end, hudState.roundLeft[2], 1)
    end
end)

addEventHandler("wgFixPlayer", root, function(p)
    if not isElement(p) then return end
   
    local function removeFromTeam(teamTable, player)
        for k, v in ipairs(teamTable) do 
            if v == player then 
                table.remove(teamTable, k)
                break
            end
        end
    end
    removeFromTeam(hudState.teamPlayers.red, p)
    removeFromTeam(hudState.teamPlayers.blue, p)
end)

local function drawTeamStats(pos, text, r, g, b)
    dxDrawText(text, pos.x + 2, pos.y + 2, pos.w, pos.h, tocolor(0, 0, 0, 255), 0.94 * scaleH, fonts.medium, "center", "center")
    dxDrawText(text, pos.x, pos.y, pos.w, pos.h, tocolor(r, g, b, 255), 0.94 * scaleH, fonts.medium, "center", "center")
end

local function drawScoreboard(t1, t2, t1Score, t2Score, t1r, t1g, t1b, t2r, t2g, t2b)

    dxDrawText(getTeamName(t1).." #000000"..t1Score, positions.score.team1.x + 21, positions.score.team1.y + 1, positions.score.team1.w + 1, positions.score.team1.y + 17, tocolor(0, 0, 0, 255), scaleH/5, fonts.main, "right", "center", false, false, false, true)
    dxDrawText(getTeamName(t1).." #FFFFFF"..t1Score, positions.score.team1.x, positions.score.team1.y, positions.score.team1.w, positions.score.team1.y + 16, tocolor(t1r, t1g, t1b, 255), scaleH/5, fonts.main, "right", "center", false, false, false, true)
    
    dxDrawText("-", positions.score.separator.x, positions.score.separator.y, positions.score.separator.w, positions.score.separator.y + 12, tocolor(0, 0, 0, 255), scaleH/5, fonts.large, "center", "center")
    dxDrawText("-", positions.score.separator.x, positions.score.separator.y, positions.score.separator.w, positions.score.separator.y + 10, tocolor(255, 255, 255, 255), scaleH/5, fonts.large, "center", "center")
    
    dxDrawText("#000000"..t2Score.." "..getTeamName(t2), positions.score.team2.x + 1, positions.score.team2.y, positions.score.team2.x +1, positions.score.team2.y + 18, tocolor(0, 0, 0, 255), scaleH/5, fonts.main, "left", "center", false, false, false, true)
    dxDrawText("#FFFFFF"..t2Score.." #"..string.format("%02X%02X%02X", t2r, t2g, t2b)..getTeamName(t2), positions.score.team2.x, positions.score.team2.y + 17, positions.score.team2.w, positions.score.team2.y, tocolor(255, 255, 255, 255), scaleH/5, fonts.main, "left", "center", false, false, false, true)
end

addEventHandler("onClientRender", root, function()
    if not hudState.trueShow or not hudState.show then return end
    local r = getRoundMapInfo()
    local t1 = getTeamFromID("1")
    local t2 = getTeamFromID("2")
    if not t1 or not t2 then return end
    local t1r, t1g, t1b = getTeamColor(t1)
    local t2r, t2g, t2b = getTeamColor(t2)
    local scoreType = r.modename == "domination" and "Points" or "Score"
    local t1Score = getElementData(t1, scoreType) or 0
    local t2Score = getElementData(t2, scoreType) or 0
    local timeText = getTimeLeft(hudTimer)
    dxDrawText(timeText, positions.time.x + 3, positions.time.y + 3, positions.time.w, positions.time.h, tocolor(0, 0, 0, 255), 0.98 * scaleH, fonts.medium, "center", "center")
    dxDrawText(timeText, positions.time.x, positions.time.y, positions.time.w, positions.time.h, tocolor(255, 255, 255, 255), 0.98 * scaleH, fonts.medium, "center", "center")
    local aliveRed = #getAlivePlayersInTeam("1")
    local aliveBlue = #getAlivePlayersInTeam("2")
    local team1Text = getTeamHP("1").." ("..aliveRed..")"
    local team2Text = "("..aliveBlue..") "..getTeamHP("2")
    
    drawTeamStats(positions.team1, team1Text, t1r, t1g, t1b)
    drawTeamStats(positions.team2, team2Text, t2r, t2g, t2b)
    drawScoreboard(t1, t2, t1Score, t2Score, t1r, t1g, t1b, t2r, t2g, t2b)
end)

function getAlivePlayersInTeam(teamID)
    local alivePlayers = {}
    local team = getTeamFromID(teamID)
    if not team then return alivePlayers end
    
    for _, v in ipairs(getPlayersInTeam(team)) do
        if isElement(v) and not isPedDead(v) and getPlayerGameStatus(v) == "Play" then
            table.insert(alivePlayers, v)
        end
    end
    return alivePlayers
end

function getTeamHP(teamID)
    local hp = 0
    local team = getTeamFromID(teamID)
    if not team then return hp end
    
    for _, v in ipairs(getPlayersInTeam(team)) do
        if isElement(v) and not isPedDead(v) and getPlayerGameStatus(v) == "Play" then
            hp = hp + math.ceil((getElementHealth(v) or 0) + (getPedArmor(v) or 0))
        end
    end
    return hp
end

function getTeamFromID(id)
    for _, team in ipairs(getElementsByType("team")) do
        if isElement(team) and tostring(getElementData(team, "Side")) == id then
            return team
        end
    end
    return false
end

function getTimeLeft(timer)
    if isTimer(timer) then
        local ms = getTimerDetails(timer)
        local m = math.floor(ms / 60000)
        local s = math.floor((ms - m * 60000) / 1000)
        return string.format("%d:%02d", m, s)
    end
    return hudState.roundLeft[1]
end

function firstUpper(str)
    return str and (str:gsub("^%l", string.upper)) or ""end