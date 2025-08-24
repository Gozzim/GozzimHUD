-- Auto Door Opener for Zerobot
-- Combines a key-press handler for responsiveness and a polling loop for seamless running.

-- #################### CONFIGURATION ####################
-- Item ID for the HUD icon.
local ICON_ITEM_ID = 12305

-- Position of the icon on the screen.
local ICON_POSITION_X = 10
local ICON_POSITION_Y = 120

-- How often the polling loop checks your movement (in milliseconds).
local POLLING_RATE_MS = 50

-- How many tiles ahead the polling loop checks for doors.
local LOOKAHEAD_DISTANCE = 2

-- Opacity for the icon when ON vs OFF.
local OPACITY_ON = 1.0
local OPACITY_OFF = 0.5
-- ######################################################


-- Convert the list of door IDs into a set for fast lookups.
local doorsSet = {
    [5007] = true, [8265] = true, [1629] = true, [1632] = true, [5129] = true, [6252] = true, [6249] = true, [7715] = true, [7712] = true, [7714] = true,
    [7719] = true, [6256] = true, [1669] = true, [1672] = true, [5125] = true, [5115] = true, [5124] = true, [17701] = true, [17710] = true, [1642] = true,
    [6260] = true, [5107] = true, [4912] = true, [6251] = true, [5291] = true, [1683] = true, [1696] = true, [1692] = true, [5006] = true, [2179] = true, [5116] = true,
    [11705] = true, [30772] = true, [30774] = true, [6248] = true, [5735] = true, [5732] = true, [5120] = true, [23873] = true, [5736] = true,
    [6264] = true, [5122] = true, [30049] = true, [30042] = true, [5131] = true, [8363] = true, [5293] = true, [1664] = true, [5111] = true, [5098] = true
}

-- State tracking variables
local isAutoDoorActive = true
local autoDoorIcon = nil
local lastPosition = nil

-- This function is called when the HUD icon is clicked.
local function toggleAutoDoor()
    isAutoDoorActive = not isAutoDoorActive
    if isAutoDoorActive then
        autoDoorIcon:setOpacity(OPACITY_ON)
        print(">> Auto Door Opener ENABLED.")
    else
        autoDoorIcon:setOpacity(OPACITY_OFF)
        print(">> Auto Door Opener DISABLED.")
    end
end

-- This function checks for a door at a given position and opens it.
local function openDoorAt(pos)
    local thingsOnTile = Map.getThings(pos.x, pos.y, pos.z)
    if not thingsOnTile then
        return
    end

    for _, thing in ipairs(thingsOnTile) do
        if doorsSet[thing.id] then
            Game.useItemFromGround(pos.x, pos.y, pos.z)
            return -- Stop checking this tile once a door is found and used.
        end
    end
end

-- ==================== SYSTEM 1: INSTANT KEY-PRESS HANDLER ====================
-- This provides perfect responsiveness for the first step from a standstill.
local function onHotkeyPress(key, modifier)
    if not isAutoDoorActive then
        return
    end

    local myPlayer = Creature(Player.getId())
    if not myPlayer then
        return
    end
    local currentPos = myPlayer:getPosition()
    if not currentPos then
        return
    end

    local destPos = { x = currentPos.x, y = currentPos.y, z = currentPos.z }
    local moved = false

    -- Check which movement key was pressed and calculate the destination tile.
    if key == HotkeyManager.keyMapping["up"] or key == HotkeyManager.keyMapping["w"] then
        destPos.y = destPos.y - 1
        moved = true
    elseif key == HotkeyManager.keyMapping["down"] or key == HotkeyManager.keyMapping["s"] then
        destPos.y = destPos.y + 1
        moved = true
    elseif key == HotkeyManager.keyMapping["left"] or key == HotkeyManager.keyMapping["a"] then
        destPos.x = destPos.x - 1
        moved = true
    elseif key == HotkeyManager.keyMapping["right"] or key == HotkeyManager.keyMapping["d"] then
        destPos.x = destPos.x + 1
        moved = true
    elseif key == HotkeyManager.keyMapping["q"] then
        destPos.x = destPos.x - 1
        destPos.y = destPos.y - 1
        moved = true
    elseif key == HotkeyManager.keyMapping["e"] then
        destPos.x = destPos.x + 1
        destPos.y = destPos.y - 1
        moved = true
    elseif key == HotkeyManager.keyMapping["z"] then
        destPos.x = destPos.x - 1
        destPos.y = destPos.y + 1
        moved = true
    elseif key == HotkeyManager.keyMapping["c"] then
        destPos.x = destPos.x + 1
        destPos.y = destPos.y + 1
        moved = true
    end

    if moved then
        openDoorAt(destPos)
    end
end


-- ==================== SYSTEM 2: PROACTIVE POLLING LOOP ====================
-- This provides seamless door opening when running continuously.
local function mainDoorLoop()
    if not isAutoDoorActive then
        return
    end

    local myPlayer = Creature(Player.getId())
    if not myPlayer then
        return
    end
    local currentPos = myPlayer:getPosition()
    if not currentPos then
        return
    end

    if lastPosition and (currentPos.x ~= lastPosition.x or currentPos.y ~= lastPosition.y) then
        local dx = currentPos.x - lastPosition.x
        local dy = currentPos.y - lastPosition.y

        for i = 1, LOOKAHEAD_DISTANCE do
            local lookaheadPos = { x = currentPos.x + (dx * i), y = currentPos.y + (dy * i), z = currentPos.z }
            openDoorAt(lookaheadPos)
        end
    end
    lastPosition = currentPos
end

-- ################# SCRIPT INITIALIZATION #################

autoDoorIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, ICON_ITEM_ID, true)

if autoDoorIcon then
    autoDoorIcon:setOpacity(OPACITY_ON)
    autoDoorIcon:setCallback(toggleAutoDoor)

    -- Register BOTH systems to run in parallel.
    Game.registerEvent(Game.Events.HOTKEY_SHORTCUT_PRESS, onHotkeyPress) -- System 1
    Timer.new("ProactiveDoorTimer", mainDoorLoop, POLLING_RATE_MS, true) -- System 2

    print(">> Auto Door Opener HUD loaded.")
else
    print(">> ERROR: Failed to create Auto Door Opener HUD.")
end