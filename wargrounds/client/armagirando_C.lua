local damageObjects = {}
local timers = {}
local weaponModels = {
  [1] = 331, [2] = 333, [3] = 334, [4] = 335, [5] = 336, [6] = 337,
  [7] = 338, [8] = 339, [9] = 341, [10] = 321, [11] = 322, [12] = 323,
  [14] = 325, [15] = 326, [16] = 342, [17] = 343, [18] = 344, [22] = 346,
  [23] = 347, [24] = 348, [25] = 349, [26] = 350, [27] = 351, [28] = 352,
  [29] = 353, [30] = 355, [31] = 356, [32] = 372, [33] = 357, [34] = 358,
  [35] = 359, [36] = 360, [37] = 361, [38] = 362, [39] = 363, [40] = 364,
  [41] = 365, [42] = 366
}

addEvent("onDMG", true)
addEventHandler("onDMG", root, function(player, weapon)
  local modelID = weaponModels[weapon]
  if not modelID then return end

  if isElement(damageObjects[player]) then
    destroyElement(damageObjects[player])
    damageObjects[player] = nil
  end

  local x, y, z = getElementPosition(player)
  damageObjects[player] = createObject(modelID, x, y, z + 1.15)
  setElementCollisionsEnabled(damageObjects[player], false)

  if isTimer(timers[player]) then
    killTimer(timers[player])
  end
  timers[player] = setTimer(function(target)
    if isElement(damageObjects[target]) then
      destroyElement(damageObjects[target])
      damageObjects[target] = nil
    end
  end, 6000, 1, player)
end)

addEventHandler("onClientPreRender", root, function()
  for player, object in pairs(damageObjects) do
    if isElement(player) and isElement(object) then
      local x, y, z = getElementPosition(player)
      local rx, ry, rz = getElementRotation(object)
      setElementPosition(object, x, y, z + 1.15)
      setElementRotation(object, rx, ry, rz + 5)
      setElementInterior(object, getElementInterior(player))
      setElementDimension(object, getElementDimension(player))
    end
  end
end)