local lastClickedPlayer = false
local lastElementType = ""

function onJoin()
    if not dxGetStatus().AllowScreenUpload then
        triggerServerEvent("wargrounds:handleScreenshot", localPlayer)
    end
end
addEventHandler("onClientPlayerJoin", localPlayer, onJoin)

setTimer(function()
    if not dxGetStatus().AllowScreenUpload then
        triggerServerEvent("wargrounds:handleScreenshot", localPlayer)
    end
end, 1000, 0)

function guiClick(button, state)
    if button == "left" and state == "up" then
        if isElement(source) then
            local elementType = getElementType(source)

            if elementType == "gui-button" then
                local buttonText = guiGetText(source)
                outputConsole(buttonText)
                if buttonText == "Screen Shot" then
                    triggerServerEvent("sendCheater", root, getPlayerName(localPlayer))
                elseif buttonText == "Set Health" then
                    lastElementType = "Set Health"
                elseif buttonText == "Set Armour" then
                    lastElementType = "Set Armour"
                elseif buttonText == "Set Dimens." then
                    lastElementType = "Set Dimens."
                elseif buttonText == "Give JetPack" then
                    triggerServerEvent("reportJetpack", root, getPlayerName(localPlayer), lastClickedPlayer)
                elseif buttonText == "Spectate" then
                    if lastClickedPlayer and getPlayerFromName(lastClickedPlayer) then
                        triggerServerEvent("reportSpec", root, getPlayerName(localPlayer), lastClickedPlayer)
                    end
                elseif buttonText == "OK" or buttonText == "Ok" then
                    if lastElementType == "Set Health" then
                        triggerServerEvent("reportHealth", root, getPlayerName(localPlayer), lastClickedPlayer)
                        lastElementType = ""
                    elseif lastElementType == "Set Armour" then
                        triggerServerEvent("reportArmour", root, getPlayerName(localPlayer), lastClickedPlayer)
                        lastElementType = ""
                    elseif lastElementType == "Set Dimens." then
                        triggerServerEvent("reportDimension", root, getPlayerName(localPlayer), lastClickedPlayer,
                            getElementDimension(localPlayer))
                        lastElementType = ""
                    end
                elseif buttonText == "Cancel" then
                    if lastElementType == "Set Health" then
                        lastElementType = ""
                    elseif lastElementType == "Set Armour" then
                        lastElementType = ""
                    elseif lastElementType == "Set Dimens." then
                        lastElementType = ""
                    end
                elseif string.match(buttonText, "Give:") then
                    triggerServerEvent("reportElement", root, getPlayerName(localPlayer), lastClickedPlayer, buttonText)
                end
            elseif elementType == "gui-gridlist" then

                local selected = guiGridListGetSelectedItem(source)
                if selected and selected ~= -1 then
                    local playerName = guiGridListGetItemText(source, selected, 1)
                    if getPlayerFromName(playerName) then
                        lastClickedPlayer = playerName
                    end
                end

            end
        end
    end
end
addEventHandler("onClientGUIClick", root, guiClick)