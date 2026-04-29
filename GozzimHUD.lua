-- GozzimHUD Main Controller
-- Loads and manages all individual GozzimScripts.

local SCRIPTS_FOLDER = "GozzimScripts/"
local STORAGE_FOLDER = "GozzimScripts/Storage/"

-- Item IDs for the HUD icons
local CONFIG_TOGGLE_ICON_ID = 9153
local SETTINGS_ICON_ID = 9654

-- Position of the icons on the screen.
local gameWindow = Client.getGameWindowDimensions()
local ICON_POSITION_X = 10
local ICON_POSITION_Y = gameWindow.height - 42
local SPACING = 40

-- Global variables to control icon visibility
_G.GozzimHUD_ShowMasterIcons = true -- Controls Main Settings & Char Info
_G.GozzimHUD_ShowSettingsIcon = true -- Controls Subscript Icons (derived from Master + Subscript setting)

-- Internal user preference for subscript icons specifically
local subscriptIconsSetting = true

-- List of all manageable scripts.
local allScripts = {
    { name = "Eat", file = "eat.lua.script", defaultState = true },
    { name = "Rage", file = "rage.lua.script", defaultState = false },
    { name = "Open Doors", file = "doors.lua.script", defaultState = true },
    { name = "Exiva", file = "exiva.lua.script", defaultState = true },
    { name = "Oberon", file = "oberon.lua.script", defaultState = true },
    { name = "Fishing", file = "fishing.lua.script", defaultState = true },
    { name = "Skinner", file = "skinner.lua.script", defaultState = true },
    { name = "Autoloot", file = "autoloot.lua.script", defaultState = true },
    { name = "Anti-Push", file = "anti_push.lua.script", defaultState = true },
    { name = "Haste", file = "autohaste.lua.script", defaultState = true },
    { name = "Autoshoot", file = "autoshoot.lua.script", defaultState = false },
    { name = "Hold Target", file = "holdtarget.lua.script", defaultState = true },
    { name = "MWall", file = "shootmwall.lua.script", defaultState = true },
    { name = "FPS/Ping", file = "fps_latency.lua.script", defaultState = true },
    { name = "SSA/Might", file = "auto_ssa_might.lua.script", defaultState = true },
    { name = "Effects", file = "toggle_effects.lua.script", defaultState = true },
    { name = "Exercise", file = "training.lua.script", defaultState = true },
    { name = "Anti-Drunk", file = "anti_drunk.lua.script", defaultState = true },
}

-- Runtime state variables
local configToggleIcon = nil
local configToggleText = nil
local settingsIcon = nil
local settingsModal = nil
local charInfoModule = nil

-- Initialize runtime state for each script
for _, script in ipairs(allScripts) do
    script.module = nil
    script.isLoaded = false
end

-- Forward declarations
local loadScript, unloadScript, openSettingsModal

-- Helper to update visibility of Settings and Char Info icons
local function updateIconVisibility()
    if settingsIcon then
        if _G.GozzimHUD_ShowMasterIcons then
            settingsIcon:show()
        else
            settingsIcon:hide()
        end
    end

    -- Trigger char info update if the module registered a global callback
    if _G.CharInfo_UpdateIconVisibility then
        _G.CharInfo_UpdateIconVisibility()
    end
end

-- Helper to update the state of the toggle icon itself
local function updateToggleIconState()
    if configToggleIcon and configToggleText then
        if _G.GozzimHUD_ShowMasterIcons then
            configToggleIcon:setOpacity(1.0)
            configToggleText:setText("Configs")
            configToggleText:setColor(0, 255, 0) -- Green
        else
            configToggleIcon:setOpacity(0.6)
            configToggleText:setText("Configs")
            configToggleText:setColor(255, 102, 102) -- Red
        end
    end
end

local function getStorageFileName(scriptName)
    local worldName = Client.getWorldName()
    local charName = Player.getName()

    -- Trim and replace spaces and colons
    worldName = worldName:gsub("^%s*(.-)%s*$", "%1"):gsub("%s", "_"):gsub(":", ".")
    charName = charName:gsub("^%s*(.-)%s*$", "%1"):gsub("%s", "_"):gsub(":", ".")

    return string.format("%s_%s_%s.json", worldName, charName, scriptName)
end

local function saveScriptStates()
    local states = {}
    for _, script in ipairs(allScripts) do
        states[script.name] = script.isLoaded
    end

    states["SubscriptIconsSetting"] = subscriptIconsSetting
    states["MasterIconsSetting"] = _G.GozzimHUD_ShowMasterIcons

    local fileName = getStorageFileName("GozzimHUD")
    local filePath = Engine.getScriptsDirectory() .. "/" .. STORAGE_FOLDER .. fileName
    local file = io.open(filePath, "w")
    if file then
        file:write(JSON.encode(states))
        file:close()
    end
end

local function loadScriptStates()
    local fileName = getStorageFileName("GozzimHUD")
    local filePath = Engine.getScriptsDirectory() .. "/" .. STORAGE_FOLDER .. fileName
    local file = io.open(filePath, "r")
    if file then
        local content = file:read("*a")
        file:close()
        local states = JSON.decode(content)
        if states then
            -- Load new distinct properties, or fallback to legacy variable if migrating
            if states["SubscriptIconsSetting"] ~= nil then
                subscriptIconsSetting = states["SubscriptIconsSetting"]
            elseif states["GozzimHUD_ShowSettingsIcon"] ~= nil then
                subscriptIconsSetting = states["GozzimHUD_ShowSettingsIcon"]
            end

            if states["MasterIconsSetting"] ~= nil then
                _G.GozzimHUD_ShowMasterIcons = states["MasterIconsSetting"]
            end

            -- Derive the actual subscript visibility based on both preferences
            _G.GozzimHUD_ShowSettingsIcon = subscriptIconsSetting and _G.GozzimHUD_ShowMasterIcons

            for i, script in ipairs(allScripts) do
                if states[script.name] and not script.isLoaded then
                    loadScript(i)
                elseif not states[script.name] and script.isLoaded then
                    unloadScript(i)
                end
            end
        end
        return true -- States loaded
    end
    return false -- No states file
end

-- Tries to load a script module by its file name.
loadScript = function(scriptIndex)
    local script = allScripts[scriptIndex]
    if not script or script.isLoaded then
        return
    end

    local filePath = Engine.getScriptsDirectory() .. "/" .. SCRIPTS_FOLDER .. script.file

    local chunk, compileError = loadfile(filePath)
    if not chunk then
        print(string.format("!! ERROR compiling module %s: %s", script.file, tostring(compileError)))
        return
    end

    local success, module = pcall(chunk)

    if success and type(module) == "table" and module.load then
        script.module = module
        script.module.load()
        script.isLoaded = true
        print(string.format(">> Loaded module: %s", script.name))
    else
        print(string.format("!! ERROR loading module %s: %s", script.file, tostring(module)))
    end
end

-- Unloads a script module.
unloadScript = function(scriptIndex)
    local script = allScripts[scriptIndex]
    if not script or not script.isLoaded or not script.module then
        return
    end

    if script.module.unload then
        script.module.unload()
    end

    script.module = nil
    script.isLoaded = false
    print(string.format(">> Unloaded module: %s", script.name))
end

-- Central function to toggle config icons
local function toggleConfigIcons()
    _G.GozzimHUD_ShowMasterIcons = not _G.GozzimHUD_ShowMasterIcons

    -- Subscripts are only visible if the master toggle AND their individual setting are ON
    _G.GozzimHUD_ShowSettingsIcon = subscriptIconsSetting and _G.GozzimHUD_ShowMasterIcons

    updateIconVisibility()
    updateToggleIconState()

    -- Reload active scripts that use settings icons so they update
    for i, script in ipairs(allScripts) do
        if script.isLoaded and (script.name == "Autoshoot" or script.name == "Haste" or script.name == "SSA/Might") then
            unloadScript(i)
            loadScript(i)
        end
    end
    saveScriptStates()
end

-- Callback for modal button clicks.
local function onModalButtonClick(buttonIndex)
    if buttonIndex == 0 then
        -- Toggle ONLY the subscript icons setting
        subscriptIconsSetting = not subscriptIconsSetting
        _G.GozzimHUD_ShowSettingsIcon = subscriptIconsSetting and _G.GozzimHUD_ShowMasterIcons

        -- Reload active scripts that use subscript settings icons
        for i, script in ipairs(allScripts) do
            if script.isLoaded and (script.name == "Autoshoot" or script.name == "Haste" or script.name == "SSA/Might") then
                unloadScript(i)
                loadScript(i)
            end
        end
        openSettingsModal()
        return
    elseif buttonIndex == #allScripts + 1 then
        if settingsModal then
            saveScriptStates()
            settingsModal:destroy()
            settingsModal = nil
        end
        return
    end

    local scriptIndex = buttonIndex
    local script = allScripts[scriptIndex]
    if script.isLoaded then
        unloadScript(scriptIndex)
    else
        loadScript(scriptIndex)
    end

    openSettingsModal()
end

-- Definition of the function to open the settings modal.
openSettingsModal = function()
    if settingsModal then
        settingsModal:destroy()
    end

    settingsModal = CustomModalWindow("GozzimHUD Scripts", "Toggle scripts on or off.")

    -- The text in the modal represents the subscript preference
    local iconStatus = subscriptIconsSetting and '<font color="#00FF00">ON</font>' or '<font color="#FF6666">OFF</font>'
    settingsModal:addButton("ConfigIcons: " .. iconStatus)

    for _, script in ipairs(allScripts) do
        local status = script.isLoaded and '<font color="#00FF00">ON</font>' or '<font color="#FF6666">OFF</font>'
        local buttonText = string.format("%s: %s", script.name, status)
        settingsModal:addButton(buttonText)
    end

    settingsModal:addButton("Save & Close")
    settingsModal:setCallback(onModalButtonClick)
end

-- Main load function for the entire HUD controller.
local function loadController()
    if not Player.hasReceivedBasicData() then
        print(">> Waiting for basic player data...")
        Timer.new("GozzimHUD_LoadRetry", loadController, 500, false)
        return
    end

    print(">> GozzimHUD Controller loading...")

    -- Load the new Config Toggle Icon and its text
    configToggleIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, CONFIG_TOGGLE_ICON_ID, true)
    configToggleText = HUD.new(ICON_POSITION_X, ICON_POSITION_Y + 34, "ConfigIcons Enabled", true)

    if configToggleIcon then
        configToggleIcon:setCallback(toggleConfigIcons)
    end

    -- Load the Main Settings Icon (Moved to the right by SPACING)
    settingsIcon = HUD.new(ICON_POSITION_X + SPACING, ICON_POSITION_Y, SETTINGS_ICON_ID, true)
    if settingsIcon then
        settingsIcon:setCallback(openSettingsModal)
    end

    loadScriptStates() -- Load states first so we get states synchronized
    updateIconVisibility() -- Ensure correct initial visibility
    updateToggleIconState() -- Ensure initial text and opacity are correct

    -- Load the Char Info script by default
    local charInfoPath = Engine.getScriptsDirectory() .. "/" .. SCRIPTS_FOLDER .. "char_info.lua.script"
    local chunk, err = loadfile(charInfoPath)
    if chunk then
        local success, module = pcall(chunk)
        if success and type(module) == "table" and module.load then
            charInfoModule = module
            charInfoModule.load()
            print(">> Loaded module: Char Info")
        end
    else
        print("!! ERROR loading module char_info.lua.script: " .. tostring(err))
    end

    -- Determine vocation for default script loading if states weren't loaded properly
    local player = Creature(Player.getId())
    local vocation = player and player:getVocation() or Enums.Vocations.NONE
    local isKnight = (vocation == Enums.Vocations.KNIGHT or vocation == Enums.Vocations.ELITE_KNIGHT)

    for i, script in ipairs(allScripts) do
        -- Only load if it's not already loaded (might have been loaded by loadScriptStates)
        if not script.isLoaded then
            local shouldLoad = script.defaultState
            if script.name == "Rage" then
                shouldLoad = isKnight
            elseif script.name == "Autoshoot" then
                shouldLoad = not isKnight
            end

            -- If there was no saved state, load the default
            local hasSavedState = false
            local fileName = getStorageFileName("GozzimHUD")
            local filePath = Engine.getScriptsDirectory() .. "/" .. STORAGE_FOLDER .. fileName
            local file = io.open(filePath, "r")
            if file then
                local content = file:read("*a")
                file:close()
                local states = JSON.decode(content)
                if states and states[script.name] ~= nil then
                    hasSavedState = true
                end
            end

            if not hasSavedState and shouldLoad then
                loadScript(i)
            end
        end
    end

    print(">> GozzimHUD Controller loaded successfully.")
end

-- Main unload function for the entire HUD controller.
local function unloadController()
    print(">> GozzimHUD Controller unloading...")
    for i, script in ipairs(allScripts) do
        if script.isLoaded then
            unloadScript(i)
        end
    end

    -- Unload the char info module
    if charInfoModule and charInfoModule.unload then
        charInfoModule.unload()
        charInfoModule = nil
    end

    if configToggleIcon then
        configToggleIcon:destroy()
        configToggleIcon = nil
    end

    if configToggleText then
        configToggleText:destroy()
        configToggleText = nil
    end

    if settingsIcon then
        settingsIcon:destroy()
        settingsIcon = nil
    end

    if settingsModal then
        settingsModal:destroy()
        settingsModal = nil
    end

    _G.CharInfo_UpdateIconVisibility = nil

    print(">> GozzimHUD Controller unloaded successfully.")
end

-- The script starts here by calling the main load function.
loadController()

-- Provide the unload function globally so it can be called if the script is reloaded.
GozzimHUD_Unload = unloadController
