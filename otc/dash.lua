local config = {
    enabled = true,

    hotkeys = {
        north = "W",
        south = "S",
        east = "D",
        west = "A"
    },

    -- Time in milliseconds between each step while holding down a key.
    -- Adjust this value if movement feels too slow.
    -- A value around your latency (ping) is often a good starting point.
    walkInterval = 50
}

-- Create a widget to capture key presses
local walkModule = g_ui.createWidget('walkModule')

local movementState = {
    north = false,
    south = false,
    east = false,
    west = false
}

macro(config.walkInterval, "Continuous Walk Loop", function()
    if not config.enabled or not g_game.isOnline() then
        return
    end

    if movementState.north then
        g_game.walk("north")
    elseif movementState.south then
        g_game.walk("south")
    elseif movementState.east then
        g_game.walk("east")
    elseif movementState.west then
        g_game.walk("west")
    end
end)

walkModule.onKeyDown = function(self, key)
    if not config.enabled then return false end

    if key == config.hotkeys.north then
        movementState.north = true
        return true
    elseif key == config.hotkeys.south then
        movementState.south = true
        return true
    elseif key == config.hotkeys.east then
        movementState.east = true
        return true
    elseif key == config.hotkeys.west then
        movementState.west = true
        return true
    end
    return false
end

walkModule.onKeyUp = function(self, key)
    if not config.enabled then return false end

    if key == config.hotkeys.north then
        movementState.north = false
        return true
    elseif key == config.hotkeys.south then
        movementState.south = false
        return true
    elseif key == config.hotkeys.east then
        movementState.east = false
        return true
    elseif key == config.hotkeys.west then
        movementState.west = false
        return true
    end
    return false
end