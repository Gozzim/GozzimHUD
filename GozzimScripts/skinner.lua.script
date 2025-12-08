-- Auto-Skinner Toggle HUD for Zerobot
-- Automatically skins nearby corpses with the correct tool when toggled on.

-- #################### CONFIGURATION ####################
-- Item ID for the HUD icon. An obsidian knife is a good choice.
local ICON_ITEM_ID = 5908

-- Item IDs for the skinning tools
local OBSIDIAN_KNIFE_ID = 5908
local BLESSED_STAKE_ID = 5942

-- Position of the icon on the screen.
local ICON_POSITION_X = 10
local ICON_POSITION_Y = 400

-- Cooldown in milliseconds after a kill before scanning for corpses.
-- This gives the game time to render the corpse and prevents spam.
local SKIN_SCAN_DELAY_MS = 500
local SKIN_COOLDOWN_MS = 1000 -- Cooldown between skinning attempts

-- Opacity for the icon when ON vs OFF.
local OPACITY_ON = 1.0  -- Fully visible
local OPACITY_OFF = 0.5 -- Semi-transparent
-- ######################################################


-- Convert the body ID arrays into sets for faster lookups
local knifeBodies = { [4286] = true, [4272] = true, [4173] = true, [4011] = true, [4025] = true, [4047] = true, [4052] = true, [4057] = true, [4062] = true, [4112] = true, [4212] = true, [4321] = true, [4324] = true, [4327] = true, [10352] = true, [10356] = true, [10360] = true, [10364] = true }
local stakeBodies = { [4097] = true, [4137] = true, [8738] = true, [18958] = true }

-- State tracking variables
local isAutoSkinActive = false
local lastSkinAttemptTime = 0
local autoSkinIcon = nil

-- This function is called when the HUD icon is clicked.
local function toggleAutoSkin()
    isAutoSkinActive = not isAutoSkinActive
    if isAutoSkinActive then
        autoSkinIcon:setOpacity(OPACITY_ON)
        print(">> Auto-Skinner ENABLED.")
    else
        autoSkinIcon:setOpacity(OPACITY_OFF)
        print(">> Auto-Skinner DISABLED.")
    end
end

-- This is the main logic function that finds and skins a corpse.
local function skinNearbyCorpse()
    -- Check for tools first to be efficient.
    local hasKnife = Game.getItemCount(OBSIDIAN_KNIFE_ID) > 0
    local hasStake = Game.getItemCount(BLESSED_STAKE_ID) > 0

    if not hasKnife and not hasStake then
        print(">> Auto-Skinner: No skinning tools found.")
        return
    end

    -- Get all tiles on the screen.
    local tiles = Map.getTiles()
    if not tiles then
        return
    end

    -- Iterate through every tile and every item on each tile.
    for _, tile in ipairs(tiles) do
        if tile.things then
            for _, thing in ipairs(tile.things) do
                local toolToUse = nil
                -- Check if the item is a corpse that needs a knife.
                if hasKnife and knifeBodies[thing.id] then
                    toolToUse = OBSIDIAN_KNIFE_ID
                    -- Check if the item is a corpse that needs a stake.
                elseif hasStake and stakeBodies[thing.id] then
                    toolToUse = BLESSED_STAKE_ID
                end

                -- If we found a skinnable corpse and have the right tool
                if toolToUse then
                    print(">> Found skinnable corpse (ID: " .. thing.id .. "). Attempting to use tool (ID: " .. toolToUse .. ").")
                    -- Use the tool on the corpse's location.
                    Game.useItemOnGround(toolToUse, tile.x, tile.y, tile.z)
                    -- Return immediately to only skin one corpse per trigger.
                    return
                end
            end
        end
    end
end

-- This function listens for game messages to detect a kill.
local function onTextMessage(messageData)
    if not isAutoSkinActive then
        return
    end

    local messageType = messageData.messageType
    if messageType == Enums.MessageTypes.MESSAGE_LOOT or messageType == Enums.MessageTypes.MESSAGE_EXPERIENCE then
        local currentTime = os.clock() * 1000
        if currentTime - lastSkinAttemptTime > SKIN_COOLDOWN_MS then
            lastSkinAttemptTime = currentTime
            -- Use a delayed, single-run timer to scan for the corpse.
            Timer.new("SkinScanTimer", skinNearbyCorpse, SKIN_SCAN_DELAY_MS, false)
        end
    end
end

local function load()
    autoSkinIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, ICON_ITEM_ID, true)

    if autoSkinIcon then
        autoSkinIcon:setOpacity(OPACITY_OFF)
        autoSkinIcon:setCallback(toggleAutoSkin)

        -- Register the event listener for monster kills.
        Game.registerEvent(Game.Events.TEXT_MESSAGE, onTextMessage)

        print(">> Auto-Skinner HUD loaded.")
    else
        print(">> ERROR: Failed to create Auto-Skinner HUD.")
    end
end

local function unload()
    if autoSkinIcon then
        autoSkinIcon:destroy()
        autoSkinIcon = nil
    end
    Game.unregisterEvent(Game.Events.TEXT_MESSAGE, onTextMessage)
    -- Although it's a one-shot timer, it's good practice to clean it up
    -- in case the script is unloaded before the timer fires.
    destroyTimer("SkinScanTimer")
    print(">> Auto-Skinner HUD unloaded.")
end

return {
    load = load,
    unload = unload
}
