-- Rune Max Toggle HUD for Zerobot (Dynamic Icon)
-- Automatically uses the icon of the rune set in the ZeroBot Rune Max configuration.

-- #################### CONFIGURATION ####################
-- Position of the icon on the screen.
local ICON_POSITION_X = 50
local ICON_POSITION_Y = 240

-- How often to check for external changes (in milliseconds).
-- This ensures the icon updates if you change the setting manually in the bot UI.
local SYNC_INTERVAL_MS = 200

-- Opacity for the icon when ON vs OFF.
local OPACITY_ON = 1.0
local OPACITY_OFF = 0.5
-- ######################################################


-- State tracking variables
local runeMaxIcon = nil
local currentIconId = 0 -- This will track the item ID currently shown on the HUD.

-- This function now updates both the icon's appearance (item) and its state (opacity).
local function updateIconState()
    if not runeMaxIcon then return end

    -- Get the rune ID currently configured in ZeroBot's Rune Max tool.
    local configuredRuneId = Engine.getRuneMaxId() --

    -- If the configured rune is different from our current icon, update the icon.
    if configuredRuneId ~= 0 and configuredRuneId ~= currentIconId then
        runeMaxIcon:setItemId(configuredRuneId) --
        currentIconId = configuredRuneId
        print(">> Rune Max icon updated to item ID: " .. configuredRuneId)
    end

    -- Update the icon's opacity based on whether the feature is enabled.
    if Engine.isRuneMaxEnabled() then --
        runeMaxIcon:setOpacity(OPACITY_ON) --
    else
        runeMaxIcon:setOpacity(OPACITY_OFF) --
    end
end

-- This function is called when the HUD icon is clicked.
local function toggleRuneMax()
    local isCurrentlyEnabled = Engine.isRuneMaxEnabled() --
    Engine.runeMaxEnable(not isCurrentlyEnabled) --

    Timer.new("UpdateRuneMaxIconDelay", function()
        updateIconState()
        if not isCurrentlyEnabled then
            print(">> Rune Max ENABLED.")
        else
            print(">> Rune Max DISABLED.")
        end
    end, 100, false) --
end


-- ################# SCRIPT INITIALIZATION #################

-- Get the initial rune ID to create the icon for the first time.
local initialRuneId = Engine.getRuneMaxId() --
if initialRuneId == 0 then
    -- Default to an SD rune if no rune is configured yet.
    initialRuneId = 3155
    print(">> Rune Max: No rune configured. Defaulting to SD icon.")
end
currentIconId = initialRuneId

runeMaxIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, currentIconId, true) --

if runeMaxIcon then
    runeMaxIcon:setCallback(toggleRuneMax) --
    updateIconState() -- Set the initial appearance and state.
    Timer.new("RuneMaxSyncTimer", updateIconState, SYNC_INTERVAL_MS, true) --

    print(">> Dynamic Rune Max Toggle HUD loaded. Icon will match your configuration.")
else
    print(">> ERROR: Failed to create Dynamic Rune Max Toggle HUD.")
end