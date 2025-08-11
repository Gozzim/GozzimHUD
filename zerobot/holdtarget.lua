-- Hold Target Toggle HUD for Zerobot
-- Creates a clickable icon to enable/disable the "Hold Target" PvP tool.

-- #################### CONFIGURATION ####################
-- Item ID for the icon. A crossbow (3349) is a good visual.
local ICON_ITEM_ID = 3349

-- Position of the icon on the screen.
local ICON_POSITION_X = 10
local ICON_POSITION_Y = 240 -- Positioned below the haste icon from the previous script

-- How often to check for external changes (in milliseconds).
-- This ensures the icon updates if you change the setting manually in the bot UI.
local SYNC_INTERVAL_MS = 200

-- Opacity for the icon when ON vs OFF.
local OPACITY_ON = 1.0  -- Fully visible
local OPACITY_OFF = 0.5 -- Semi-transparent
-- ######################################################


-- This will hold our HUD object.
local holdTargetIcon = nil

-- This function updates the icon's appearance based on the bot's setting.
local function updateIconState()
    if not holdTargetIcon then return end

    if Engine.isHoldTargetEnabled() then
        -- If enabled, make the icon fully visible.
        holdTargetIcon:setOpacity(OPACITY_ON)
    else
        -- If disabled, make the icon semi-transparent.
        holdTargetIcon:setOpacity(OPACITY_OFF)
    end
end

-- This function is called when the HUD icon is clicked.
local function toggleHoldTarget()
    -- Check the current state of the "Hold Target" option.
    local isCurrentlyEnabled = Engine.isHoldTargetEnabled()

    -- Set the option to the opposite of its current state.
    Engine.holdTargetEnable(not isCurrentlyEnabled)

    -- Give the engine a moment to process the change, then update the icon.
    Timer.new("UpdateHoldTargetIconDelay", function()
        updateIconState()
        if not isCurrentlyEnabled then
            print(">> Hold Target ENABLED.")
        else
            print(">> Hold Target DISABLED.")
        end
    end, 100, false) -- Runs once after 100ms
end


-- ################# SCRIPT INITIALIZATION #################

-- Create the HUD icon using the item ID and position from the config.
holdTargetIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, ICON_ITEM_ID, true)

if holdTargetIcon then
    -- Set the icon's click action to our toggle function.
    holdTargetIcon:setCallback(toggleHoldTarget)

    -- Set the initial appearance of the icon when the script loads.
    updateIconState()

    -- Create a recurring timer to keep the icon's state synchronized.
    -- This handles cases where the user changes the setting manually in the UI.
    Timer.new("HoldTargetSyncTimer", updateIconState, SYNC_INTERVAL_MS, true)

    -- Print a confirmation message in the Zerobot console.
    print(">> Hold Target Toggle HUD loaded. Click the crossbow icon to toggle.")
else
    print(">> ERROR: Failed to create Hold Target Toggle HUD.")
end