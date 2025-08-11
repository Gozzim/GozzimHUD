-- Auto-Fishing Script for Zerobot (State Machine Version)
-- Uses a reliable timer-based state machine that cannot get stuck.

-- #################### CONFIGURATION ####################
-- The time in seconds to wait after a cast before trying again.
-- This should be a few seconds longer than a typical fishing attempt.
local FISHING_TIMEOUT_SECONDS = 1

-- How often the main loop runs (in milliseconds).
local LOOP_INTERVAL_MS = 500

-- Item ID for the HUD icon.
local ICON_ITEM_ID = 3483

-- Item IDs for the fishing tools and bait.
local FISHING_ROD_ID = 3483
local WORM_ID = 3492

-- Position of the icon on the screen.
local ICON_POSITION_X = 10
local ICON_POSITION_Y = 480

-- How far from the player to scan for water tiles.
local MAX_FISHING_DISTANCE = 6

-- Opacity for the icon when ON vs OFF.
local OPACITY_ON = 1.0
local OPACITY_OFF = 0.5
-- ######################################################

-- A set of known water tile IDs for fast checking.
local waterTileIds = {
    [629] = true, [4597] = true, [4598] = true, [4599] = true, [4600] = true,
    [4601] = true, [4602] = true, [4609] = true, [4610] = true, [4611] = true,
    [4612] = true, [4613] = true, [4614] = true
}

-- State tracking variables
local isFishingActive = false
local fishingIcon = nil
local fishingState = "IDLE" -- Can be "IDLE" or "WAITING"
local castTimestamp = 0

-- This function finds a random spot and casts the line.
-- It returns true on success, false on failure.
local function findSpotAndCast()
    if Game.getItemCount(FISHING_ROD_ID) == 0 then
        print(">> Auto-Fishing: No fishing rod found.")
        return false
    end
    if Game.getItemCount(WORM_ID) == 0 then
        print(">> Auto-Fishing: Out of worms!")
        return false
    end

    local myPlayer = Creature(Player.getId())
    if not myPlayer then return false end
    local myPos = myPlayer:getPosition()
    if not myPos then return false end

    local fishableSpots = {}
    for scanX = myPos.x - MAX_FISHING_DISTANCE, myPos.x + MAX_FISHING_DISTANCE do
        for scanY = myPos.y - MAX_FISHING_DISTANCE, myPos.y + MAX_FISHING_DISTANCE do
            local thingsOnTile = Map.getThings(scanX, scanY, myPos.z)
            if thingsOnTile and #thingsOnTile > 0 then
                if waterTileIds[thingsOnTile[1].id] then
                    table.insert(fishableSpots, {x = scanX, y = scanY, z = myPos.z})
                end
            end
        end
    end

    if #fishableSpots > 0 then
        local targetSpot = fishableSpots[math.random(#fishableSpots)]
        print(">> Casting at X: " .. targetSpot.x .. ", Y: " .. targetSpot.y)
        Game.useItemOnGround(FISHING_ROD_ID, targetSpot.x, targetSpot.y, targetSpot.z)
        return true -- Successfully cast
    else
        print(">> No fishable water spots found on screen.")
        return false -- Failed to find a spot
    end
end

-- This is the main loop, driven by a timer.
local function fishingLoop()
    if not isFishingActive then return end

    if fishingState == "IDLE" then
        -- Try to cast.
        if findSpotAndCast() then
            -- If successful, enter the WAITING state.
            fishingState = "WAITING"
            castTimestamp = os.clock()
        else
            -- If we failed (e.g., no worms), disable the script.
            toggleFishing()
        end
    elseif fishingState == "WAITING" then
        -- Check if the timeout has passed.
        if os.clock() - castTimestamp > FISHING_TIMEOUT_SECONDS then
            print(">> Fishing timer finished. Finding new spot...")
            -- Reset to IDLE to trigger a new cast on the next loop.
            fishingState = "IDLE"
        end
    end
end

-- This function is called when the HUD icon is clicked.
toggleFishing = function()
    isFishingActive = not isFishingActive
    if isFishingActive then
        fishingIcon:setOpacity(OPACITY_ON)
        print(">> Auto-Fishing ENABLED.")
        -- Reset state to ensure it starts fresh.
        fishingState = "IDLE"
    else
        fishingIcon:setOpacity(OPACITY_OFF)
        print(">> Auto-Fishing DISABLED.")
    end
end

-- ################# SCRIPT INITIALIZATION #################

fishingIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, ICON_ITEM_ID, true)

if fishingIcon then
    fishingIcon:setOpacity(OPACITY_OFF)
    fishingIcon:setCallback(toggleFishing)
    -- This single timer now controls the entire script's logic.
    Timer.new("FishingMasterTimer", fishingLoop, LOOP_INTERVAL_MS, true)
    print(">> Auto-Fishing HUD (Reliable Version) loaded.")
else
    print(">> ERROR: Failed to create Auto-Fishing HUD.")
end