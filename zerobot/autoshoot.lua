-- Rune Max Toggle HUD for Zerobot
-- Creates a clickable icon to enable/disable the "Rune Max" PvP tool.

-- #################### CONFIGURATION ####################
-- Item ID for the icon. A Sudden Death Rune (3155) is a good choice.
local ICON_ITEM_ID = 3155

-- Position of the icon on the screen.
local ICON_POSITION_X = 50
local ICON_POSITION_Y = 240

-- How often to check for external changes (in milliseconds).
-- This ensures the icon updates if you change the setting manually in the bot UI.
local SYNC_INTERVAL_MS = 200

-- Opacity for the icon when ON vs OFF.
local OPACITY_ON = 1.0  -- Fully visible
local OPACITY_OFF = 0.5 -- Semi-transparent
-- ######################################################


-- This will hold our HUD object.
local runeMaxIcon = nil

-- This function updates the icon's appearance based on the bot's setting.
local function updateIconState()
    if not runeMaxIcon then return end

    if Engine.isRuneMaxEnabled() then
        -- If enabled, make the icon fully visible.
        runeMaxIcon:setOpacity(OPACITY_ON)
    else
        -- If disabled, make the icon semi-transparent.
        runeMaxIcon:setOpacity(OPACITY_OFF)
    end
end

-- This function is called when the HUD icon is clicked.
local function toggleRuneMax()
    -- Check the current state of the "Rune Max" option.
    local isCurrentlyEnabled = Engine.isRuneMaxEnabled()

    -- Set the option to the opposite of its current state.
    Engine.runeMaxEnable(not isCurrentlyEnabled)

    -- Give the engine a moment to process the change, then update the icon and print a message.
    Timer.new("UpdateRuneMaxIconDelay", function()
        updateIconState()
        if not isCurrentlyEnabled then
            print(">> Rune Max ENABLED.")
        else
            print(">> Rune Max DISABLED.")
        end
    end, 100, false) -- Runs once after 100ms
end


-- ################# SCRIPT INITIALIZATION #################

-- Create the HUD icon using the item ID and position from the config.
runeMaxIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, ICON_ITEM_ID, true)

if runeMaxIcon then
    -- Set the icon's click action to our toggle function.
    runeMaxIcon:setCallback(toggleRuneMax)

    -- Set the initial appearance of the icon when the script loads.
    updateIconState()

    -- Create a recurring timer to keep the icon's state synchronized.
    -- This handles cases where the user changes the setting manually in the UI.
    Timer.new("RuneMaxSyncTimer", updateIconState, SYNC_INTERVAL_MS, true)

    -- Print a confirmation message in the Zerobot console.
    print(">> Rune Max Toggle HUD loaded. Click the SD icon to toggle.")
else
    print(">> ERROR: Failed to create Rune Max Toggle HUD.")
end