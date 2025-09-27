-- Disable Magic Effects Hotkey Button
-- Clicks the hotkey assigned to the "Disable Magic Effects" function.
-- This version acts as a button only, as the on/off state cannot be read by the script.

-- #################### CONFIGURATION ####################
-- The EXACT key you assigned in ZeroBot's Hotkey Manager for this function.
local TOGGLE_HOTKEY = "l"

-- Item ID for the HUD icon.
local ICON_ITEM_ID = 3248

-- Position of the icon on the screen, next to the anti-push icon.
local ICON_POSITION_X = 50
local ICON_POSITION_Y = 520

-- ######################################################


-- This will hold our HUD object.
local effectsButtonIcon = nil

-- This function is called when the HUD icon is clicked.
local function pressToggleHotkey()
    print(">> Simulating '" .. TOGGLE_HOTKEY .. "' key press to toggle magic effects.")

    -- Parse the hotkey string to get its key code and modifier.
    local success, modifier, key = HotkeyManager.parseKeyCombination(TOGGLE_HOTKEY)

    if success then
        -- Send the key press event to the client.
        Client.sendHotkey(key, modifier)
    else
        print(">> ERROR: Could not parse the configured hotkey: '" .. TOGGLE_HOTKEY .. "'")
    end
end

-- ################# SCRIPT INITIALIZATION #################

-- Create the HUD icon.
effectsButtonIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, ICON_ITEM_ID, true)

if effectsButtonIcon then
    -- Assign our pressToggleHotkey function to be called when the icon is clicked.
    effectsButtonIcon:setCallback(pressToggleHotkey)

    print(">> Magic Effects Button HUD loaded. Click the ring icon to press '" .. TOGGLE_HOTKEY .. "'.")
else
    print(">> ERROR: Failed to create Magic Effects Button HUD.")
end