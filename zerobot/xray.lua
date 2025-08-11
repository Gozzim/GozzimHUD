-- X-Ray Player List for Zerobot
-- Detects players on the level below and displays their names in a list on the HUD.

-- #################### CONFIGURATION ####################
-- The Item ID for the toggle icon. An eye (e.g., from a beholder) seems fitting.
local ICON_ITEM_ID = 3068

-- Position of the toggle icon on the screen.
local ICON_POSITION_X = 10
local ICON_POSITION_Y = 440 -- Positioned below the other icons

-- Starting position for the list of player names.
local LIST_START_X = 10
local LIST_START_Y = 480

-- Vertical spacing between names in the list.
local LIST_SPACING_Y = 20

-- How often the script checks for players (in milliseconds).
local SCAN_INTERVAL_MS = 500

-- Color for the "grayed out" text (R, G, B).
local TEXT_COLOR_R, TEXT_COLOR_G, TEXT_COLOR_B = 180, 180, 180

-- Opacity for the toggle icon when ON vs OFF.
local OPACITY_ON = 1.0
local OPACITY_OFF = 0.5
-- ######################################################


-- State tracking variables
local isXRayActive = false
local xrayToggleIcon = nil
-- Table to store active HUDs, using creature ID as the key. { [creatureId] = hudObject }
local activePlayerHuds = {}


-- This function updates the HUD elements based on current player locations.
local function updateXRayList()
    if not isXRayActive then return end

    -- Get our own player's Z position to determine the floor below.
    local myPlayerCreature = Creature(Player.getId())
    if not myPlayerCreature then return end
    local myPos = myPlayerCreature:getPosition()
    if not myPos then return end
    local floorBelowZ = myPos.z + 1

    -- Keep track of players found in this scan to remove old entries.
    local playersFoundThisTick = {}

    -- Get all players on screen (not just our floor).
    local allPlayersOnScreen = Map.getCreatureIds(false, true)
    if not allPlayersOnScreen then
        -- If no players are on screen, clear all existing HUDs.
        for cid, hud in pairs(activePlayerHuds) do
            hud:destroy()
        end
        activePlayerHuds = {}
        return
    end

    local listIndex = 0
    -- Iterate through all visible players.
    for _, pid in ipairs(allPlayersOnScreen) do
        local creature = Creature(pid)
        if creature then
            local creaturePos = creature:getPosition()

            -- Check if the player is on the floor directly below us.
            if creaturePos and creaturePos.z == floorBelowZ then
                playersFoundThisTick[pid] = true
                local creatureName = creature:getName()

                -- Is this a new player we haven't seen before?
                if not activePlayerHuds[pid] then
                    -- Create a new HUD for this player.
                    local newHud = HUD.new(LIST_START_X, LIST_START_Y + (listIndex * LIST_SPACING_Y), creatureName, true)
                    newHud:setColor(TEXT_COLOR_R, TEXT_COLOR_G, TEXT_COLOR_B)
                    activePlayerHuds[pid] = newHud
                    print(">> X-Ray: Detected " .. creatureName .. " below.")
                else
                    -- If we already have a HUD, just update its Y position in the list.
                    activePlayerHuds[pid]:setPos(LIST_START_X, LIST_START_Y + (listIndex * LIST_SPACING_Y))
                end
                listIndex = listIndex + 1
            end
        end
    end

    -- Clean up: Remove HUDs for players who are no longer visible or on the wrong floor.
    for cid, hud in pairs(activePlayerHuds) do
        if not playersFoundThisTick[cid] then
            hud:destroy()
            activePlayerHuds[cid] = nil
            print(">> X-Ray: Player " .. cid .. " is no longer detected below.")
        end
    end
end


-- This function is called when the HUD icon is clicked.
local function toggleXRay()
    isXRayActive = not isXRayActive
    if isXRayActive then
        xrayToggleIcon:setOpacity(OPACITY_ON)
        print(">> X-Ray Player List ENABLED.")
    else
        xrayToggleIcon:setOpacity(OPACITY_OFF)
        print(">> X-Ray Player List DISABLED.")
        -- Destroy all active HUDs when turning the feature off.
        for cid, hud in pairs(activePlayerHuds) do
            hud:destroy()
        end
        activePlayerHuds = {}
    end
end


-- ################# SCRIPT INITIALIZATION #################
xrayToggleIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, ICON_ITEM_ID, true)

if xrayToggleIcon then
    xrayToggleIcon:setOpacity(OPACITY_OFF)
    xrayToggleIcon:setCallback(toggleXRay)

    -- Create a recurring timer that runs the main update function.
    Timer.new("XRayUpdateTimer", updateXRayList, SCAN_INTERVAL_MS, true)

    print(">> X-Ray Player List HUD loaded. Click the eye icon to toggle.")
else
    print(">> ERROR: Failed to create X-Ray Player List HUD.")
end