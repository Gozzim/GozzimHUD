-- Advanced Player List Script for Zerobot
-- Features a modal window to configure floor visibility and toggle the script.

-- #################### CONFIGURATION ####################
-- Item ID for the new settings icon.
local ICON_ITEM_ID = 4843

-- Position for the settings icon on the screen.
-- Positioned on the left side, below the Anti-Push icon (at Y=520).
local ICON_POSITION_X = 10
local ICON_POSITION_Y = 560

-- Position for the list on the right side of the screen.
local LIST_MARGIN_X = -10
local LIST_START_Y = 20

-- Other settings
local LIST_SPACING_Y = 20
local SKULL_ICON_SCALE = 0.5
local SCAN_INTERVAL_MS = 500

-- Color definitions
local COLORS = {
    RED_SKULL = {r=255, g=50, b=50}, WHITE_SKULL = {r=255, g=150, b=0}, ENEMY = {r=180, g=0, b=0},
    GUILD = {r=0, g=200, b=0}, PARTY = {r=100, g=150, b=255}, NORMAL = {r=255, g=255, b=255},
    HEADER = {r=200, g=200, b=200}, SAME_FLOOR_HEADER = {r=255, g=255, b=100}
}
-- ######################################################


-- Helper maps
local vocationMap = {[1]="EK",[2]="RP",[3]="MS",[4]="ED",[5]="MK",[0]="?"}
local skullIconMap = {[1]=37339,[2]=37341,[3]=37337,[4]=37338,[5]=37335,[6]=37340}

-- State tracking tables
local knownPlayerLevels = {}
local activePlayerHuds = {}
local activeHeaderHuds = {}
-- State variables for the settings panel
local isListEnabled = true
local maxFloorsAbove = 7
local maxFloorsBelow = 7
local settingsIcon = nil
local settingsModal = nil

-- Event handlers to learn levels (no changes)
local function onPlayerTalk(name, level, mode, text) if level > 0 then knownPlayerLevels[name:lower()] = level end end
local function onServerLogMessage(messageData)
    if messageData.messageType == Enums.MessageTypes.MESSAGE_INFO_DESCR then
        local name, level = messageData.text:match("You see ([^%(]+) %(Level (%d+)")
        if name and level then name = name:gsub("^%s*(.-)%s*$", "%1"); knownPlayerLevels[name:lower()] = tonumber(level) end
    end
end

-- ==================== Settings Modal Logic ====================
local refreshModal -- Forward declaration
local function onModalButtonClick(buttonIndex)
    if buttonIndex == 0 then maxFloorsAbove = math.max(0, maxFloorsAbove - 1)
    elseif buttonIndex == 1 then maxFloorsAbove = math.min(7, maxFloorsAbove + 1)
    elseif buttonIndex == 2 then maxFloorsBelow = math.max(0, maxFloorsBelow - 1)
    elseif buttonIndex == 3 then maxFloorsBelow = math.min(7, maxFloorsBelow + 1)
    elseif buttonIndex == 4 then isListEnabled = not isListEnabled
    end
    refreshModal()
end

refreshModal = function()
    if settingsModal then settingsModal:destroy() end

    local statusText = isListEnabled and "ENABLED" or "DISABLED"
    local description = string.format("Max Floors Above: %d\nMax Floors Below: %d", maxFloorsAbove, maxFloorsBelow)

    settingsModal = CustomModalWindow("Player List Settings (" .. statusText .. ")", description)

    settingsModal:addButton("Floors Above [-]")
    settingsModal:addButton("Floors Above [+]")
    settingsModal:addButton("Floors Below [-]")
    settingsModal:addButton("Floors Below [+]")

    local toggleButtonText = isListEnabled and "[Disable List]" or "[Enable List]"
    settingsModal:addButton(toggleButtonText)

    settingsModal:setCallback(onModalButtonClick)
end

local function openSettingsModal()
    if settingsModal then settingsModal:destroy() end
    refreshModal()
end

-- ==================== Main Display Loop ====================
local function updatePlayerList()
    if not isListEnabled then
        if next(activePlayerHuds) or next(activeHeaderHuds) then
            for cid, huds in pairs(activePlayerHuds) do if huds.skullHud then huds.skullHud:destroy() end; if huds.textHud then huds.textHud:destroy() end; activePlayerHuds[cid] = nil end
            for z, hud in pairs(activeHeaderHuds) do hud:destroy(); activeHeaderHuds[z] = nil end
        end
        return
    end

    if not Client.isConnected() then return end
    local myPlayer = Creature(Player.getId()); if not myPlayer then return end
    local myPos = myPlayer:getPosition(); if not myPos then return end

    local playersFoundThisTick, playersByFloor = {}, {}
    local allCreatures = Map.getCreatureIds(false, false)
    if allCreatures then
        for _, cid in ipairs(allCreatures) do
            if cid ~= myPos.id then
                local creature = Creature(cid)
                if creature and creature:getType() == Enums.CreatureTypes.CREATURETYPE_PLAYER then
                    local creaturePos = creature:getPosition()
                    if creaturePos then
                        local zOffset = creaturePos.z - myPos.z
                        local shouldShow = (zOffset == 0) or (zOffset < 0 and math.abs(zOffset) <= maxFloorsAbove) or (zOffset > 0 and zOffset <= maxFloorsBelow)
                        if shouldShow then
                            if not playersByFloor[zOffset] then playersByFloor[zOffset] = {} end
                            local name = creature:getName()
                            table.insert(playersByFloor[zOffset], { cid = cid, name = name, level = knownPlayerLevels[name:lower()], vocationId = creature:getVocation(), skullId = creature:getSkull(), partyIconId = creature:getPartyIcon(), guildEmblemId = creature:getGuildEmblem() })
                        end
                    end
                end
            end
        end
    end

    -- Sorting logic
    for zOffset, playerList in pairs(playersByFloor) do table.sort(playerList, function(a, b) local pA, pB = 5, 5; if a.skullId ~= 0 then pA=1 end; if b.skullId~=0 then pB=1 end; if a.guildEmblemId==2 then pA=2 end; if b.guildEmblemId==2 then pB=2 end; if a.guildEmblemId==4 then pA=3 end; if b.guildEmblemId==4 then pB=3 end; if a.partyIconId~=0 and a.partyIconId~=11 then pA=4 end; if b.partyIconId~=0 and b.partyIconId~=11 then pB=4 end; if pA~=pB then return pA<pB end; if a.vocationId~=b.vocationId then return a.vocationId<b.vocationId end; if a.level and b.level then if a.level~=b.level then return a.level>b.level end elseif a.level then return true elseif b.level then return false end; return a.name:lower()<b.name:lower() end) end

    local yOffset = LIST_START_Y
    local floorsToRender = {}; for zOffset, _ in pairs(playersByFloor) do table.insert(floorsToRender, zOffset) end
    table.sort(floorsToRender)
    local headersFoundThisTick = {}

    -- Rendering logic
    for _, zOffset in ipairs(floorsToRender) do
        local playerList = playersByFloor[zOffset]
        if #playerList > 0 then
            local headerText, headerColor; if zOffset==0 then headerText="--- Same Floor ---"; headerColor=COLORS.SAME_FLOOR_HEADER elseif zOffset<0 then headerText="--- Floor +"..math.abs(zOffset).." ---"; headerColor=COLORS.HEADER else headerText="--- Floor -"..zOffset.." ---"; headerColor=COLORS.HEADER end
            headersFoundThisTick[zOffset] = true; if not activeHeaderHuds[zOffset] then activeHeaderHuds[zOffset]=HUD.new(LIST_MARGIN_X,yOffset,headerText,true); activeHeaderHuds[zOffset]:setHorizontalAlignment(Enums.HorizontalAlign.Right) else activeHeaderHuds[zOffset]:setText(headerText); activeHeaderHuds[zOffset]:setPos(LIST_MARGIN_X, yOffset) end; activeHeaderHuds[zOffset]:setColor(headerColor.r,headerColor.g,headerColor.b); yOffset=yOffset+LIST_SPACING_Y
            for _,pData in ipairs(playerList) do local cid=pData.cid; playersFoundThisTick[cid]=true; local sId=skullIconMap[pData.skullId]; local vS=vocationMap[pData.vocationId]or"?"; local lS=pData.level and" "..pData.level or""; local dTxt=pData.name.." ("..vS..")"..lS; local tX=sId and(LIST_MARGIN_X-(32*SKULL_ICON_SCALE)-5)or LIST_MARGIN_X; local clr=COLORS.NORMAL; if pData.skullId==4 or pData.skullId==5 then clr=COLORS.RED_SKULL elseif pData.skullId~=0 then clr=COLORS.WHITE_SKULL elseif pData.guildEmblemId==2 then clr=COLORS.ENEMY elseif pData.guildEmblemId==4 then clr=COLORS.GUILD elseif pData.partyIconId~=0 and pData.partyIconId~=11 then clr=COLORS.PARTY end
                if not activePlayerHuds[cid] then activePlayerHuds[cid]={} end; local huds=activePlayerHuds[cid]
                if sId then if not huds.skullHud then huds.skullHud=HUD.new(LIST_MARGIN_X,yOffset,sId,true);huds.skullHud:setHorizontalAlignment(Enums.HorizontalAlign.Right);huds.skullHud:setScale(SKULL_ICON_SCALE)else huds.skullHud:setPos(LIST_MARGIN_X,yOffset)end elseif huds.skullHud then huds.skullHud:destroy();huds.skullHud=nil end
                if not huds.textHud then huds.textHud=HUD.new(tX,yOffset,dTxt,true);huds.textHud:setHorizontalAlignment(Enums.HorizontalAlign.Right)else huds.textHud:setText(dTxt);huds.textHud:setPos(tX,yOffset)end; huds.textHud:setColor(clr.r,clr.g,clr.b); yOffset=yOffset+LIST_SPACING_Y
            end; yOffset = yOffset + (LIST_SPACING_Y/2)
        end
    end

    for cid, huds in pairs(activePlayerHuds) do if not playersFoundThisTick[cid] then if huds.skullHud then huds.skullHud:destroy() end; if huds.textHud then huds.textHud:destroy() end; activePlayerHuds[cid] = nil end end
    for zOffset, hud in pairs(activeHeaderHuds) do if not headersFoundThisTick[zOffset] then hud:destroy(); activeHeaderHuds[zOffset] = nil end end
end

-- ################# SCRIPT INITIALIZATION #################

settingsIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, ICON_ITEM_ID, true)
if settingsIcon then
    -- The icon is now on the left, so it no longer needs to be right-aligned.
    settingsIcon:setCallback(openSettingsModal)
end

Game.registerEvent(Game.Events.TALK, onPlayerTalk)
Game.registerEvent(Game.Events.TEXT_MESSAGE, onServerLogMessage)
Timer.new("AdvancedPlayerListTimer", updatePlayerList, SCAN_INTERVAL_MS, true)
print(">> Advanced Player List (Updated Icon) loaded.")