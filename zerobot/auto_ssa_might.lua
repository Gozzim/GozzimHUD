-- Auto SSA & Might Ring HUD Toggles for Zerobot
-- Creates three icons to control Auto SSA and Auto Might Ring.

-- #################### CONFIGURATION ####################
-- Item IDs for the HUD icons.
local COMBINED_ICON_ID = 7532 -- Koshei's Ancient Amulet, representing both
local SSA_ONLY_ICON_ID = 3081   -- Stone Skin Amulet
local RING_ONLY_ICON_ID = 3048  -- Might Ring

-- Position for the row of icons. Y=280 is below the default Hold Target icon (Y=240).
local ICON_ROW_Y = 280
local ICON_1_X = 10 -- Combined
local ICON_2_X = 50 -- SSA Only
local ICON_3_X = 90 -- Ring Only

-- How often to check for external changes (in milliseconds).
local SYNC_INTERVAL_MS = 200

-- Opacity for the icon when ON vs OFF.
local OPACITY_ON = 1.0
local OPACITY_OFF = 0.5
-- ######################################################


-- State tracking variables for the HUD objects
local combinedIcon, ssaIcon, mightRingIcon = nil, nil, nil

-- This single function updates the appearance of all three icons.
local function updateAllIconStates()
    if not combinedIcon then return end -- Check if icons have been created

    local isSsaEnabled = Engine.isAutoSSAEnabled() --
    local isMightRingEnabled = Engine.isAutoMightRingEnabled() --

    -- Update Combined Icon: On only if BOTH are enabled.
    if isSsaEnabled and isMightRingEnabled then
        combinedIcon:setOpacity(OPACITY_ON) --
    else
        combinedIcon:setOpacity(OPACITY_OFF) --
    end

    -- Update SSA Only Icon
    if isSsaEnabled then
        ssaIcon:setOpacity(OPACITY_ON) --
    else
        ssaIcon:setOpacity(OPACITY_OFF) --
    end

    -- Update Ring Only Icon
    if isMightRingEnabled then
        mightRingIcon:setOpacity(OPACITY_ON) --
    else
        mightRingIcon:setOpacity(OPACITY_OFF) --
    end
end

-- Toggle function for the COMBINED icon.
local function toggleCombined()
    local isSsaEnabled = Engine.isAutoSSAEnabled() --
    local isMightRingEnabled = Engine.isAutoMightRingEnabled() --
    -- New state: if they aren't both on, turn them both on. If they are both on, turn them both off.
    local newState = not (isSsaEnabled and isMightRingEnabled)

    Engine.autoSSAEnable(newState) --
    Engine.autoMightRingEnable(newState) --

    Timer.new("UpdateCombinedDelay", function()
        updateAllIconStates()
        if newState then
            print(">> Auto SSA & Might Ring ENABLED.")
        else
            print(">> Auto SSA & Might Ring DISABLED.")
        end
    end, 100, false) --
end

-- Toggle function for the SSA ONLY icon.
local function toggleSsaOnly()
    local isCurrentlyEnabled = Engine.isAutoSSAEnabled() --
    Engine.autoSSAEnable(not isCurrentlyEnabled) --

    Timer.new("UpdateSsaDelay", function()
        updateAllIconStates()
        if not isCurrentlyEnabled then
            print(">> Auto SSA ENABLED.")
        else
            print(">> Auto SSA DISABLED.")
        end
    end, 100, false) --
end

-- Toggle function for the RING ONLY icon.
local function toggleMightRingOnly()
    local isCurrentlyEnabled = Engine.isAutoMightRingEnabled() --
    Engine.autoMightRingEnable(not isCurrentlyEnabled) --

    Timer.new("UpdateRingDelay", function()
        updateAllIconStates()
        if not isCurrentlyEnabled then
            print(">> Auto Might Ring ENABLED.")
        else
            print(">> Auto Might Ring DISABLED.")
        end
    end, 100, false) --
end

-- ################# SCRIPT INITIALIZATION #################

-- Create the three HUD icons.
combinedIcon = HUD.new(ICON_1_X, ICON_ROW_Y, COMBINED_ICON_ID, true) --
ssaIcon = HUD.new(ICON_2_X, ICON_ROW_Y, SSA_ONLY_ICON_ID, true) --
mightRingIcon = HUD.new(ICON_3_X, ICON_ROW_Y, RING_ONLY_ICON_ID, true) --

if combinedIcon and ssaIcon and mightRingIcon then
    -- Assign the correct callback function to each icon.
    combinedIcon:setCallback(toggleCombined) --
    ssaIcon:setCallback(toggleSsaOnly) --
    mightRingIcon:setCallback(toggleMightRingOnly) --

    -- Set the initial appearance of all icons.
    updateAllIconStates()

    -- Create a single recurring timer to keep all icons synchronized.
    Timer.new("DefensiveSyncTimer", updateAllIconStates, SYNC_INTERVAL_MS, true) --

    print(">> Defensive Toggles HUD loaded.")
else
    print(">> ERROR: Failed to create Defensive Toggles HUD.")
end