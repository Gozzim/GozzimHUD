-- Auto-Eating Toggle HUD for Zerobot
-- Creates a clickable icon to toggle automatic food eating.
-- Will not eat while in a Protection Zone.

-- #################### CONFIGURATION ####################
-- The Item ID for the food you want to eat.
-- 3731 = Fire Mushroom
local FOOD_ITEM_ID = 3731

-- How often the script checks if you are hungry (in milliseconds).
local EAT_INTERVAL_MS = 1000 -- Check every 1 second

-- Position of the icon on the screen.
local ICON_POSITION_X = 10
local ICON_POSITION_Y = 160

-- Opacity for the icon when ON vs OFF.
local OPACITY_ON = 1.0  -- Fully visible
local OPACITY_OFF = 0.5 -- Semi-transparent
-- ######################################################


-- This variable tracks whether auto-eating is active.
local isAutoEatingActive = true

-- This will hold our HUD object.
local foodIcon = nil

-- This function is called when the HUD icon is clicked.
local function toggleFoodEating()
    -- Flip the active state.
    isAutoEatingActive = not isAutoEatingActive

    if isAutoEatingActive then
        -- Set icon to fully visible and print a message.
        foodIcon:setOpacity(OPACITY_ON)
        print(">> Auto-Eating ENABLED.")
    else
        -- Set icon to semi-transparent and print a message.
        foodIcon:setOpacity(OPACITY_OFF)
        print(">> Auto-Eating DISABLED.")
    end
end

-- This function is run by the timer to check if we need to eat.
local function eatFoodIfNeeded()
    -- Only proceed if auto-eating is enabled and the client is connected.
    if not isAutoEatingActive or not Client.isConnected() then
        return
    end

    -- Check all conditions before eating.
    local canEat = true
    if Player.getState(Enums.States.STATE_PIGEON) then
        canEat = false -- In a protection zone.
    elseif not Player.isHungry() then
        canEat = false -- Not hungry.
    elseif Game.getItemCount(FOOD_ITEM_ID) <= 0 then
        canEat = false -- No food found.
    end

    -- If all checks passed, use the food item.
    if canEat then
        Game.useItem(FOOD_ITEM_ID)
        print(">> Eating food.")
    end
end

local function load()
    -- Create the HUD icon using the food item ID and position from the config.
    foodIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, FOOD_ITEM_ID, true)

    if foodIcon then
        foodIcon:setOpacity(OPACITY_ON)

        -- Assign our toggleFoodEating function to be called when the icon is clicked.
        foodIcon:setCallback(toggleFoodEating)

        -- Create a recurring timer that calls eatFoodIfNeeded.
        Timer.new("FoodTimer", eatFoodIfNeeded, EAT_INTERVAL_MS, true)

        print(">> Auto-Eating HUD loaded.")
    else
        print(">> ERROR: Failed to create Auto-Eating HUD.")
    end
end

local function unload()
    if foodIcon then
        foodIcon:destroy()
        foodIcon = nil
    end
    destroyTimer("FoodTimer")
    print(">> Auto-Eating HUD unloaded.")
end

return {
    load = load,
    unload = unload
}
