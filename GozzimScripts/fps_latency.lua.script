-- FPS & Latency Display for Zerobot
-- Displays current FPS and color-coded latency in the top-left corner.

-- #################### CONFIGURATION ####################
-- How often to update the display (in milliseconds).
local UPDATE_INTERVAL_MS = 1000

-- Position for the display in the top-left corner.
local FPS_POS_X = 10
local FPS_POS_Y = 10
local LATENCY_POS_X = 10
local LATENCY_POS_Y = 30

-- Latency thresholds (in milliseconds) for color coding.
local GOOD_LATENCY_THRESHOLD = 150 -- Below this is green
local BAD_LATENCY_THRESHOLD = 300  -- Above this is red

-- Color definitions (R, G, B).
local COLOR_GOOD = { r = 100, g = 255, b = 100 } -- Light Green
local COLOR_OKAY = { r = 255, g = 255, b = 100 } -- Yellow
local COLOR_BAD = { r = 255, g = 100, b = 100 }  -- Light Red
local COLOR_FPS = { r = 200, g = 200, b = 200 }  -- Light Grey for FPS
-- ######################################################


-- State tracking variables
local fpsHud = nil
local latencyHud = nil
local lastLatencyColor = nil -- Tracks the current color to avoid unnecessary updates.

-- The main loop to update the display.
local function updateDisplay()
    if not Client.isConnected() then
        return
    end

    -- Update FPS Display
    if fpsHud then
        local currentFps = math.floor(Client.getFps())
        fpsHud:setText("FPS: " .. tostring(currentFps))
    end

    -- Update Latency Display
    if latencyHud then
        local currentLatency = Client.getLatency()
        latencyHud:setText("Ping: " .. tostring(currentLatency) .. "ms")

        local newColor
        if currentLatency <= GOOD_LATENCY_THRESHOLD then
            newColor = COLOR_GOOD
        elseif currentLatency > BAD_LATENCY_THRESHOLD then
            newColor = COLOR_BAD
        else
            newColor = COLOR_OKAY
        end

        -- Only update the color if it has changed to improve performance.
        if newColor ~= lastLatencyColor then
            latencyHud:setColor(newColor.r, newColor.g, newColor.b)
            lastLatencyColor = newColor
        end
    end
end

local function load()
    -- Create the HUD elements.
    fpsHud = HUD.new(FPS_POS_X, FPS_POS_Y, "FPS: ", true)
    latencyHud = HUD.new(LATENCY_POS_X, LATENCY_POS_Y, "Ping: ", true)

    if fpsHud and latencyHud then
        -- Set initial colors.
        fpsHud:setColor(COLOR_FPS.r, COLOR_FPS.g, COLOR_FPS.b)
        latencyHud:setColor(COLOR_OKAY.r, COLOR_OKAY.g, COLOR_OKAY.b)

        -- Run the update function once immediately to populate the fields.
        updateDisplay()

        -- Create a recurring timer that runs the main update loop.
        Timer.new("InfoDisplayTimer", updateDisplay, UPDATE_INTERVAL_MS, true)

        print(">> FPS & Latency Display script loaded.")
    else
        print(">> ERROR: Failed to create FPS & Latency HUDs.")
    end
end

local function unload()
    if fpsHud then
        fpsHud:destroy()
        fpsHud = nil
    end
    if latencyHud then
        latencyHud:destroy()
        latencyHud = nil
    end
    destroyTimer("InfoDisplayTimer")
    lastLatencyColor = nil
    print(">> FPS & Latency Display script unloaded.")
end

return {
    load = load,
    unload = unload
}
