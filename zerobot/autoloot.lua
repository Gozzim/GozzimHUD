-- Auto-Loot on Kill Toggle HUD for Zerobot
-- Creates a clickable icon to toggle an event-driven auto-looter.

-- #################### CONFIGURATION ####################
-- Item ID for the icon. A loot bag (23721).
local ICON_ITEM_ID = 23721

-- Position of the icon on the screen.
local ICON_POSITION_X = 10
local ICON_POSITION_Y = 360 -- Positioned below the other icons

-- Cooldown in milliseconds to prevent spamming the loot command for a single kill.
local LOOT_COOLDOWN_MS = 500

-- Opacity for the icon when ON vs OFF.
local OPACITY_ON = 1.0  -- Fully visible
local OPACITY_OFF = 0.5 -- Semi-transparent
-- ######################################################


-- This variable tracks whether auto-looting is active.
local isAutoLootActive = true

-- This variable tracks the last time the loot command was triggered.
local lastLootTriggerTime = 0

-- This will hold our HUD object.
local autoLootIcon = nil

-- This function is called when the HUD icon is clicked.
local function toggleAutoLoot()
    isAutoLootActive = not isAutoLootActive

    if isAutoLootActive then
        autoLootIcon:setOpacity(OPACITY_ON)
        print(">> Auto-Loot on Kill ENABLED.")
    else
        autoLootIcon:setOpacity(OPACITY_OFF)
        print(">> Auto-Loot on Kill DISABLED.")
    end
end

-- This function is the event handler for game messages.
-- It triggers the loot action when a monster's death is detected.
local function onTextMessage(messageData)
    -- Only proceed if the feature is toggled on.
    if not isAutoLootActive then return end

    -- Check if the message indicates a monster was killed (loot or experience gained).
    local messageType = messageData.messageType
    if messageType == Enums.MessageTypes.MESSAGE_LOOT or messageType == Enums.MessageTypes.MESSAGE_EXPERIENCE then

        -- Check if the cooldown has passed since the last loot trigger.
        local currentTime = os.clock() * 1000
        if currentTime - lastLootTriggerTime > LOOT_COOLDOWN_MS then
            print(">> Monster death detected. Triggering Auto-Loot.")
            -- Call Zerobot's native auto-loot function.
            Game.autoLoot()
            -- Update the last trigger time.
            lastLootTriggerTime = currentTime
        end
    end
end


-- ################# SCRIPT INITIALIZATION #################

-- Create the HUD icon using the item ID and position from the config.
autoLootIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, ICON_ITEM_ID, true)

if autoLootIcon then
    -- Set the icon's initial state to ON (fully visible).
    autoLootIcon:setOpacity(OPACITY_ON)

    -- Assign our toggle function to be called when the icon is clicked.
    autoLootIcon:setCallback(toggleAutoLoot)

    -- Register our onTextMessage function to listen for game messages.
    Game.registerEvent(Game.Events.TEXT_MESSAGE, onTextMessage)

    -- Print a confirmation message in the Zerobot console.
    print(">> Auto-Loot on Kill HUD loaded and ENABLED by default. Click the loot bag icon to toggle.")
else
    print(">> ERROR: Failed to create Auto-Loot on Kill HUD.")
end