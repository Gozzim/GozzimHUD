-- GozzimHUD Main Controller
-- Loads and manages all individual GozzimScripts.

local SCRIPTS_FOLDER = "GozzimScripts/"
local STORAGE_FOLDER = "GozzimScripts/Storage/"

-- Item ID for the main settings icon.
local SETTINGS_ICON_ID = 9153

-- Position of the main settings icon on the screen.
local gameWindow = Client.getGameWindowDimensions()
local ICON_POSITION_X = 10
local ICON_POSITION_Y = gameWindow.height - 42

-- Global variable to control settings icon visibility in subscripts
_G.GozzimHUD_ShowSettingsIcon = true

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
}

-- Runtime state variables
local settingsIcon = nil
local settingsModal = nil
local charInfoModule = nil

-- Initialize runtime state for each script
for i, script in ipairs(allScripts) do
    script.module = nil
    script.isLoaded = false
end

-- Forward declarations for script loading functions
local loadScript, unloadScript

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
    states["GozzimHUD_ShowSettingsIcon"] = _G.GozzimHUD_ShowSettingsIcon

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
            if states["GozzimHUD_ShowSettingsIcon"] ~= nil then
                _G.GozzimHUD_ShowSettingsIcon = states["GozzimHUD_ShowSettingsIcon"]
            end
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

-- Main function to open the settings panel.
local openSettingsModal

-- Callback for modal button clicks.
local function onModalButtonClick(buttonIndex)
    if buttonIndex == #allScripts then
        _G.GozzimHUD_ShowSettingsIcon = not _G.GozzimHUD_ShowSettingsIcon
        
        -- Reload active scripts that use settings icons so they update
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

    local scriptIndex = buttonIndex + 1
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

    for i, script in ipairs(allScripts) do
        local status = script.isLoaded and '<font color="#00FF00">ON</font>' or '<font color="#FF6666">OFF</font>'
        local buttonText = string.format("%s: %s", script.name, status)
        settingsModal:addButton(buttonText)
    end

    local iconStatus = _G.GozzimHUD_ShowSettingsIcon and '<font color="#00FF00">ON</font>' or '<font color="#FF6666">OFF</font>'
    settingsModal:addButton("Settings Icons: " .. iconStatus)
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
    settingsIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, SETTINGS_ICON_ID, true)
    if settingsIcon then
        settingsIcon:setCallback(openSettingsModal)
    end

    loadScriptStates() -- Load states first so we get GozzimHUD_ShowSettingsIcon

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

    if settingsIcon then
        settingsIcon:destroy()
        settingsIcon = nil
    end

    if settingsModal then
        settingsModal:destroy()
        settingsModal = nil
    end

    print(">> GozzimHUD Controller unloaded successfully.")
end

-- The script starts here by calling the main load function.
loadController()

-- Provide the unload function globally so it can be called if the script is reloaded.
GozzimHUD_Unload = unloadController
