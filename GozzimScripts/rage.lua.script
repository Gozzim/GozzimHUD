-- Auto "Utito Tempo" Script for Zerobot
-- Casts the spell only when conditions are safe and effective.

-- #################### CONFIGURATION ####################
-- The spell to be cast.
local UTITO_SPELL_WORDS = "utito tempo"
local UTITO_MANA_COST = 290

-- Minimum number of monsters on screen to justify using the spell.
local MIN_MONSTERS_TO_CAST = 2

-- Minimum health percentage required to safely cast the spell.
local MIN_HP_PERCENT_TO_CAST = 85

-- How often the script checks conditions (in milliseconds).
local CHECK_INTERVAL_MS = 500

-- Item ID for the HUD icon. A berserk potion (7439) is a good visual.
local ICON_ITEM_ID = 7439

-- Position of the icon on the screen.
local ICON_POSITION_X = 50
local ICON_POSITION_Y = 240

-- Opacity for the icon when ON vs OFF.
local OPACITY_ON = 1.0  -- Fully visible
local OPACITY_OFF = 0.5 -- Semi-transparent
-- ######################################################


-- State tracking variables
local isAutoUtitoActive = false
local autoUtitoIcon = nil

-- This function is called when the HUD icon is clicked.
local function toggleAutoUtito()
    isAutoUtitoActive = not isAutoUtitoActive
    if isAutoUtitoActive then
        autoUtitoIcon:setOpacity(OPACITY_ON)
        print(">> Auto 'Utito Tempo' ENABLED.")
    else
        autoUtitoIcon:setOpacity(OPACITY_OFF)
        print(">> Auto 'Utito Tempo' DISABLED.")
    end
end

-- This is the main logic function, running on a timer.
local function castUtitoIfNeeded()
    -- Only run if the feature is toggled on and the player is in the game.
    if not isAutoUtitoActive or not Client.isConnected() then
        return
    end

    -- 1. --- SAFETY CHECKS --- (Conditions that PREVENT casting)
    if Player.getState(Enums.States.STATE_PARTY_BUFF) then
        return
    end
    -- Check if health is too low.
    if Player.getHealthPercent() < MIN_HP_PERCENT_TO_CAST then
        return
    end
    -- Check if in a Protection Zone.
    if Player.getState(Enums.States.STATE_PIGEON) then
        return
    end

    local monsterCount = 0
    local isPlayerThreatNearby = false
    local allCreatures = Map.getCreatureIds(true, false) -- Get all creatures on our floor.

    if allCreatures then
        for _, cid in ipairs(allCreatures) do
            local creature = Creature(cid)
            if creature then
                local creatureType = creature:getType()
                -- Check for dangerous players (non-party members with a skull).
                if creatureType == Enums.CreatureTypes.CREATURETYPE_PLAYER and creature:getPartyIcon() == Enums.PartyIcons.SHIELD_NONE then
                    if creature:getSkull() ~= Enums.Skulls.SKULL_NONE then
                        isPlayerThreatNearby = true
                        break -- Found a threat, no need to check further.
                    end
                    -- Count the number of monsters.
                elseif creatureType == Enums.CreatureTypes.CREATURETYPE_MONSTER then
                    monsterCount = monsterCount + 1
                end
            end
        end
    end

    -- If a skulled player is on screen, do not cast.
    if isPlayerThreatNearby then
        print(">> Auto 'Utito Tempo': Player threat detected. Not casting.")
        return
    end

    -- 2. --- EFFICIENCY CHECKS --- (Conditions REQUIRED for casting)
    -- Check if there are enough monsters nearby.
    if monsterCount < MIN_MONSTERS_TO_CAST then
        return
    end
    -- Check for sufficient mana.
    if Player.getMana() < UTITO_MANA_COST then
        return
    end
    -- Check if the support spell group is on cooldown.
    if Spells.groupIsInCooldown(Enums.SpellGroups.SPELLGROUP_SUPPORT) then
        return
    end

    -- 3. --- ACTION ---
    -- If all checks passed, cast the spell.
    print(">> Conditions met. Casting 'utito tempo'.")
    Game.talk(UTITO_SPELL_WORDS, Enums.TalkTypes.TALKTYPE_SAY)
end

local function load()
    autoUtitoIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, ICON_ITEM_ID, true)

    if autoUtitoIcon then
        autoUtitoIcon:setOpacity(OPACITY_OFF)
        autoUtitoIcon:setCallback(toggleAutoUtito)

        -- Create a recurring timer that runs the main logic loop.
        Timer.new("AutoUtitoTimer", castUtitoIfNeeded, CHECK_INTERVAL_MS, true)

        print(">> Auto 'Utito Tempo' HUD loaded.")
    else
        print(">> ERROR: Failed to create Auto 'Utito Tempo' HUD.")
    end
end

local function unload()
    if autoUtitoIcon then
        autoUtitoIcon:destroy()
        autoUtitoIcon = nil
    end
    destroyTimer("AutoUtitoTimer")
    print(">> Auto 'Utito Tempo' HUD unloaded.")
end

return {
    load = load,
    unload = unload
}
