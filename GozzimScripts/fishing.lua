-- Auto-Fishing Script for Zerobot
-- Worm count text color changes based on the script's active state.

-- #################### CONFIGURATION ####################
-- The time in seconds to wait after a cast before trying again.
local FISHING_TIMEOUT_SECONDS = 1

-- How often the main loop runs (in milliseconds).
local LOOP_INTERVAL_MS = 500

-- Item ID for the HUD icon.
local ICON_ITEM_ID = 3483

-- Item IDs for the fishing tools and bait.
local FISHING_ROD_ID = 3483
local WORM_ID = 3492

-- Position of the main fishing icon on the screen.
local ICON_POSITION_X = 10
local ICON_POSITION_Y = 480

-- Position for the worm count text, manually centered below the 32x32 icon.
local ICON_WIDTH = 32
local ICON_HEIGHT = 32
local COUNT_POSITION_X = (ICON_POSITION_X + ICON_WIDTH / 2) - 12
local COUNT_POSITION_Y = ICON_POSITION_Y + ICON_HEIGHT - 10

-- Opacity for the icon when ON vs OFF.
local OPACITY_ON = 1.0
local OPACITY_OFF = 0.5

-- Colors for the worm count text.
local COLOR_ACTIVE = { r = 255, g = 255, b = 255 } -- White
local COLOR_INACTIVE = { r = 150, g = 150, b = 150 } -- Grey
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
local wormCountHud = nil
local lastWormCount = -1
local fishingState = "IDLE"
local castTimestamp = 0

local function toggleFishing()
    isFishingActive = not isFishingActive
    if isFishingActive then
        fishingIcon:setOpacity(OPACITY_ON)
        if wormCountHud then
            wormCountHud:setColor(COLOR_ACTIVE.r, COLOR_ACTIVE.g, COLOR_ACTIVE.b)
        end
        print(">> Auto-Fishing ENABLED.")
        fishingState = "IDLE"
    else
        fishingIcon:setOpacity(OPACITY_OFF)
        if wormCountHud then
            wormCountHud:setColor(COLOR_INACTIVE.r, COLOR_INACTIVE.g, COLOR_INACTIVE.b)
        end
        print(">> Auto-Fishing DISABLED.")
    end
end

-- This function finds a random spot and casts the line.
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
    if not myPlayer then
        return false
    end
    local myPos = myPlayer:getPosition()
    if not myPos then
        return false
    end

    local fishableSpots = {}
    for scanX = myPos.x - 5, myPos.x + 5 do
        for scanY = myPos.y - 5, myPos.y + 5 do
            local thingsOnTile = Map.getThings(scanX, scanY, myPos.z)
            if thingsOnTile and #thingsOnTile > 0 then
                if waterTileIds[thingsOnTile[1].id] then
                    table.insert(fishableSpots, { x = scanX, y = scanY, z = myPos.z })
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
    -- Update the worm count display, regardless of whether fishing is active.
    if wormCountHud then
        local currentWormCount = Game.getItemCount(WORM_ID)
        if currentWormCount ~= lastWormCount then
            wormCountHud:setText(tostring(currentWormCount))
            lastWormCount = currentWormCount
        end
    end

    if not isFishingActive then
        return
    end

    if fishingState == "IDLE" then
        if findSpotAndCast() then
            fishingState = "WAITING"
            castTimestamp = os.clock()
        else
            toggleFishing()
        end
    elseif fishingState == "WAITING" then
        if os.clock() - castTimestamp > FISHING_TIMEOUT_SECONDS then
            print(">> Fishing timer finished. Finding new spot.")
            fishingState = "IDLE"
        end
    end
end

local function load()
    fishingIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, ICON_ITEM_ID, true)
    wormCountHud = HUD.new(COUNT_POSITION_X, COUNT_POSITION_Y, "0", true)

    if fishingIcon and wormCountHud then
        fishingIcon:setCallback(toggleFishing)
        fishingIcon:setOpacity(OPACITY_OFF)

        -- Style the worm count text and set its initial inactive color.
        wormCountHud:setColor(COLOR_INACTIVE.r, COLOR_INACTIVE.g, COLOR_INACTIVE.b)

        Timer.new("FishingMasterTimer", fishingLoop, LOOP_INTERVAL_MS, true)
        print(">> Auto-Fishing HUD loaded.")
    else
        print(">> ERROR: Failed to create Auto-Fishing HUD.")
    end
end

local function unload()
    if fishingIcon then
        fishingIcon:destroy()
        fishingIcon = nil
    end
    if wormCountHud then
        wormCountHud:destroy()
        wormCountHud = nil
    end
    destroyTimer("FishingMasterTimer")
    print(">> Auto-Fishing HUD unloaded.")
end

return {
    load = load,
    unload = unload
}
