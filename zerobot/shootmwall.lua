-- Magic Wall Hotkey for Zerobot
-- Uses a Magic Wall rune on the tile in front of your current target.

-- #################### CONFIGURATION ####################
-- The hotkey to trigger the script.
-- You can use combinations like "ctrl+f", "alt+x", "shift+1", or single keys like "f1", "f2" etc.
-- Make sure this hotkey is NOT already assigned in the Tibia client itself.
local HOTKEY_COMBINATION = "x"

-- The Item ID for the Magic Wall Rune.
local MAGIC_WALL_RUNE_ID = 3180
-- ######################################################


-- This is the main function that performs the action.
local function shootMagicWall()
    -- 1. Check for basic requirements.
    if not Client.isConnected() then return end

    local targetId = Player.getTargetId()
    if not targetId or targetId == 0 then
        print(">> Magic Wall: No target selected.")
        return
    end

    if Game.getItemCount(MAGIC_WALL_RUNE_ID) <= 0 then
        print(">> Magic Wall: No Magic Wall runes found.")
        return
    end

    -- 2. Get target information.
    local targetCreature = Creature(targetId)
    if not targetCreature then return end

    local targetPos = targetCreature:getPosition()
    local targetDir = targetCreature:getDirection()

    -- 3. Calculate the position of the tile in front of the target.
    local wallPos = {x = targetPos.x, y = targetPos.y, z = targetPos.z}

    if targetDir == Enums.Directions.NORTH then
        wallPos.y = wallPos.y - 1
    elseif targetDir == Enums.Directions.SOUTH then
        wallPos.y = wallPos.y + 1
    elseif targetDir == Enums.Directions.EAST then
        wallPos.x = wallPos.x + 1
    elseif targetDir == Enums.Directions.WEST then
        wallPos.x = wallPos.x - 1
    else
        -- Target is facing a diagonal direction, do nothing.
        print(">> Magic Wall: Target is facing diagonally.")
        return
    end

    -- 4. Use the Magic Wall rune on the calculated position.
    print(">> Attempting to place Magic Wall at X:" .. wallPos.x .. ", Y:" .. wallPos.y)
    Game.useItemOnGround(MAGIC_WALL_RUNE_ID, wallPos.x, wallPos.y, wallPos.z)
end

-- This function listens for all hotkey presses.
local function onHotkeyPress(key, modifier)
    -- Parse the configured hotkey combination to get its key code and modifier flags.
    local success, configuredModifier, configuredKey = HotkeyManager.parseKeyCombination(HOTKEY_COMBINATION)
    if not success then return end

    -- Check if the pressed hotkey matches our configured one.
    if key == configuredKey and modifier == configuredModifier then
        -- If it matches, execute the main function.
        shootMagicWall()
    end
end


-- ################# SCRIPT INITIALIZATION #################

-- Register our onHotkeyPress function to be called by the game engine.
Game.registerEvent(Game.Events.HOTKEY_SHORTCUT_PRESS, onHotkeyPress)

-- Print a confirmation message in the Zerobot console.
print(">> Magic Wall Hotkey script loaded. Press '" .. HOTKEY_COMBINATION .. "' to use.")