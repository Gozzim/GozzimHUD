-- Magic Wall Hotkey Script with HUD
-- Uses manual coordinate calculation to center the text below the icon.

-- #################### CONFIGURATION ####################
-- The hotkey to trigger the script.
local HOTKEY_COMBINATION = "x"

-- The Item ID for the Magic Wall Rune.
local MAGIC_WALL_RUNE_ID = 3180

-- Position of the icon on the screen.
local ICON_POSITION_X = 90
local ICON_POSITION_Y = 240

-- ## --- Auto-calculated Text Position --- ##
-- We manually calculate the text position to center it under the 32x32 icon.
local ICON_WIDTH = 32
local ICON_HEIGHT = 32
local APPROX_CHAR_WIDTH = 6 -- Estimated average width of a character in the font.
local TEXT_WIDTH = string.len(HOTKEY_COMBINATION) * APPROX_CHAR_WIDTH

-- X-Position: Start at the icon's center, then move left by half the text's width.
local TEXT_POSITION_X = (ICON_POSITION_X + ICON_WIDTH / 2) - (TEXT_WIDTH / 2) - 1
-- Y-Position: Start at the icon's Y, add the icon's height, plus a small margin.
local TEXT_POSITION_Y = ICON_POSITION_Y + ICON_HEIGHT - 16
-- ######################################################

local magicWallIcon = nil
local hotkeyText = nil

-- This is the main function that performs the action.
local function shootMagicWall()
    if not Client.isConnected() then
        return
    end

    local targetId = Player.getTargetId()
    if not targetId or targetId == 0 then
        print(">> Magic Wall: No target selected.")
        return
    end

    if Game.getItemCount(MAGIC_WALL_RUNE_ID) <= 0 then
        print(">> Magic Wall: No Magic Wall runes found.")
        return
    end

    local targetCreature = Creature(targetId)
    if not targetCreature then
        return
    end

    local targetPos = targetCreature:getPosition()
    local targetDir = targetCreature:getDirection()

    local wallPos = { x = targetPos.x, y = targetPos.y, z = targetPos.z }

    if targetDir == Enums.Directions.NORTH then
        wallPos.y = wallPos.y - 2
    elseif targetDir == Enums.Directions.SOUTH then
        wallPos.y = wallPos.y + 2
    elseif targetDir == Enums.Directions.EAST then
        wallPos.x = wallPos.x + 2
    elseif targetDir == Enums.Directions.WEST then
        wallPos.x = wallPos.x - 2
    else
        print(">> Magic Wall: Target is facing diagonally.")
        return
    end

    print(">> Attempting to place Magic Wall at X:" .. wallPos.x .. ", Y:" .. wallPos.y)
    Game.useItemOnGround(MAGIC_WALL_RUNE_ID, wallPos.x, wallPos.y, wallPos.z)
end

-- This function listens for all hotkey presses.
local function onHotkeyPress(key, modifier)
    local success, configuredModifier, configuredKey = HotkeyManager.parseKeyCombination(HOTKEY_COMBINATION)
    if not success then
        return
    end

    if key == configuredKey and modifier == configuredModifier then
        shootMagicWall()
    end
end

local function load()
    -- Create the item icon for the HUD.
    magicWallIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, MAGIC_WALL_RUNE_ID, true)
    -- Create the text element for the HUD using our calculated coordinates.
    hotkeyText = HUD.new(TEXT_POSITION_X, TEXT_POSITION_Y, HOTKEY_COMBINATION, true)

    if magicWallIcon and hotkeyText then
        -- Make the item icon clickable.
        magicWallIcon:setCallback(shootMagicWall)

        -- Style the hotkey text.
        hotkeyText:setColor(200, 200, 200)

        -- Register the event listener for the keyboard hotkey.
        Game.registerEvent(Game.Events.HOTKEY_SHORTCUT_PRESS, onHotkeyPress)

        print(">> Magic Wall Hotkey HUD loaded. Press '" .. HOTKEY_COMBINATION .. "' or click the icon.")
    else
        print(">> ERROR: Failed to create Magic Wall Hotkey HUD.")
    end
end

local function unload()
    if magicWallIcon then
        magicWallIcon:destroy()
        magicWallIcon = nil
    end
    if hotkeyText then
        hotkeyText:destroy()
        hotkeyText = nil
    end
    Game.unregisterEvent(Game.Events.HOTKEY_SHORTCUT_PRESS, onHotkeyPress)
    print(">> Magic Wall Hotkey HUD unloaded.")
end

return {
    load = load,
    unload = unload
}
