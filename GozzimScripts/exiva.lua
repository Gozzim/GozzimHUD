-- Smart "Exiva" Script for Zerobot
-- Uses a "sticky" target system with Smart/Frenzy modes and multiple targeting methods.

-- #################### CONFIGURATION ####################
-- The spell to be cast.
local EXIVA_SPELL_WORDS = "exiva"
local EXIVA_MANA_COST = 20

-- How often the script checks conditions (in milliseconds).
local EXIVA_INTERVAL_MS = 1500

-- Item IDs for the HUD icons.
local MAIN_ICON_ID = 10302 -- A compass
local FRENZY_ICON_ID = 6546 -- Dracolas Eye

-- Text color for target
local COLOR_TARGET = { r = 200, g = 200, b = 80 }

-- Position of the icons and text display.
local MAIN_ICON_POS_X = 10
local MAIN_ICON_POS_Y = 560
local FRENZY_ICON_POS_X = 50
local FRENZY_ICON_POS_Y = 560
local TARGET_TEXT_POS_X = 10
local TARGET_TEXT_POS_Y = 590

-- Opacity for icons when ON vs OFF.
local OPACITY_ON = 1.0
local OPACITY_OFF = 0.5
-- ######################################################


-- State tracking variables
local isExivaActive = false
local isFrenzyMode = false
local currentTargetName = nil

-- HUD object variables
local exivaIcon, frenzyIcon, targetDisplayHud = nil, nil, nil

-- This event handler detects when you manually cast exiva.
local function onPlayerTalk(name, level, type, x, y, z, text)
    -- Check if the message is from our own character.
    if name:lower() == Player.getName():lower() then
        -- Check if the message is an exiva spell.
        -- ^exiva%s+\"([^\"]+)\"$  -> Matches 'exiva "Player Name"'
        local targetName = text:match("^exiva%s+\"([^\"]+)\"")
        if targetName then
            print(">> New exiva target set from manual cast: " .. targetName)
            currentTargetName = targetName
        end
    end
end

-- This function is called when the main icon is clicked.
local function toggleExiva()
    isExivaActive = not isExivaActive
    if isExivaActive then
        exivaIcon:setOpacity(OPACITY_ON)
        targetDisplayHud:show()
        print(">> Smart Exiva ENABLED.")
    else
        exivaIcon:setOpacity(OPACITY_OFF)
        targetDisplayHud:hide()
        if isFrenzyMode then
            isFrenzyMode = false
            frenzyIcon:setOpacity(OPACITY_OFF)
        end
        print(">> Smart Exiva DISABLED.")
    end
end

-- This function is called when the frenzy icon is clicked.
local function toggleFrenzy()
    if not isExivaActive then
        print(">> Enable Smart Exiva first to use Frenzy Mode.")
        return
    end
    isFrenzyMode = not isFrenzyMode
    if isFrenzyMode then
        frenzyIcon:setOpacity(OPACITY_ON)
        print(">> Exiva Frenzy Mode ENABLED.")
    else
        frenzyIcon:setOpacity(OPACITY_OFF)
        print(">> Exiva Frenzy Mode DISABLED.")
    end
end

-- This is the main logic loop, driven by a timer.
local function exivaLoop()
    -- Target acquisition is now always active, regardless of the toggle.
    local attackTargetId = Player.getTargetId()
    if attackTargetId and attackTargetId ~= 0 then
        local targetCreature = Creature(attackTargetId)
        if targetCreature then
            if targetCreature:getType() == Enums.CreatureTypes.CREATURETYPE_PLAYER then
                local name = targetCreature:getName()
                if name then
                    currentTargetName = name
                end
            end
        end
    end

    -- Update the target display HUD text.
    if targetDisplayHud then
        targetDisplayHud:setText(currentTargetName or "No Target")
    end

    -- The rest of the logic only runs if the script is toggled on.
    if not isExivaActive or not currentTargetName then
        return
    end

    -- --- SMART CHECKS ---
    if not isFrenzyMode then
        if Map.getPlayerOnScreen(currentTargetName) then
            return
        end
    end
    if Player.getMana() < EXIVA_MANA_COST then
        return
    end
    if Spells.groupIsInCooldown(Enums.SpellGroups.SPELLGROUP_SUPPORT) then
        return
    end

    -- If all checks passed, cast the spell.
    print(">> Casting exiva on '" .. currentTargetName .. "'")
    Game.talk(EXIVA_SPELL_WORDS .. " \"" .. currentTargetName .. "\"", Enums.TalkTypes.TALKTYPE_SAY)
end

local function load()
    exivaIcon = HUD.new(MAIN_ICON_POS_X, MAIN_ICON_POS_Y, MAIN_ICON_ID, true)
    frenzyIcon = HUD.new(FRENZY_ICON_POS_X, FRENZY_ICON_POS_Y, FRENZY_ICON_ID, true)
    targetDisplayHud = HUD.new(TARGET_TEXT_POS_X, TARGET_TEXT_POS_Y, "No Target", true)

    if exivaIcon and frenzyIcon and targetDisplayHud then
        targetDisplayHud:setColor(COLOR_TARGET.r, COLOR_TARGET.g, COLOR_TARGET.b)
        exivaIcon:setOpacity(OPACITY_OFF)
        frenzyIcon:setOpacity(OPACITY_OFF)
        targetDisplayHud:hide()

        exivaIcon:setCallback(toggleExiva)
        frenzyIcon:setCallback(toggleFrenzy)

        -- Register the event listener for your own chat messages.
        Game.registerEvent(Game.Events.TALK, onPlayerTalk)
        Timer.new("SmartExivaTimer", exivaLoop, EXIVA_INTERVAL_MS, true)

        print(">> Smart Exiva script loaded.")
    else
        print(">> ERROR: Failed to create Smart Exiva HUD.")
    end
end

local function unload()
    if exivaIcon then
        exivaIcon:destroy()
        exivaIcon = nil
    end
    if frenzyIcon then
        frenzyIcon:destroy()
        frenzyIcon = nil
    end
    if targetDisplayHud then
        targetDisplayHud:destroy()
        targetDisplayHud = nil
    end

    Game.unregisterEvent(Game.Events.TALK, onPlayerTalk)

    destroyTimer("SmartExivaTimer")
    print(">> Smart Exiva script unloaded.")
end

return {
    load = load,
    unload = unload
}
