-- Auto Door Opener for Zerobot
-- Automatically opens doors when you walk towards them.

-- #################### CONFIGURATION ####################
-- Item ID for the HUD icon. A door seems appropriate.
local ICON_ITEM_ID = 5007

-- Position of the icon on the screen.
local ICON_POSITION_X = 10
local ICON_POSITION_Y = 480 -- Positioned below the other icons

-- Opacity for the icon when ON vs OFF.
local OPACITY_ON = 1.0  -- Fully visible
local OPACITY_OFF = 0.5 -- Semi-transparent
-- ######################################################


-- Convert the list of door IDs into a set for fast lookups.
local doorsSet = {
    [5007]=true, [8265]=true, [1629]=true, [1632]=true, [5129]=true, [6252]=true, [6249]=true, [7715]=true, [7712]=true, [7714]=true,
    [7719]=true, [6256]=true, [1669]=true, [1672]=true, [5125]=true, [5115]=true, [5124]=true, [17701]=true, [17710]=true, [1642]=true,
    [6260]=true, [5107]=true, [4912]=true, [6251]=true, [5291]=true, [1683]=true, [1696]=true, [1692]=true, [5006]=true, [2179]=true, [5116]=true,
    [11705]=true, [30772]=true, [30774]=true, [6248]=true, [5735]=true, [5732]=true, [5120]=true, [23873]=true, [5736]=true,
    [6264]=true, [5122]=true, [30049]=true, [30042]=true
}

-- State tracking variables
local isAutoDoorActive = false
local autoDoorIcon = nil

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
    -- Get all items on the target tile.
    local thingsOnTile = Map.getThings(pos.x, pos.y, pos.z)
    if not thingsOnTile then return end

    -- Check if any item on the tile is a door from our list.
    for _, thing in ipairs(thingsOnTile) do
        if doorsSet[thing.id] then
            -- Found a door, use the item at that position.
            Game.useItemFromGround(pos.x, pos.y, pos.z)
            -- Stop checking this tile once a door is found and used.
            return
        end
    end
end

-- This function listens for movement key presses.
local function onHotkeyPress(key, modifier)
    -- Only run if the feature is toggled on.
    if not isAutoDoorActive then return end

    -- Get the player's current position.
    local myPlayer = Creature(Player.getId())
    if not myPlayer then return end
    local currentPos = myPlayer:getPosition()
    if not currentPos then return end

    -- Create a copy of the position to calculate the next step.
    local nextPos = {x = currentPos.x, y = currentPos.y, z = currentPos.z}
    local keyFound = false

    -- Check which movement key was pressed and calculate the destination tile.
    if key == HotkeyManager.keyMapping["up"] or key == HotkeyManager.keyMapping["w"] then
        nextPos.y = nextPos.y - 1; keyFound = true
    elseif key == HotkeyManager.keyMapping["down"] or key == HotkeyManager.keyMapping["s"] then
        nextPos.y = nextPos.y + 1; keyFound = true
    elseif key == HotkeyManager.keyMapping["left"] or key == HotkeyManager.keyMapping["a"] then
        nextPos.x = nextPos.x - 1; keyFound = true
    elseif key == HotkeyManager.keyMapping["right"] or key == HotkeyManager.keyMapping["d"] then
        nextPos.x = nextPos.x + 1; keyFound = true
    -- Diagonal checks (like OTCv8)
    elseif key == HotkeyManager.keyMapping["q"] then
        nextPos.x = nextPos.x - 1; nextPos.y = nextPos.y - 1; keyFound = true
    elseif key == HotkeyManager.keyMapping["e"] then
        nextPos.x = nextPos.x + 1; nextPos.y = nextPos.y - 1; keyFound = true
    elseif key == HotkeyManager.keyMapping["z"] then
        nextPos.x = nextPos.x - 1; nextPos.y = nextPos.y + 1; keyFound = true
    elseif key == HotkeyManager.keyMapping["c"] then
        nextPos.x = nextPos.x + 1; nextPos.y = nextPos.y + 1; keyFound = true
    end

    -- If a movement key was pressed, check the destination tile for a door.
    if keyFound then
        openDoorAt(nextPos)
    end
end


-- ################# SCRIPT INITIALIZATION #################

autoDoorIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, ICON_ITEM_ID, true)

if autoDoorIcon then
    autoDoorIcon:setOpacity(OPACITY_OFF)
    autoDoorIcon:setCallback(toggleAutoDoor)

    -- Register the event listener for hotkey presses.
    Game.registerEvent(Game.Events.HOTKEY_SHORTCUT_PRESS, onHotkeyPress)

    print(">> Auto Door Opener HUD loaded. Click the door icon to toggle.")
else
    print(">> ERROR: Failed to create Auto Door Opener HUD.")
end