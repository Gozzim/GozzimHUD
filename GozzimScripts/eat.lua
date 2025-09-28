-- Auto-Eating Toggle HUD for Zerobot
-- Creates a clickable icon to toggle automatic food eating.
-- Will not eat while in a Protection Zone.

-- A prioritized list of Item IDs for the food you want to eat.
-- Example: { 3731, 3725, 3724 } -- Fire Mushroom, Brown Mushroom, Red Mushroom
local FOOD_ITEM_IDS = { 3731, 3725, 3724 }

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
-- This tracks the item ID currently displayed on the icon.
local currentIconId = nil

local function findValidFood()
    for _, foodId in ipairs(FOOD_ITEM_IDS) do
        if Game.getItemCount(foodId) > 0 then
            return foodId
        end
    end
    return nil
end

-- This function updates the icon to the best available food.
local function updateFoodIcon(foodIconId)
    if not foodIcon then
        return
    end

    if not foodIconId or foodIcon == nil then
        foodIconId = FOOD_ITEM_IDS[1]
    end

    if foodIconId ~= currentIconId then
        foodIcon:setItemId(foodIconId)
        currentIconId = foodIconId
    end
end

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

    -- Don't eat if in a protection zone or not hungry.
    if Player.getState(Enums.States.STATE_PIGEON) or not Player.isHungry() then
        return
    end

    local foodId = findValidFood()
    if foodId == nil then
        return
    end

    Game.useItem(foodId)
    updateFoodIcon(foodId)
end

local function load()
    -- Ensure there are food items configured.
    if #FOOD_ITEM_IDS == 0 then
        print(">> ERROR: No food items configured in eat.lua.")
        return
    end

    -- Create the HUD icon with a default item.
    foodIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, FOOD_ITEM_IDS[1], true)

    if foodIcon then
        foodIcon:setOpacity(OPACITY_ON)

        -- Set the correct initial icon based on inventory.
        updateFoodIcon(findValidFood())

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
