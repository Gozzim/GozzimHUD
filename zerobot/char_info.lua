-- Advanced Player List Script for Zerobot (Final Alignment)
-- Corrects spacing and icon size to match the user's reference image.

-- #################### CONFIGURATION ####################
-- Position for the list on the right side of the screen.
local LIST_MARGIN_X = -10
local LIST_START_Y = 20

-- Vertical spacing between names in the list.
local LIST_SPACING_Y = 20

-- The scale of the skull icons. Reduced for a cleaner look.
local SKULL_ICON_SCALE = 0.5

-- How often the script scans for players (in milliseconds).
local SCAN_INTERVAL_MS = 500

-- Color definitions for different player states (R, G, B).
local COLORS = {
    RED_SKULL = {r=255, g=50, b=50},
    WHITE_SKULL = {r=255, g=150, b=0},
    ENEMY = {r=180, g=0, b=0},
    GUILD = {r=0, g=200, b=0},
    PARTY = {r=100, g=150, b=255},
    NORMAL = {r=255, g=255, b=255}
}
-- ######################################################


-- Helper maps
local vocationMap = {
    [Enums.Vocations.KNIGHT]   = "EK", [Enums.Vocations.PALADIN]  = "RP",
    [Enums.Vocations.SORCERER] = "MS", [Enums.Vocations.DRUID]    = "ED",
    [Enums.Vocations.MONK]     = "MK", [Enums.Vocations.NONE]     = "?"
}
local skullIconMap = {
    [Enums.Skulls.SKULL_YELLOW] = 37339, [Enums.Skulls.SKULL_GREEN] = 37341,
    [Enums.Skulls.SKULL_WHITE]  = 37337, [Enums.Skulls.SKULL_RED]   = 37338,
    [Enums.Skulls.SKULL_BLACK]  = 37335, [Enums.Skulls.SKULL_ORANGE] = 37340
}

-- Table to store active HUDs for each player.
local activePlayerHuds = {}

-- The main loop to update the player list.
local function updatePlayerList()
    if not Client.isConnected() then return end

    local playersFoundThisTick = {}
    local playerList = {}
    local myId = Player.getId() --

    local allCreatures = Map.getCreatureIds(false, false) --
    if allCreatures then
        for _, cid in ipairs(allCreatures) do
            if cid ~= myId then
                local creature = Creature(cid) --
                if creature and creature:getType() == Enums.CreatureTypes.CREATURETYPE_PLAYER then --
                    table.insert(playerList, {
                        cid = cid, name = creature:getName(), vocationId = creature:getVocation(),
                        skullId = creature:getSkull(), partyIconId = creature:getPartyIcon(), guildEmblemId = creature:getGuildEmblem()
                    })
                end
            end
        end
    end

    -- Sort the list of players based on priority.
    table.sort(playerList, function(a, b)
        local priorityA, priorityB = 5, 5
        if a.skullId ~= Enums.Skulls.SKULL_NONE then priorityA = 1 end
        if b.skullId ~= Enums.Skulls.SKULL_NONE then priorityB = 1 end
        if a.guildEmblemId == Enums.GuildEmblem.GUILDEMBLEM_ENEMY then priorityA = 2 end
        if b.guildEmblemId == Enums.GuildEmblem.GUILDEMBLEM_ENEMY then priorityB = 2 end
        if a.guildEmblemId == Enums.GuildEmblem.GUILDEMBLEM_MEMBER then priorityA = 3 end
        if b.guildEmblemId == Enums.GuildEmblem.GUILDEMBLEM_MEMBER then priorityB = 3 end
        if a.partyIconId ~= Enums.PartyIcons.SHIELD_NONE and a.partyIconId ~= Enums.PartyIcons.SHIELD_GRAY then priorityA = 4 end
        if b.partyIconId ~= Enums.PartyIcons.SHIELD_NONE and b.partyIconId ~= Enums.PartyIcons.SHIELD_GRAY then priorityB = 4 end
        
        if priorityA ~= priorityB then
            return priorityA < priorityB
        end
        return a.name:lower() < b.name:lower()
    end)

    -- Render the sorted list.
    for i, playerData in ipairs(playerList) do
        local cid = playerData.cid
        playersFoundThisTick[cid] = true
        
        -- Determine display properties
        local yPos = LIST_START_Y + ((i - 1) * LIST_SPACING_Y)
        local skullItemId = skullIconMap[playerData.skullId]
        local vocationSuffix = vocationMap[playerData.vocationId] or "?"
        local displayText = playerData.name .. " (" .. vocationSuffix .. ")"
        
        -- NEW: Improved positioning logic for consistent spacing
        local skullXPos = LIST_MARGIN_X
        local textXPos = skullItemId and (skullXPos - (32 * SKULL_ICON_SCALE) - 5) or skullXPos

        local color = COLORS.NORMAL
        if playerData.skullId == Enums.Skulls.SKULL_RED or playerData.skullId == Enums.Skulls.SKULL_BLACK then color = COLORS.RED_SKULL
        elseif playerData.skullId ~= Enums.Skulls.SKULL_NONE then color = COLORS.WHITE_SKULL
        elseif playerData.guildEmblemId == Enums.GuildEmblem.GUILDEMBLEM_ENEMY then color = COLORS.ENEMY
        elseif playerData.guildEmblemId == Enums.GuildEmblem.GUILDEMBLEM_MEMBER then color = COLORS.GUILD
        elseif playerData.partyIconId ~= Enums.PartyIcons.SHIELD_NONE and playerData.partyIconId ~= Enums.PartyIcons.SHIELD_GRAY then color = COLORS.PARTY
        end

        if not activePlayerHuds[cid] then activePlayerHuds[cid] = {} end
        local huds = activePlayerHuds[cid]

        -- Manage Skull Icon HUD
        if skullItemId then
            if not huds.skullHud then
                huds.skullHud = HUD.new(skullXPos, yPos, skullItemId, true) --
                huds.skullHud:setHorizontalAlignment(Enums.HorizontalAlign.Right) --
                huds.skullHud:setScale(SKULL_ICON_SCALE) --
            else
                huds.skullHud:setPos(skullXPos, yPos) --
            end
        elseif huds.skullHud then
            huds.skullHud:destroy(); huds.skullHud = nil --
        end
        
        -- Manage Text HUD
        if not huds.textHud then
            huds.textHud = HUD.new(textXPos, yPos, displayText, true) --
            huds.textHud:setHorizontalAlignment(Enums.HorizontalAlign.Right) --
        else
            huds.textHud:setText(displayText) --
            huds.textHud:setPos(textXPos, yPos) --
        end
        huds.textHud:setColor(color.r, color.g, color.b) --
    end

    -- Clean up HUDs for players who are no longer on screen.
    for cid, huds in pairs(activePlayerHuds) do
        if not playersFoundThisTick[cid] then
            if huds.skullHud then huds.skullHud:destroy() end --
            if huds.textHud then huds.textHud:destroy() end --
            activePlayerHuds[cid] = nil
        end
    end
end


-- ################# SCRIPT INITIALIZATION #################

Timer.new("AdvancedPlayerListTimer", updatePlayerList, SCAN_INTERVAL_MS, true) --
print(">> Advanced Player List (Final Alignment) script loaded.") --