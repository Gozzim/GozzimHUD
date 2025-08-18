-- Advanced Player List Script for Zerobot (Vocation Colors & New Format)
-- Features a side-list and a new, toggleable on-screen player information tracker.

-- #################### CONFIGURATION ####################
-- Item ID for the settings icon.
local ICON_ITEM_ID = 4843

-- Position for the settings icon on the screen.
local ICON_POSITION_X = 10
local ICON_POSITION_Y = 560

-- Position for the side-list on the right side of the screen.
local LIST_MARGIN_X = -10
local LIST_START_Y = 20

-- NEW: Vertical offset for the on-screen tracker text (pixels above character).
local TRACKER_TEXT_Y_OFFSET = 0

-- Other settings
local LIST_SPACING_Y = 20; local ICON_TEXT_SPACING = 35; local SKULL_ICON_SCALE = 0.5; local SCAN_INTERVAL_MS = 25

-- Color definitions
local COLORS = {
    RED_SKULL={r=255, g=50, b=50}, WHITE_SKULL={r=255, g=150, b=0}, ENEMY={r=180, g=0, b=0},
    GUILD={r=0, g=200, b=0}, PARTY={r=100, g=150, b=255}, NORMAL={r=255, g=255, b=255},
    HEADER={r=200, g=200, b=200}, SAME_FLOOR_HEADER={r=255, g=255, b=100}
}
-- NEW: Colors for the on-screen tracker, based on vocation.
local VOCATION_COLORS = {
    [Enums.Vocations.KNIGHT]   = {r=100, g=100, b=200},  -- Blue
    [Enums.Vocations.PALADIN]  = {r=255, g=215, b=0}, -- Golden
    [Enums.Vocations.SORCERER] = {r=200, g=75, b=75}, -- Red
    [Enums.Vocations.DRUID]    = {r=100, g=200, b=100}, -- Green
    [Enums.Vocations.MONK]     = {r=150, g=75, b=0}, -- Brown
    [Enums.Vocations.NONE]     = COLORS.NORMAL
}
-- ######################################################


-- Helper maps
local vocationMap = {[1]="EK",[2]="RP",[3]="MS",[4]="ED",[5]="MK",[0]="?"}
local skullIconMap = {[1]=37339,[2]=37341,[3]=37337,[4]=37338,[5]=37335,[6]=37340}

-- State tracking tables
local knownPlayerLevels = {}; local activePlayerHuds = {}; local activeHeaderHuds = {}
local activeTrackerHuds = {}
local isListEnabled = true; local isTrackerEnabled = true;
local maxFloorsAbove = 7; local maxFloorsBelow = 7;
local settingsIcon = nil; local settingsModal = nil

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
    elseif buttonIndex == 5 then isTrackerEnabled = not isTrackerEnabled
    end
    refreshModal()
end

refreshModal = function()
    if settingsModal then settingsModal:destroy() end

    local listStatus = isListEnabled and "LIST: ON" or "LIST: OFF"
    local trackerStatus = isTrackerEnabled and "TRACKER: ON" or "TRACKER: OFF"
    local description = string.format("Floors Above: %d | Floors Below: %d", maxFloorsAbove, maxFloorsBelow)

    settingsModal = CustomModalWindow("Player Display Settings", description) --

    settingsModal:addButton("Floors Above [-]"); settingsModal:addButton("Floors Above [+]") --
    settingsModal:addButton("Floors Below [-]"); settingsModal:addButton("Floors Below [+]") --
    settingsModal:addButton(listStatus); settingsModal:addButton(trackerStatus) --

    settingsModal:setCallback(onModalButtonClick) --
end

local function openSettingsModal()
    if settingsModal then settingsModal:destroy() end --
    refreshModal()
end

-- ==================== Main Display Loop ====================
local function updatePlayerDisplays()
    local myId = Player.getId() --

    -- Logic for the side-list
    if isListEnabled then
        local myPlayer_list = Creature(myId); if not myPlayer_list then return end
        local myPos_list = myPlayer_list:getPosition(); if not myPos_list then return end
        local playersFoundThisTick_list, playersByFloor = {}, {};
        local allPlayers_list = Map.getCreatureIds(false, true)
        if allPlayers_list then
            for _, cid in ipairs(allPlayers_list) do
                if cid ~= myId then
                    local creature = Creature(cid); local creaturePos = creature:getPosition()
                    if creaturePos then
                        local zOffset = creaturePos.z - myPos_list.z
                        local shouldShow = (zOffset == 0) or (zOffset < 0 and math.abs(zOffset) <= maxFloorsAbove) or (zOffset > 0 and zOffset <= maxFloorsBelow)
                        if shouldShow then
                            if not playersByFloor[zOffset] then playersByFloor[zOffset] = {} end
                            local name = creature:getName(); table.insert(playersByFloor[zOffset], { cid = cid, name = name, level = knownPlayerLevels[name:lower()], vocationId = creature:getVocation(), skullId = creature:getSkull(), partyIconId = creature:getPartyIcon(), guildEmblemId = creature:getGuildEmblem() })
                        end
                    end
                end
            end
        end
        -- Sorting, rendering, and cleanup logic for side-list
        for z, pList in pairs(playersByFloor) do table.sort(pList, function(a,b) local pA,pB=5,5; if a.skullId ~= 0 then pA=1 end;if b.skullId~=0 then pB=1 end;if a.guildEmblemId==2 then pA=2 end;if b.guildEmblemId==2 then pB=2 end;if a.guildEmblemId==4 then pA=3 end;if b.guildEmblemId==4 then pB=3 end;if a.partyIconId~=0 and a.partyIconId~=11 then pA=4 end;if b.partyIconId~=0 and b.partyIconId~=11 then pB=4 end;if pA~=pB then return pA<pB end;if a.vocationId~=b.vocationId then return a.vocationId<b.vocationId end;if a.level and b.level then if a.level~=b.level then return a.level > b.level end elseif a.level then return true elseif b.level then return false end;return a.name:lower()<b.name:lower() end) end
        local yOff = LIST_START_Y; local fRend={}; for z,_ in pairs(playersByFloor) do table.insert(fRend,z) end; table.sort(fRend); local hFound={};
        for _, z in ipairs(fRend) do local pList=playersByFloor[z]; if #pList>0 then local hTxt,hClr; if z==0 then hTxt="--- Same Floor ---";hClr=COLORS.SAME_FLOOR_HEADER elseif z<0 then hTxt="--- Floor +"..math.abs(z).." ---";hClr=COLORS.HEADER else hTxt="--- Floor -"..z.." ---";hClr=COLORS.HEADER end; hFound[z]=true; if not activeHeaderHuds[z] then activeHeaderHuds[z]=HUD.new(LIST_MARGIN_X,yOff,hTxt,true);activeHeaderHuds[z]:setHorizontalAlignment(Enums.HorizontalAlign.Right)else activeHeaderHuds[z]:setText(hTxt);activeHeaderHuds[z]:setPos(LIST_MARGIN_X,yOff)end;activeHeaderHuds[z]:setColor(hClr.r,hClr.g,hClr.b);yOff=yOff+LIST_SPACING_Y; for _,pData in ipairs(pList) do local cid=pData.cid;playersFoundThisTick_list[cid]=true;local sId=skullIconMap[pData.skullId];local vS=vocationMap[pData.vocationId]or"?";
            -- NEW: Updated List Display Format
            local lvlS=pData.level and", "..pData.level or""; local dTxt=pData.name.." ("..vS..lvlS..")";
            local tX=sId and(LIST_MARGIN_X-(32*SKULL_ICON_SCALE)-5)or LIST_MARGIN_X;local clr=COLORS.NORMAL;if pData.skullId==4 or pData.skullId==5 then clr=COLORS.RED_SKULL elseif pData.skullId~=0 then clr=COLORS.WHITE_SKULL elseif pData.guildEmblemId==2 then clr=COLORS.ENEMY elseif pData.guildEmblemId==4 then clr=COLORS.GUILD elseif pData.partyIconId~=0 and pData.partyIconId~=11 then clr=COLORS.PARTY end;if not activePlayerHuds[cid]then activePlayerHuds[cid]={}end;local huds=activePlayerHuds[cid];if sId then if not huds.skullHud then huds.skullHud=HUD.new(LIST_MARGIN_X,yOff,sId,true);huds.skullHud:setHorizontalAlignment(Enums.HorizontalAlign.Right);huds.skullHud:setScale(SKULL_ICON_SCALE)else huds.skullHud:setPos(LIST_MARGIN_X,yOff)end elseif huds.skullHud then huds.skullHud:destroy();huds.skullHud=nil end;if not huds.textHud then huds.textHud=HUD.new(tX,yOff,dTxt,true);huds.textHud:setHorizontalAlignment(Enums.HorizontalAlign.Right)else huds.textHud:setText(dTxt);huds.textHud:setPos(tX,yOff)end;huds.textHud:setColor(clr.r,clr.g,clr.b);yOff=yOff+LIST_SPACING_Y end;yOff=yOff+(LIST_SPACING_Y/2)end end
        for cid,huds in pairs(activePlayerHuds)do if not playersFoundThisTick_list[cid]then if huds.skullHud then huds.skullHud:destroy()end;if huds.textHud then huds.textHud:destroy()end;activePlayerHuds[cid]=nil end end;for z,hud in pairs(activeHeaderHuds)do if not hFound[z]then hud:destroy();activeHeaderHuds[z]=nil end end
    else if next(activePlayerHuds) or next(activeHeaderHuds) then for c,h in pairs(activePlayerHuds)do if h.s then h.s:destroy()end;if h.t then h.t:destroy()end;activePlayerHuds[c]=nil end;for z,h in pairs(activeHeaderHuds)do h:destroy();activeHeaderHuds[z]=nil end end end

    -- Logic for the on-screen tracker
    local playersFoundThisTick_tracker = {}
    if isTrackerEnabled then
        local gameWindow = Client.getGameWindowDimensions()
        if gameWindow and gameWindow.width > 0 then
            local calibratedX=gameWindow.x-15; local calibratedY=gameWindow.y-28; local tileWidth=gameWindow.width/15; local tileHeight=gameWindow.height/11; local winCenterX=calibratedX+(gameWindow.width/2); local winCenterY=calibratedY+(gameWindow.height/2);
            local myPos_tracker = Map.getCameraPosition()
            local sameFloorPlayers = Map.getCreatureIds(true, true)
            if sameFloorPlayers then
                for _, cid in ipairs(sameFloorPlayers) do
                    if cid ~= myId then
                        playersFoundThisTick_tracker[cid] = true
                        local creature = Creature(cid); local otherPlayerPos = creature:getPosition()
                        local deltaX = otherPlayerPos.x - myPos_tracker.x; local deltaY = otherPlayerPos.y - myPos_tracker.y

                        if math.abs(deltaX) <= 7 and math.abs(deltaY) <= 5 then
                            local screenX = winCenterX + (deltaX * tileWidth) - (tileWidth / 10)
                            local screenY = winCenterY + (deltaY * tileHeight) + TRACKER_TEXT_Y_OFFSET
                            local name = creature:getName(); local vocId = creature:getVocation()
                            local voc = vocationMap[vocId] or "?"; local lvl = knownPlayerLevels[name:lower()]
                            local text = lvl and voc.."\n"..lvl or voc

                            -- NEW: Determine color based on vocation
                            local color = VOCATION_COLORS[vocId] or VOCATION_COLORS[Enums.Vocations.NONE]

                            if not activeTrackerHuds[cid] then
                                activeTrackerHuds[cid] = HUD.new(screenX, screenY, text, true) --
                            else
                                activeTrackerHuds[cid]:setText(text) --
                                activeTrackerHuds[cid]:setPos(screenX, screenY) --
                            end
                            activeTrackerHuds[cid]:setColor(color.r, color.g, color.b) --
                        end
                    end
                end
            end
        end
    end
    -- Cleanup for tracker HUDs
    for cid, hud in pairs(activeTrackerHuds) do if not playersFoundThisTick_tracker[cid] then hud:destroy(); activeTrackerHuds[cid] = nil end end
end

-- ################# SCRIPT INITIALIZATION #################

settingsIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, ICON_ITEM_ID, true)
if settingsIcon then
    settingsIcon:setCallback(openSettingsModal)
end

Game.registerEvent(Game.Events.TALK, onPlayerTalk)
Game.registerEvent(Game.Events.TEXT_MESSAGE, onServerLogMessage)
Timer.new("AdvancedPlayerDisplayTimer", updatePlayerDisplays, SCAN_INTERVAL_MS, true)
print(">> Advanced Player Display (Vocation Colors) loaded.")