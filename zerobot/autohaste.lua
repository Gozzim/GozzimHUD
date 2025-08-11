-- Vocation-Aware Haste Toggle HUD for Zerobot
-- Creates a clickable icon that automatically selects the correct haste spell.

-- #################### CONFIGURATION ####################
-- Haste spell for Knights and Paladins
local DEFAULT_HASTE_SPELL = "utani hur"
local DEFAULT_MANA_COST = 20

-- Haste spell for Sorcerers and Druids
local STRONG_HASTE_SPELL = "utani gran hur"
local STRONG_MANA_COST = 100

-- How often the script checks to recast haste (in milliseconds).
local RECAST_INTERVAL_MS = 500

-- Item ID for the icon. Boots of Haste (3079) is a good choice.
local ICON_ITEM_ID = 3079

-- Position of the icon on the screen.
local ICON_POSITION_X = 10
local ICON_POSITION_Y = 200

-- Opacity for the icon when ON vs OFF.
local OPACITY_ON = 1.0  -- Fully visible
local OPACITY_OFF = 0.5 -- Semi-transparent
-- ######################################################


-- This variable tracks whether the auto-haste is active.
local isAutoHasteActive = false

-- This will hold our HUD object.
local hasteIcon = nil

-- This function is called when the HUD icon is clicked.
local function toggleHaste()
    -- Flip the active state.
    isAutoHasteActive = not isAutoHasteActive

    if isAutoHasteActive then
        -- Set icon to fully visible and print a message.
        hasteIcon:setOpacity(OPACITY_ON) --
        print(">> Auto-Haste ENABLED.") --
    else
        -- Set icon to semi-transparent and print a message.
        hasteIcon:setOpacity(OPACITY_OFF) --
        print(">> Auto-Haste DISABLED.") --
    end
end

-- This function is run by the timer to check if we need to cast haste.
local function castHasteIfNeeded()
    -- Only proceed if auto-haste is enabled and the client is connected.
    if not isAutoHasteActive or not Client.isConnected() then --
        return
    end

    -- ## Vocation Check: Get the player's creature object to find the vocation ##
    local playerCreature = Creature(Player.getId()) --
    local currentVocation = playerCreature:getVocation() --

    local spellToCast = DEFAULT_HASTE_SPELL
    local manaCostForSpell = DEFAULT_MANA_COST

    -- Set the correct spell based on vocation enum.
    if currentVocation == Enums.Vocations.SORCERER or currentVocation == Enums.Vocations.DRUID then --
        spellToCast = STRONG_HASTE_SPELL
        manaCostForSpell = STRONG_MANA_COST
    end

    -- Check all conditions before casting.
    local canCast = true
    if Player.getState(Enums.States.STATE_HASTE) then --
        canCast = false -- Already hasted.
    elseif Player.getMana() < manaCostForSpell then --
        canCast = false -- Not enough mana.
    elseif Spells.groupIsInCooldown(Enums.SpellGroups.SPELLGROUP_SUPPORT) then --
        canCast = false -- A support spell (like haste) is on cooldown.
    end

    -- If all checks passed, cast the spell.
    if canCast then
        Game.talk(spellToCast, Enums.TalkTypes.TALKTYPE_SAY) --
    end
end

-- ################# SCRIPT INITIALIZATION #################

-- Create the HUD icon using the item ID and position from the config.
-- The 'true' argument enables new features like opacity and click handling.
hasteIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, ICON_ITEM_ID, true) --

if hasteIcon then
    -- Set the icon's initial state to OFF (semi-transparent).
    hasteIcon:setOpacity(OPACITY_OFF) --

    -- Assign our toggleHaste function to be called when the icon is clicked.
    hasteIcon:setCallback(toggleHaste) --

    -- Create a recurring timer that calls castHasteIfNeeded.
    Timer.new("HasteTimer", castHasteIfNeeded, RECAST_INTERVAL_MS, true) --

    -- Print a confirmation message in the Zerobot console.
    print(">> Vocation-Aware Haste HUD loaded. Click the boots icon to toggle.") --
else
    print(">> ERROR: Failed to create Haste Toggle HUD.") --
end