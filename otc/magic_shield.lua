local config = {
    -- Healing Settings
    healing = {
        enabled = true,
        spell = "exana vita",
        manaCost = 40,
        maxHealthPercent = 80
    },

    -- Magic Shield Settings
    magicShield = {
        enabled = true,
        spell = "utamo vita",
        manaCost = 50,
        triggerHealthPercent = 70
    }
}

macro(100, "Auto Healer & Shield", function()
    if not g_game.isOnline() then
        return
    end

    local player = g_game.getLocalPlayer()
    local playerHealthPercent = player:getHealthPercent()
    local playerMana = player:getMana()

    if config.magicShield.enabled and playerHealthPercent <= config.magicShield.triggerHealthPercent then
        if not player:hasCondition(ConditionMagicShield) and playerMana >= config.magicShield.manaCost then
            say(config.magicShield.spell)
            return
        end
    end

    if config.healing.enabled and playerHealthPercent <= config.healing.maxHealthPercent then
        if playerMana >= config.healing.manaCost then
            say(config.healing.spell)
        end
    end
end)