-- Anti-Push Toggle HUD for Zerobot
-- Creates a clickable icon to enable/disable the "Anti-Push" PvP tool.

-- #################### CONFIGURATION ####################
-- Item ID for the icon.
local ICON_ITEM_ID = 9104

-- Position of the icon on the screen.
local ICON_POSITION_X = 10
local ICON_POSITION_Y = 520

-- How often to check for external changes (in milliseconds).
-- This ensures the icon updates if you change the setting manually in the bot UI.
local SYNC_INTERVAL_MS = 1000

-- Opacity for the icon when ON vs OFF.
local OPACITY_ON = 1.0  -- Fully visible
local OPACITY_OFF = 0.5 -- Semi-transparent
-- ######################################################


-- This will hold our HUD object.
local antiPushIcon = nil

-- This function updates the icon's appearance based on the bot's setting.
local function updateIconState()
    if not antiPushIcon then
        return
    end

    if Engine.isAntiPushEnabled() then
        -- If enabled, make the icon fully visible.
        antiPushIcon:setOpacity(OPACITY_ON)
    else
        -- If disabled, make the icon semi-transparent.
        antiPushIcon:setOpacity(OPACITY_OFF)
    end
end

-- This function is called when the HUD icon is clicked.
local function toggleAntiPush()
    -- Check the current state of the "Anti-Push" option.
    local isCurrentlyEnabled = Engine.isAntiPushEnabled()

    -- Set the option to the opposite of its current state.
    Engine.antiPushEnable(not isCurrentlyEnabled)

    -- Give the engine a moment to process the change, then update the icon and print a message.
    Timer.new("UpdateAntiPushIconDelay", function()
        updateIconState()
        if not isCurrentlyEnabled then
            print(">> Anti-Push ENABLED.")
        else
            print(">> Anti-Push DISABLED.")
        end
    end, 100, false) -- Runs once after 100ms
end

local function load()
    -- Create the HUD icon using the item ID and position from the config.
    antiPushIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, ICON_ITEM_ID, true)

    if antiPushIcon then
        -- Set the icon's click action to our toggle function.
        antiPushIcon:setCallback(toggleAntiPush)

        -- Set the initial appearance of the icon when the script loads.
        updateIconState()

        -- Create a recurring timer to keep the icon's state synchronized.
        Timer.new("AntiPushSyncTimer", updateIconState, SYNC_INTERVAL_MS, true)

        -- Print a confirmation message in the Zerobot console.
        print(">> Anti-Push Toggle HUD loaded. Click the magic wall icon to toggle.")
    else
        print(">> ERROR: Failed to create Anti-Push Toggle HUD.")
    end
end

local function unload()
    if antiPushIcon then
        antiPushIcon:destroy()
        antiPushIcon = nil
    end
    destroyTimer("AntiPushSyncTimer")
    print(">> Anti-Push Toggle HUD unloaded.")
end

return {
    load = load,
    unload = unload
}
