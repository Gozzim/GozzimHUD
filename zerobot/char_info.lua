local ICON_ITEM_ID = 4843
local ICON_POSITION_X = 10
local ICON_POSITION_Y = 560
local LIST_MARGIN_X = -10
local LIST_START_Y = 20
local TRACKER_TEXT_Y_OFFSET = 0
local SCAN_INTERVAL_MS = 25
local LIST_SPACING_Y = 20
local SKULL_ICON_SCALE = 0.5
local COLORS = {
    RED_SKULL = { r = 255, g = 50, b = 50 },
    WHITE_SKULL = { r = 255, g = 150, b = 0 },
    ENEMY = { r = 180, g = 0, b = 0 },
    GUILD = { r = 0, g = 200, b = 0 },
    PARTY = { r = 100, g = 150, b = 255 },
    NORMAL = { r = 255, g = 255, b = 255 },
    HEADER = { r = 255, g = 125, b = 0 },
    FLOOR = { r = 200, g = 200, b = 200 },
    SAME_FLOOR = { r = 255, g = 255, b = 100 }
}
local VOCATION_COLORS = {
    [Enums.Vocations.KNIGHT] = { r = 100, g = 100, b = 200 },
    [Enums.Vocations.PALADIN] = { r = 255, g = 215, b = 0 },
    [Enums.Vocations.SORCERER] = { r = 200, g = 75, b = 75 },
    [Enums.Vocations.DRUID] = { r = 100, g = 200, b = 100 },
    [Enums.Vocations.MONK] = { r = 150, g = 75, b = 0 },
    [Enums.Vocations.NONE] = COLORS.NORMAL
}
local vocationMap = { [1] = "EK", [2] = "RP", [3] = "MS", [4] = "ED", [5] = "EM", [0] = "?" }
local skullIconMap = { [1] = 37339, [2] = 37341, [3] = 37337, [4] = 37338, [5] = 37335, [6] = 37340 }
local knownPlayerLevels = {}
local activePlayerHuds = {}
local activeHeaderHuds = {}
local activeTrackerHuds = {}
local activeMonsterHuds = {}
local activeMonsterHeaderHuds = {}
local activeNpcHuds = {}
local activeNpcHeaderHuds = {}
local isListEnabled = true
local isTrackerEnabled = true
local maxFloorsAbove = 7
local maxFloorsBelow = 7
local showPartyMembers = true
local showGuildMates = true
local subSortOrder = "vocation"
local isCategorySortEnabled = true
local isColorCodingEnabled = true
local isAutoLookEnabled = false
local showPlayers = true
local showMonsters = true
local showNpcs = false
local settingsIcon = nil
local settingsModal = nil
local lastWorldName = nil

local function getCharacterInfoPath(worldNameOverride)
    local scriptsDir = Engine.getScriptsDirectory()
    local worldName = worldNameOverride or Client.getWorldName()

    if not scriptsDir or not worldName then
        return nil
    end

    -- Trim whitespace from world name
    worldName = worldName:gsub("^%s*(.-)%s*$", "%1")

    return string.format("%s/charInfo_%s.json", scriptsDir, worldName)
end

local function saveCharacterInfo(worldNameToSave)
    if not worldNameToSave then return end

    local path = getCharacterInfoPath(worldNameToSave)
    if not path then
        print("Could not save character info: Missing path components for world: " .. worldNameToSave)
        return
    end

    local success, jsonData = pcall(JSON.encode, knownPlayerLevels)
    if not success then
        print("Error encoding character info to JSON: " .. tostring(jsonData))
        return
    end

    local file, err = io.open(path, "w")
    if not file then
        print("Error opening file to save character info: " .. tostring(err))
        return
    end

    file:write(jsonData)
    file:close()
    print(">> Character info saved for " .. worldNameToSave)
end

local function loadCharacterInfo()
    local path = getCharacterInfoPath()
    if not path then
        print("Could not load character info: Not connected or world name is unavailable.")
        knownPlayerLevels = {}
        return
    end

    local file = io.open(path, "r")
    if not file then
        knownPlayerLevels = {}
        print(">> No existing charInfo file found for " .. (Client.getWorldName() or "current world"))
        return
    end

    local content = file:read("*a")
    file:close()

    if content and #content > 0 then
        local success, data = pcall(JSON.decode, content)
        if success and type(data) == "table" then
            knownPlayerLevels = data
            print(">> Character info loaded for " .. Client.getWorldName())
        else
            print("Error decoding character info from JSON: " .. tostring(data))
            knownPlayerLevels = {}
        end
    else
        knownPlayerLevels = {}
    end
end

local function onPlayerTalk(name, level, mode, text)
    if level > 0 then
        knownPlayerLevels[name:lower()] = level
    end
end

local function onServerLogMessage(messageData)
    if messageData.messageType == Enums.MessageTypes.MESSAGE_INFO_DESCR then
        local name, level = messageData.text:match("You see ([^%(]+) %(Level (%d+)")
        if name and level then
            name = name:gsub("^%s*(.-)%s*$", "%1")
            knownPlayerLevels[name:lower()] = tonumber(level)
        end
    end
end

local openSettingsModal
local function onModalButtonClick(buttonIndex)
    if buttonIndex == 0 then
        maxFloorsAbove = math.max(0, maxFloorsAbove - 1)
    elseif buttonIndex == 1 then
        maxFloorsAbove = math.min(7, maxFloorsAbove + 1)
    elseif buttonIndex == 2 then
        maxFloorsBelow = math.max(0, maxFloorsBelow - 1)
    elseif buttonIndex == 3 then
        maxFloorsBelow = math.min(7, maxFloorsBelow + 1)
    elseif buttonIndex == 4 then
        isTrackerEnabled = not isTrackerEnabled
    elseif buttonIndex == 5 then
        isListEnabled = not isListEnabled
    elseif buttonIndex == 6 then
        isColorCodingEnabled = not isColorCodingEnabled
    elseif buttonIndex == 7 then
        isAutoLookEnabled = not isAutoLookEnabled
    elseif buttonIndex == 8 then
        showGuildMates = not showGuildMates
    elseif buttonIndex == 9 then
        showPartyMembers = not showPartyMembers
    elseif buttonIndex == 10 then
        isCategorySortEnabled = not isCategorySortEnabled
    elseif buttonIndex == 11 then
        if subSortOrder == "vocation" then
            subSortOrder = "level"
        elseif subSortOrder == "level" then
            subSortOrder = "alphabet"
        else
            subSortOrder = "vocation"
        end
    elseif buttonIndex == 12 then
        showPlayers = not showPlayers
    elseif buttonIndex == 13 then
        showMonsters = not showMonsters
    elseif buttonIndex == 14 then
        showNpcs = not showNpcs
    elseif buttonIndex == 15 then
        if lastWorldName then
            saveCharacterInfo(lastWorldName)
        end
        if settingsModal then
            settingsModal:destroy()
        end
        settingsModal = nil
        return
    end
    openSettingsModal()
end

openSettingsModal = function()
    if settingsModal then
        settingsModal:destroy()
    end
    local playerStatus = showPlayers and 'Players: <font color="#00FF00">ON</font>' or 'Players: <font color="#FF6666">OFF</font>'
    local listStatus = isListEnabled and 'List: <font color="#00FF00">ON</font>' or 'List: <font color="#FF6666">OFF</font>'
    local trackerStatus = isTrackerEnabled and 'Tracker: <font color="#00FF00">ON</font>' or 'Tracker: <font color="#FF6666">OFF</font>'
    local partyStatus = showPartyMembers and 'Party: <font color="#00FF00">ON</font>' or 'Party: <font color="#FF6666">OFF</font>'
    local guildStatus = showGuildMates and 'Guild: <font color="#00FF00">ON</font>' or 'Guild: <font color="#FF6666">OFF</font>'
    local sortStatus = "Sort by: " .. subSortOrder:gsub("^%l", string.upper)
    local categorySortStatus = isCategorySortEnabled and 'Categorize: <font color="#00FF00">ON</font>' or 'Categorize: <font color="#FF6666">OFF</font>'
    local colorStatus = isColorCodingEnabled and 'Colors: <font color="#00FF00">ON</font>' or 'Colors: <font color="#FF6666">OFF</font>'
    local autoLookStatus = isAutoLookEnabled and 'Auto Look: <font color="#00FF00">ON</font>' or 'Auto Look: <font color="#FF6666">OFF</font>'
    local monsterStatus = showMonsters and 'Monsters: <font color="#00FF00">ON</font>' or 'Monsters: <font color="#FF6666">OFF</font>'
    local npcStatus = showNpcs and 'NPCs: <font color="#00FF00">ON</font>' or 'NPCs: <font color="#FF6666">OFF</font>'
    local description = string.format("Floors Above: %d | Floors Below: %d", maxFloorsAbove, maxFloorsBelow)
    settingsModal = CustomModalWindow("Player Display Settings", description)
    settingsModal:addButton('Floors Above [-]')
    settingsModal:addButton('Floors Above [+]')
    settingsModal:addButton('Floors Below [-]')
    settingsModal:addButton('Floors Below [+]')
    settingsModal:addButton(trackerStatus)
    settingsModal:addButton(listStatus)
    settingsModal:addButton(colorStatus)
    settingsModal:addButton(autoLookStatus)
    settingsModal:addButton(guildStatus)
    settingsModal:addButton(partyStatus)
    settingsModal:addButton(categorySortStatus)
    settingsModal:addButton(sortStatus)
    settingsModal:addButton(playerStatus)
    settingsModal:addButton(monsterStatus)
    settingsModal:addButton(npcStatus)
    settingsModal:addButton("Save & Close")
    settingsModal:setCallback(onModalButtonClick)
end

local function cleanupSectionHuds(hudsTable, headerHudsTable)
    for k, huds in pairs(hudsTable) do
        if huds.skullHud then huds.skullHud:destroy() end
        if huds.textHud then huds.textHud:destroy() end
        hudsTable[k] = nil
    end
    for k, h in pairs(headerHudsTable) do
        h:destroy()
        headerHudsTable[k] = nil
    end
end

local function updatePlayerDisplays()
    local isConnected = Client.isConnected()
    local currentWorld = isConnected and Client.getWorldName() or nil

    if lastWorldName and (not isConnected or (currentWorld and currentWorld ~= lastWorldName)) then
        print("Connection state or world changed, saving data for " .. lastWorldName)
        saveCharacterInfo(lastWorldName)
        knownPlayerLevels = {}
    end

    if isConnected and (not lastWorldName or (currentWorld and currentWorld ~= lastWorldName)) then
        print("New connection or world detected. Loading data for " .. currentWorld)
        loadCharacterInfo()
    end

    lastWorldName = currentWorld

    local myId = Player.getId()
    local myPlayer_list = Creature(myId)
    local myPos_list = myPlayer_list and myPlayer_list:getPosition()

    -- Cleanup for tracker HUDs
    if not isTrackerEnabled then
        for c, h in pairs(activeTrackerHuds) do
            h:destroy()
            activeTrackerHuds[c] = nil
        end
    end

    local allCreaturesOnScreen = Map.getCreatureIds(false, false)

    -- Auto-Look logic
    if isAutoLookEnabled and isListEnabled and showPlayers and allCreaturesOnScreen then
        local knownPlayerPositions = {}
        local unknownPlayersByPosition = {}
        for _, cid in ipairs(allCreaturesOnScreen) do
            if cid ~= myId then
                local creature = Creature(cid)
                if creature:getType() == Enums.CreatureTypes.CREATURETYPE_PLAYER then
                    local name = creature:getName()
                    if name then
                        local pos = creature:getPosition()
                        if pos then
                            local posKey = pos.x .. "," .. pos.y .. "," .. pos.z
                            if knownPlayerLevels[name:lower()] then
                                knownPlayerPositions[posKey] = true
                            else
                                if not unknownPlayersByPosition[posKey] then unknownPlayersByPosition[posKey] = {} end
                                table.insert(unknownPlayersByPosition[posKey], pos)
                            end
                        end
                    end
                end
            end
        end
        for posKey, positions in pairs(unknownPlayersByPosition) do
            if not knownPlayerPositions[posKey] then
                local posToLookAt = positions[1]
                Map.lookAt(posToLookAt.x, posToLookAt.y, posToLookAt.z)
                break
            end
        end
    end

    local yOff = LIST_START_Y

    -- Players Section
    if isListEnabled and showPlayers and myPos_list then
        local pFound_list, pByFloor = {}, {}
        local totalPlayersDisplayed = 0
        if allCreaturesOnScreen then
            for _, cid in ipairs(allCreaturesOnScreen) do
                if cid ~= myId then
                    local cr = Creature(cid)
                    if cr:getType() == Enums.CreatureTypes.CREATURETYPE_PLAYER then
                        local n = cr:getName()
                        if n then
                            local crP = cr:getPosition()
                            if crP then
                                local zO = crP.z - myPos_list.z
                                local sS = (zO == 0) or (zO < 0 and math.abs(zO) <= maxFloorsAbove) or (zO > 0 and zO <= maxFloorsBelow)
                                if sS then
                                    local pData = { cid = cid, name = n, level = knownPlayerLevels[n:lower()], vocationId = cr:getVocation(), skullId = cr:getSkull(), partyIconId = cr:getPartyIcon(), guildEmblemId = cr:getGuildEmblem() }
                                    local isParty = pData.partyIconId >= Enums.PartyIcons.SHIELD_BLUE and pData.partyIconId <= Enums.PartyIcons.SHIELD_YELLOW_NOSHAREDEXP
                                    local isGuild = pData.guildEmblemId == Enums.GuildEmblem.GUILDEMBLEM_MEMBER or pData.guildEmblemId == Enums.GuildEmblem.GUILDEMBLEM_ALLY
                                    if (not isParty or showPartyMembers) and (not isGuild or showGuildMates) then
                                        if not pByFloor[zO] then
                                            pByFloor[zO] = {}
                                        end
                                        table.insert(pByFloor[zO], pData)
                                        totalPlayersDisplayed = totalPlayersDisplayed + 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- Sort players
        for z, pL in pairs(pByFloor) do
            table.sort(pL, function(a, b)
                if isCategorySortEnabled then
                    local function getPriority(p)
                        if p.partyIconId >= Enums.PartyIcons.SHIELD_BLUE and p.partyIconId <= Enums.PartyIcons.SHIELD_YELLOW_NOSHAREDEXP then
                            return 4
                        end
                        if p.guildEmblemId == Enums.GuildEmblem.GUILDEMBLEM_MEMBER or p.guildEmblemId == Enums.GuildEmblem.GUILDEMBLEM_ALLY then
                            return 3
                        end
                        if p.guildEmblemId == Enums.GuildEmblem.GUILDEMBLEM_ENEMY then
                            return 2
                        end
                        if p.skullId ~= Enums.Skulls.SKULL_NONE and p.skullId ~= Enums.Skulls.SKULL_GREEN then
                            return 1
                        end
                        return 5
                    end
                    local pA, pB = getPriority(a), getPriority(b)
                    if pA ~= pB then
                        return pA < pB
                    end
                end
                if subSortOrder == "vocation" then
                    if a.vocationId ~= b.vocationId then
                        return a.vocationId < b.vocationId
                    end
                    -- Tie-breaker for vocation: level then alphabet
                    if a.level and b.level then
                        if a.level ~= b.level then
                            return a.level > b.level
                        end
                    elseif a.level then
                        return true
                    elseif b.level then
                        return false
                    end
                    return a.name:lower() < b.name:lower()
                elseif subSortOrder == "level" then
                    -- Primary sort by level
                    if a.level and b.level then
                        if a.level ~= b.level then
                            return a.level > b.level
                        end
                    elseif a.level then
                        return true
                    elseif b.level then
                        return false
                    end
                    -- Tie-breaker for level: vocation then alphabet
                    if a.vocationId ~= b.vocationId then
                        return a.vocationId < b.vocationId
                    end
                    return a.name:lower() < b.name:lower()
                elseif subSortOrder == "alphabet" then
                    -- Primary sort by alphabet
                    if a.name:lower() ~= b.name:lower() then
                        return a.name:lower() < b.name:lower()
                    end
                    -- Tie-breaker for alphabet: vocation then level
                    if a.vocationId ~= b.vocationId then
                        return a.vocationId < b.vocationId
                    end
                    if a.level and b.level then
                        if a.level ~= b.level then
                            return a.level > b.level
                        end
                    elseif a.level then
                        return true
                    elseif b.level then
                        return false
                    end
                    return false
                end
                -- Fallback
                return a.name:lower() < b.name:lower()
            end)
        end

        local fRend = {}
        for z, _ in pairs(pByFloor) do
            table.insert(fRend, z)
        end
        table.sort(fRend)

        -- Render Players Section if not empty
        if totalPlayersDisplayed > 0 then
            local hFound = {}
            local playerHeaderTxt = "PLAYERS: " .. totalPlayersDisplayed
            if not activeHeaderHuds["players_header"] then
                activeHeaderHuds["players_header"] = HUD.new(LIST_MARGIN_X, yOff, playerHeaderTxt, true)
                activeHeaderHuds["players_header"]:setHorizontalAlignment(Enums.HorizontalAlign.Right)
            else
                activeHeaderHuds["players_header"]:setText(playerHeaderTxt)
                activeHeaderHuds["players_header"]:setPos(LIST_MARGIN_X, yOff)
            end
            activeHeaderHuds["players_header"]:setColor(COLORS.HEADER.r, COLORS.HEADER.g, COLORS.HEADER.b)
            yOff = yOff + LIST_SPACING_Y

            for _, z in ipairs(fRend) do
                local pL = pByFloor[z]
                if #pL > 0 then
                    local hTxt, hClr
                    if z == 0 then
                        hTxt = "--- Same Floor ---"
                        hClr = COLORS.SAME_FLOOR
                    elseif z < 0 then
                        hTxt = "--- Floor +" .. math.abs(z) .. " ---"
                        hClr = COLORS.FLOOR
                    else
                        hTxt = "--- Floor -" .. z .. " ---"
                        hClr = COLORS.FLOOR
                    end
                    hFound[z] = true
                    if not activeHeaderHuds[z] then
                        activeHeaderHuds[z] = HUD.new(LIST_MARGIN_X, yOff, hTxt, true)
                        activeHeaderHuds[z]:setHorizontalAlignment(Enums.HorizontalAlign.Right)
                    else
                        activeHeaderHuds[z]:setText(hTxt)
                        activeHeaderHuds[z]:setPos(LIST_MARGIN_X, yOff)
                    end
                    activeHeaderHuds[z]:setColor(hClr.r, hClr.g, hClr.b)
                    yOff = yOff + LIST_SPACING_Y
                    for _, pData in ipairs(pL) do
                        local cid = pData.cid
                        pFound_list[cid] = true
                        local sId = skullIconMap[pData.skullId]
                        local vS = vocationMap[pData.vocationId] or "?"
                        local lvlS = pData.level and ", " .. pData.level or ""
                        local dTxt = pData.name .. " (" .. vS .. lvlS .. ")"
                        local tX = sId and (LIST_MARGIN_X - (32 * SKULL_ICON_SCALE) - 5) or LIST_MARGIN_X
                        local clr = COLORS.NORMAL
                        if isColorCodingEnabled then
                            if pData.partyIconId >= Enums.PartyIcons.SHIELD_BLUE and pData.partyIconId <= Enums.PartyIcons.SHIELD_YELLOW_NOSHAREDEXP then
                                clr = COLORS.PARTY
                            elseif pData.guildEmblemId == Enums.GuildEmblem.GUILDEMBLEM_MEMBER or pData.guildEmblemId == Enums.GuildEmblem.GUILDEMBLEM_ALLY then
                                clr = COLORS.GUILD
                            elseif pData.guildEmblemId == Enums.GuildEmblem.GUILDEMBLEM_ENEMY then
                                clr = COLORS.ENEMY
                            elseif pData.skullId == Enums.Skulls.SKULL_RED or pData.skullId == Enums.Skulls.SKULL_BLACK then
                                clr = COLORS.RED_SKULL
                            elseif pData.skullId ~= Enums.Skulls.SKULL_NONE and pData.skullId ~= Enums.Skulls.SKULL_GREEN then
                                clr = COLORS.WHITE_SKULL
                            end
                        end
                        if not activePlayerHuds[cid] then
                            activePlayerHuds[cid] = {}
                        end
                        local huds = activePlayerHuds[cid]
                        if sId then
                            if not huds.skullHud then
                                huds.skullHud = HUD.new(LIST_MARGIN_X, yOff, sId, true)
                                huds.skullHud:setHorizontalAlignment(Enums.HorizontalAlign.Right)
                                huds.skullHud:setScale(SKULL_ICON_SCALE)
                            else
                                huds.skullHud:setItemId(sId)
                                huds.skullHud:setPos(LIST_MARGIN_X, yOff)
                            end
                        elseif huds.skullHud then
                            huds.skullHud:destroy()
                            huds.skullHud = nil
                        end
                        if not huds.textHud then
                            huds.textHud = HUD.new(tX, yOff, dTxt, true)
                            huds.textHud:setHorizontalAlignment(Enums.HorizontalAlign.Right)
                        else
                            huds.textHud:setText(dTxt)
                            huds.textHud:setPos(tX, yOff)
                        end
                        huds.textHud:setColor(clr.r, clr.g, clr.b)
                        yOff = yOff + LIST_SPACING_Y
                    end
                    yOff = yOff + (LIST_SPACING_Y / 2)
                end
            end
            -- Cleanup for removed players or floor headers
            for cid, huds in pairs(activePlayerHuds) do
                if not pFound_list[cid] then
                    if huds.skullHud then huds.skullHud:destroy() end
                    if huds.textHud then huds.textHud:destroy() end
                    activePlayerHuds[cid] = nil
                end
            end
            for z, hud in pairs(activeHeaderHuds) do
                if z ~= "players_header" and not hFound[z] then
                    hud:destroy()
                    activeHeaderHuds[z] = nil
                end
            end
        else -- If totalPlayersDisplayed is 0, destroy all player HUDs
            cleanupSectionHuds(activePlayerHuds, activeHeaderHuds)
        end
    else -- If isListEnabled or showPlayers is false, destroy all player HUDs
        cleanupSectionHuds(activePlayerHuds, activeHeaderHuds)
    end

    -- Monsters Section
    if isListEnabled and showMonsters and myPos_list then
        local mFound_list, mByFloor = {}, {}
        local totalMonstersDisplayed = 0
        if allCreaturesOnScreen then
            for _, cid in ipairs(allCreaturesOnScreen) do
                local creature = Creature(cid)
                if creature:getType() == Enums.CreatureTypes.CREATURETYPE_MONSTER then
                    local name = creature:getName()
                    if name then
                        local crP = creature:getPosition()
                        if crP then
                            local zO = crP.z - myPos_list.z
                            local sS = (zO == 0) or (zO < 0 and math.abs(zO) <= maxFloorsAbove) or (zO > 0 and zO <= maxFloorsBelow)
                            if sS then
                                if not mByFloor[zO] then
                                    mByFloor[zO] = {}
                                end
                                mByFloor[zO][name] = (mByFloor[zO][name] or 0) + 1
                                totalMonstersDisplayed = totalMonstersDisplayed + 1
                            end
                        end
                    end
                end
            end
        end
        local mFRend = {}
        for z, _ in pairs(mByFloor) do
            table.insert(mFRend, z)
        end
        table.sort(mFRend)

        -- Render Monsters Section if not empty
        if totalMonstersDisplayed > 0 then
            local monsterHeaderTxt = "CREATURES: " .. totalMonstersDisplayed
            if not activeMonsterHeaderHuds["monsters_header"] then
                activeMonsterHeaderHuds["monsters_header"] = HUD.new(LIST_MARGIN_X, yOff, monsterHeaderTxt, true)
                activeMonsterHeaderHuds["monsters_header"]:setHorizontalAlignment(Enums.HorizontalAlign.Right)
            else
                activeMonsterHeaderHuds["monsters_header"]:setText(monsterHeaderTxt)
                activeMonsterHeaderHuds["monsters_header"]:setPos(LIST_MARGIN_X, yOff)
            end
            activeMonsterHeaderHuds["monsters_header"]:setColor(COLORS.HEADER.r, COLORS.HEADER.g, COLORS.HEADER.b)
            yOff = yOff + LIST_SPACING_Y

            local mHFound = {}
            for _, z in ipairs(mFRend) do
                local mL = mByFloor[z]
                if mL and next(mL) then
                    local hTxt, hClr
                    if z == 0 then
                        hTxt = "--- Same Floor ---"
                        hClr = COLORS.SAME_FLOOR
                    elseif z < 0 then
                        hTxt = "--- Floor +" .. math.abs(z) .. " ---"
                        hClr = COLORS.FLOOR
                    else
                        hTxt = "--- Floor -" .. z .. " ---"
                        hClr = COLORS.FLOOR
                    end
                    mHFound[z] = true
                    if not activeMonsterHeaderHuds[z] then
                        activeMonsterHeaderHuds[z] = HUD.new(LIST_MARGIN_X, yOff, hTxt, true)
                        activeMonsterHeaderHuds[z]:setHorizontalAlignment(Enums.HorizontalAlign.Right)
                    else
                        activeMonsterHeaderHuds[z]:setText(hTxt)
                        activeMonsterHeaderHuds[z]:setPos(LIST_MARGIN_X, yOff)
                    end
                    activeMonsterHeaderHuds[z]:setColor(hClr.r, hClr.g, hClr.b)
                    yOff = yOff + LIST_SPACING_Y
                    local sortedMonsterNames = {}
                    for name, _ in pairs(mL) do
                        table.insert(sortedMonsterNames, name)
                    end
                    table.sort(sortedMonsterNames)
                    for _, name in ipairs(sortedMonsterNames) do
                        local count = mL[name]
                        local dTxt = name .. ": " .. count
                        local tX = LIST_MARGIN_X
                        local clr = COLORS.NORMAL
                        local key = name .. "_" .. z
                        if not activeMonsterHuds[key] then
                            activeMonsterHuds[key] = {}
                        end
                        local huds = activeMonsterHuds[key]
                        mFound_list[key] = true
                        if not huds.textHud then
                            huds.textHud = HUD.new(tX, yOff, dTxt, true)
                            huds.textHud:setHorizontalAlignment(Enums.HorizontalAlign.Right)
                        else
                            huds.textHud:setText(dTxt)
                            huds.textHud:setPos(tX, yOff)
                        end
                        huds.textHud:setColor(clr.r, clr.g, clr.b)
                        yOff = yOff + LIST_SPACING_Y
                    end
                    yOff = yOff + (LIST_SPACING_Y / 2)
                end
            end
            -- Cleanup for removed monsters or floor headers
            for key, huds in pairs(activeMonsterHuds) do
                if not mFound_list[key] then
                    huds.textHud:destroy()
                    activeMonsterHuds[key] = nil
                end
            end
            for z, hud in pairs(activeMonsterHeaderHuds) do
                if z ~= "monsters_header" and not mHFound[z] then
                    hud:destroy()
                    activeMonsterHeaderHuds[z] = nil
                end
            end
        else -- If totalMonstersDisplayed is 0, destroy all monster HUDs
            cleanupSectionHuds(activeMonsterHuds, activeMonsterHeaderHuds)
        end
    else -- If isListEnabled or showMonsters is false, destroy all monster HUDs
        cleanupSectionHuds(activeMonsterHuds, activeMonsterHeaderHuds)
    end

    -- NPCs Section
    if isListEnabled and showNpcs and myPos_list then
        local nFound_list, nByFloor = {}, {}
        local totalNpcsDisplayed = 0
        if allCreaturesOnScreen then
            for _, cid in ipairs(allCreaturesOnScreen) do
                local creature = Creature(cid)
                if creature:getType() == Enums.CreatureTypes.CREATURETYPE_NPC then
                    local name = creature:getName()
                    if name then
                        local crP = creature:getPosition()
                        if crP then
                            local zO = crP.z - myPos_list.z
                            local sS = (zO == 0) or (zO < 0 and math.abs(zO) <= maxFloorsAbove) or (zO > 0 and zO <= maxFloorsBelow)
                            if sS then
                                if not nByFloor[zO] then
                                    nByFloor[zO] = {}
                                end
                                if not nByFloor[zO][name] then
                                    nByFloor[zO][name] = true
                                    totalNpcsDisplayed = totalNpcsDisplayed + 1
                                end
                            end
                        end
                    end
                end
            end
        end
        local nFRend = {}
        for z, _ in pairs(nByFloor) do
            table.insert(nFRend, z)
        end
        table.sort(nFRend)

        -- Render NPCs Section if not empty
        if totalNpcsDisplayed > 0 then
            local npcHeaderTxt = "NPCs: " .. totalNpcsDisplayed
            if not activeNpcHeaderHuds["npcs_header"] then
                activeNpcHeaderHuds["npcs_header"] = HUD.new(LIST_MARGIN_X, yOff, npcHeaderTxt, true)
                activeNpcHeaderHuds["npcs_header"]:setHorizontalAlignment(Enums.HorizontalAlign.Right)
            else
                activeNpcHeaderHuds["npcs_header"]:setText(npcHeaderTxt)
                activeNpcHeaderHuds["npcs_header"]:setPos(LIST_MARGIN_X, yOff)
            end
            activeNpcHeaderHuds["npcs_header"]:setColor(COLORS.HEADER.r, COLORS.HEADER.g, COLORS.HEADER.b)
            yOff = yOff + LIST_SPACING_Y

            local nHFound = {}
            for _, z in ipairs(nFRend) do
                local nL = nByFloor[z]
                if nL and next(nL) then
                    local hTxt, hClr
                    if z == 0 then
                        hTxt = "--- Same Floor ---"
                        hClr = COLORS.SAME_FLOOR
                    elseif z < 0 then
                        hTxt = "--- Floor +" .. math.abs(z) .. " ---"
                        hClr = COLORS.FLOOR
                    else
                        hTxt = "--- Floor -" .. z .. " ---"
                        hClr = COLORS.FLOOR
                    end
                    nHFound[z] = true
                    if not activeNpcHeaderHuds[z] then
                        activeNpcHeaderHuds[z] = HUD.new(LIST_MARGIN_X, yOff, hTxt, true)
                        activeNpcHeaderHuds[z]:setHorizontalAlignment(Enums.HorizontalAlign.Right)
                    else
                        activeNpcHeaderHuds[z]:setText(hTxt)
                        activeNpcHeaderHuds[z]:setPos(LIST_MARGIN_X, yOff)
                    end
                    activeNpcHeaderHuds[z]:setColor(hClr.r, hClr.g, hClr.b)
                    yOff = yOff + LIST_SPACING_Y
                    local sortedNpcNames = {}
                    for name, _ in pairs(nL) do
                        table.insert(sortedNpcNames, name)
                    end
                    table.sort(sortedNpcNames)
                    for _, name in ipairs(sortedNpcNames) do
                        local dTxt = name
                        local tX = LIST_MARGIN_X
                        local clr = COLORS.NORMAL
                        local key = name .. "_" .. z
                        if not activeNpcHuds[key] then
                            activeNpcHuds[key] = {}
                        end
                        local huds = activeNpcHuds[key]
                        nFound_list[key] = true
                        if not huds.textHud then
                            huds.textHud = HUD.new(tX, yOff, dTxt, true)
                            huds.textHud:setHorizontalAlignment(Enums.HorizontalAlign.Right)
                        else
                            huds.textHud:setText(dTxt)
                            huds.textHud:setPos(tX, yOff)
                        end
                        huds.textHud:setColor(clr.r, clr.g, clr.b)
                        yOff = yOff + LIST_SPACING_Y
                    end
                    yOff = yOff + (LIST_SPACING_Y / 2)
                end
            end
            -- Cleanup for removed NPCs or floor headers
            for key, huds in pairs(activeNpcHuds) do
                if not nFound_list[key] then
                    huds.textHud:destroy()
                    activeNpcHuds[key] = nil
                end
            end
            for z, hud in pairs(activeNpcHeaderHuds) do
                if z ~= "npcs_header" and not nHFound[z] then
                    hud:destroy()
                    activeNpcHeaderHuds[z] = nil
                end
            end
        else -- If totalNpcsDisplayed is 0, destroy all NPC HUDs
            cleanupSectionHuds(activeNpcHuds, activeNpcHeaderHuds)
        end
    else -- If isListEnabled or showNpcs is false, destroy all NPC HUDs
        cleanupSectionHuds(activeNpcHuds, activeNpcHeaderHuds)
    end

    -- Tracker Section
    local playersFoundThisTick_tracker = {}
    if isTrackerEnabled then
        local gameWindow = Client.getGameWindowDimensions()
        if gameWindow and gameWindow.width > 0 then
            local calibratedX = gameWindow.x - 15
            local calibratedY = gameWindow.y - 28
            local tileWidth = gameWindow.width / 15
            local tileHeight = gameWindow.height / 11
            local winCenterX = calibratedX + (gameWindow.width / 2)
            local winCenterY = calibratedY + (gameWindow.height / 2)
            local myPos_tracker = Map.getCameraPosition()
            local sameFloorPlayers = Map.getCreatureIds(true, true)
            if sameFloorPlayers then
                for _, cid in ipairs(sameFloorPlayers) do
                    if cid ~= myId then
                        local creature = Creature(cid)
                        local otherPlayerPos = creature:getPosition()
                        local name = creature:getName()
                        if otherPlayerPos and name then
                            local deltaX = otherPlayerPos.x - myPos_tracker.x
                            local deltaY = otherPlayerPos.y - myPos_tracker.y
                            if math.abs(deltaX) < 7.5 and math.abs(deltaY) < 5.5 then
                                playersFoundThisTick_tracker[cid] = true
                                local screenX = winCenterX + (deltaX * tileWidth) - (tileWidth / 10)
                                local screenY = winCenterY + (deltaY * tileHeight) + TRACKER_TEXT_Y_OFFSET
                                local vocId = creature:getVocation()
                                local voc = vocationMap[vocId] or "?"
                                local lvl = knownPlayerLevels[name:lower()]
                                local text = lvl and voc .. "\n" .. lvl or voc
                                local color = VOCATION_COLORS[vocId] or VOCATION_COLORS[Enums.Vocations.NONE]
                                if not activeTrackerHuds[cid] then
                                    activeTrackerHuds[cid] = HUD.new(screenX, screenY, text, true)
                                else
                                    activeTrackerHuds[cid]:setText(text)
                                    activeTrackerHuds[cid]:setPos(screenX, screenY)
                                end
                                activeTrackerHuds[cid]:setColor(color.r, color.g, color.b)
                            end
                        end
                    end
                end
            end
        end
    end
    -- Cleanup for tracker HUDs
    for cid, hud in pairs(activeTrackerHuds) do
        if not playersFoundThisTick_tracker[cid] then
            hud:destroy()
            activeTrackerHuds[cid] = nil
        end
    end
end

settingsIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, ICON_ITEM_ID, true)
if settingsIcon then
    settingsIcon:setCallback(openSettingsModal)
end

Game.registerEvent(Game.Events.TALK, onPlayerTalk)
Game.registerEvent(Game.Events.TEXT_MESSAGE, onServerLogMessage)
Timer.new("AdvancedPlayerDisplayTimer", updatePlayerDisplays, SCAN_INTERVAL_MS, true)

if Client.isConnected() then
    lastWorldName = Client.getWorldName()
    loadCharacterInfo()
end

print(">> Advanced Player Display loaded.")
