-- Icon position on the screen.
local ICON_POSITION_X = 50
local ICON_POSITION_Y = 480

-- Opacity for the icon when ON vs OFF.
local OPACITY_ON = 1.0
local OPACITY_OFF = 0.5

-- Messages that indicate training should stop.
local WEAPON_DISAPPEARED_MSG = "Your training weapon has disappeared."
local POSITION_CHANGED_MSG = "You have changed position. Training has stopped."
local COOLDOWN_MSG = "This exercise dummy can only be used after a 20 second cooldown."

-- Weapon and Dummy Definitions
local WEAPONS = {
    CLUB = { 28542, 28554, 35281, 35287 },
    SWORD = { 28540, 28552, 35279, 35285 },
    AXE = { 28541, 28553, 35280, 35286 },
    BOW = { 28543, 28555, 35282, 35288 },
    ROD = { 28544, 28556, 35283, 35289 },
    WAND = { 28545, 28557, 35284, 35290 },
    FIST = { 50292, 50293, 50294, 50295 }
}
local DUMMY_IDS = { 28561, 28562, 28558, 28565, 28559, 28560, 28563, 28564, 63249, 55016, 55076 }

-- Runtime state
local isTrainingActive = false
local trainingIcon = nil
local currentWeaponId = nil

-- Forward declaration
local performTrainingAction
local toggleTraining

local function getDistance(pos1, pos2)
    if not pos1 or not pos2 then
        return 999
    end
    return math.max(math.abs(pos1.x - pos2.x), math.abs(pos1.y - pos2.y))
end

local function findClosestDummy()
    local myPlayer = Creature(Player.getId())
    if not myPlayer then
        return nil
    end
    local playerPos = myPlayer:getPosition()
    if not playerPos then
        return nil
    end

    local closestDummy = nil
    local maxDistance = 10

    local tiles = Map.getTiles()
    if not tiles then
        return nil
    end

    for _, tile in ipairs(tiles) do
        -- Only consider tiles on the same floor as the player
        if tile.pos.z == playerPos.z then
            for _, thing in ipairs(tile.things) do
                for _, dummyId in ipairs(DUMMY_IDS) do
                    if thing.id == dummyId then
                        local distance = getDistance(playerPos, tile.pos)
                        if distance < maxDistance then
                            maxDistance = distance
                            closestDummy = {
                                id = thing.id,
                                pos = tile.pos
                            }
                        end
                    end
                end
            end
        end
    end
    return closestDummy
end

-- Find the next weapon, with an option to ignore a specific ID
local function findNextWeapon(weaponList, ignoreId)
    if not weaponList then
        return nil
    end

    local inventoryItems = Game.getInventoryItems()
    if not inventoryItems then
        return nil
    end

    local inventoryMap = {}
    for _, item in ipairs(inventoryItems) do
        inventoryMap[item.id] = (inventoryMap[item.id] or 0) + item.count
    end

    for _, weaponId in ipairs(weaponList) do
        -- Check if the weapon is not the one to be ignored
        if weaponId ~= ignoreId then
            if inventoryMap[weaponId] and inventoryMap[weaponId] > 0 then
                return weaponId
            end
        end
    end

    if ignoreId and inventoryMap[ignoreId] and inventoryMap[ignoreId] > 0 then
        return ignoreId
    end

    return nil
end

local function getWeaponListForVocation()
    local player = Creature(Player.getId())
    local vocation = player:getVocation()

    if vocation == Enums.Vocations.MONK then
        return WEAPONS.FIST
    elseif vocation == Enums.Vocations.PALADIN or vocation == Enums.Vocations.ROYAL_PALADIN then
        return WEAPONS.BOW
    elseif vocation == Enums.Vocations.KNIGHT or vocation == Enums.Vocations.ELITE_KNIGHT then
        local skills = Player.getSkills()
        if skills.club >= skills.sword and skills.club >= skills.axe then
            return WEAPONS.CLUB
        elseif skills.sword >= skills.club and skills.sword >= skills.axe then
            return WEAPONS.SWORD
        else
            return WEAPONS.AXE
        end
    elseif vocation == Enums.Vocations.SORCERER or vocation == Enums.Vocations.MASTER_SORCERER then
        local combined = {}
        for _, id in ipairs(WEAPONS.WAND) do
            table.insert(combined, id)
        end
        for _, id in ipairs(WEAPONS.ROD) do
            table.insert(combined, id)
        end
        return combined
    elseif vocation == Enums.Vocations.DRUID or vocation == Enums.Vocations.ELDER_DRUID then
        local combined = {}
        for _, id in ipairs(WEAPONS.ROD) do
            table.insert(combined, id)
        end
        for _, id in ipairs(WEAPONS.WAND) do
            table.insert(combined, id)
        end
        return combined
    end
    return nil
end

local function updateTrainingIcon(weaponId)
    if not trainingIcon then
        return
    end
    if weaponId and weaponId ~= currentWeaponId then
        trainingIcon:setItemId(weaponId)
        currentWeaponId = weaponId
    elseif not weaponId and currentWeaponId then
        trainingIcon:setItemId(WEAPONS.CLUB[1])
        currentWeaponId = nil
    end
end

-- Accept an optional weapon ID to ignore during the search
performTrainingAction = function(ignoreId)
    if not isTrainingActive or not Client.isConnected() or not Player.getState(Enums.States.STATE_PIGEON) then
        return
    end

    local weaponList = getWeaponListForVocation()
    local weaponId = findNextWeapon(weaponList, ignoreId)

    updateTrainingIcon(weaponId)

    if not weaponId then
        print(">> Exercise: No training weapons found. Disabling script.")
        toggleTraining()
        return
    end

    local dummy = findClosestDummy()
    if not dummy then
        print(">> Exercise: No training dummy found nearby.")
        return
    end

    print(string.format(">> Exercise: Using item %d on dummy at %s.", weaponId, tostring(dummy.pos)))
    Game.useItemOnGround(weaponId, dummy.pos.x, dummy.pos.y, dummy.pos.z)
end

local function onTextMessage(messageData)
    if not isTrainingActive then
        return
    end

    if messageData.messageType == Enums.MessageTypes.MESSAGE_EVENT_ADVANCE then
        if messageData.text == WEAPON_DISAPPEARED_MSG then
            print(">> Exercise: Weapon consumed. Finding next one.")

            local weaponThatDisappeared = currentWeaponId

            -- Create a one-shot timer to perform the action, passing the ID to ignore
            Timer.new("TrainingActionTimer", function()
                performTrainingAction(weaponThatDisappeared)
                destroyTimer("TrainingActionTimer")
            end, 1000, true)
        elseif messageData.text == COOLDOWN_MSG then
            print(">> Exercise: Exercise on cooldown. Disabling script.")
            toggleTraining()
        end
    elseif messageData.messageType == Enums.MessageTypes.MESSAGE_STATUS_SMALL and messageData.text == POSITION_CHANGED_MSG then
        print(">> Exercise: Position changed. Disabling script.")
        toggleTraining()
    end
end

toggleTraining = function()
    isTrainingActive = not isTrainingActive
    if isTrainingActive then
        trainingIcon:setOpacity(OPACITY_ON)
        print(">> Exercise ENABLED.")
        performTrainingAction()
    else
        trainingIcon:setOpacity(OPACITY_OFF)
        print(">> Exercise DISABLED.")
    end
end

local function load()
    local weaponList = getWeaponListForVocation()
    local initialWeaponId = findNextWeapon(weaponList) or WEAPONS.CLUB[1]

    trainingIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, initialWeaponId, true)
    if trainingIcon then
        trainingIcon:setOpacity(isTrainingActive and OPACITY_ON or OPACITY_OFF)
        trainingIcon:setCallback(toggleTraining)

        Game.registerEvent(Game.Events.TEXT_MESSAGE, onTextMessage)

        print(">> Exercise HUD loaded.")
        if isTrainingActive then
            performTrainingAction()
        end
    else
        print(">> ERROR: Failed to create Exercise HUD.")
    end
end

local function unload()
    if trainingIcon then
        trainingIcon:destroy()
        trainingIcon = nil
    end
    Game.unregisterEvent(Game.Events.TEXT_MESSAGE, onTextMessage)
    print(">> Exercise HUD unloaded.")
end

return {
    load = load,
    unload = unload
}
