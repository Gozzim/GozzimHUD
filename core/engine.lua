--- Engine table to manage various engine functionalities.
Engine = {}

--- Returns if healing function is enabled
-- This function is a wrapper around the external function engineIsHealingEnabled.
function Engine.isHealingEnabled()
    return engineIsHealingEnabled()
end

--- Returns if heal friend function is enabled
-- This function is a wrapper around the external function return IsHealFriendEnabled.
function Engine.isHealFriendEnabled()
    return engineIsHealFriendEnabled()
end

--- Returns current bot version
-- This function is a wrapper around the external function engineGetBotVersion.
function Engine.getBotVersion()
    return engineGetBotVersion()
end

--- Returns if bot is enabled
-- This function is a wrapper around the external function engineIsBotEnabled.
function Engine.isBotEnabled()
    return engineIsBotEnabled()
end

--- Returns if targeting function is enabled
-- This function is a wrapper around the external function engineIsTargetingEnabled.
function Engine.isTargetingEnabled()
    return engineIsTargetingEnabled()
end

--- Returns if magic shooter function is enabled
-- This function is a wrapper around the external function engineIsMagicShooterEnabled.
function Engine.isMagicShooterEnabled()
    return engineIsMagicShooterEnabled()
end

--- Returns if cavebot function is enabled
-- This function is a wrapper around the external function engineIsCaveBotEnabled.
function Engine.isCaveBotEnabled()
    return engineIsCaveBotEnabled()
end

--- Returns if equipment function is enabled
-- This function is a wrapper around the external function engineIsEquipmentEnabled.
function Engine.isEquipmentEnabled()
    return engineIsEquipmentEnabled()
end

--- Returns if timer function is enabled
-- This function is a wrapper around the external function engineIsTimerEnabled.
function Engine.isTimerEnabled()
    return engineIsTimerEnabled()
end

--- Returns if auto SSA function is enabled. Refer to native function located on Tools -> PvP -> Auto SSA.
--- This function is a wrapper around the external function engineIsAutoSSAEnabled.
--- @return (boolean) - Returns true if the auto SSA function is enabled, false otherwise.
function Engine.isAutoSSAEnabled()
    return engineIsAutoSSAEnabled()
end

--- Returns if hold target function is enabled. Refer to native function located on Tools -> PvP -> Hold Target.
--- This function is a wrapper around the external function engineIsHoldTargetEnabled.
--- @return (boolean) - Returns true if the hold target function is enabled, false otherwise.
function Engine.isHoldTargetEnabled()
    return engineIsHoldTargetEnabled()
end

--- Returns if auto might ring function is enabled. Refer to native function located on Tools -> PvP -> Auto Might Ring.
--- This function is a wrapper around the external function engineIsAutoMightRingEnabled.
--- @return (boolean) - Returns true if the auto might ring function is enabled, false otherwise.
function Engine.isAutoMightRingEnabled()
    return engineIsAutoMightRingEnabled()
end

--- Returns if anti-push function is enabled. Refer to native function located on Tools -> PvP -> Anti-Push.
--- This function is a wrapper around the external function engineIsAntiPushEnabled.
--- @return (boolean) - Returns true if the anti-push function is enabled, false otherwise.
function Engine.isAntiPushEnabled()
    return engineIsAntiPushEnabled()
end

--- Returns if rune max function is enabled. Refer to native function located on Tools -> PvP -> Rune Max.
--- This function is a wrapper around the external function engineIsRuneMaxEnabled.
--- @return (boolean) - Returns true if the rune max function is enabled, false otherwise.
function Engine.isRuneMaxEnabled()
    return engineIsRuneMaxEnabled()
end

--- Returns if reconnect function is enabled. Refer to native function located on Tools -> Reconnect.
--- This function is a wrapper around the external function engineIsReconnectEnabled.
--- @return (boolean) - Returns true if the reconnect function is enabled, false otherwise.
function Engine.isReconnectEnabled()
    return engineIsReconnectEnabled()
end

--- Enables or disables the targeting system.
-- This function is a wrapper around the external function engineTargetingEnable.
-- @param enable (boolean) - A flag indicating whether to enable (true) or disable (false) the targeting system.
function Engine.enableTargeting(enable)
    engineTargetingEnable(enable)
end

--- Enables or disables the magic shooter system.
-- This function is a wrapper around the external function engineMagicShooterEnable.
-- @param enable (boolean) - A flag indicating whether to enable (true) or disable (false) the magic shooter system.
function Engine.enableMagicShooter(enable)
    engineMagicShooterEnable(enable)
end

--- Enables or disables the heal friend system.
-- This function is a wrapper around the external function engineHealFriendEnable.
-- @param enable (boolean) - A flag indicating whether to enable (true) or disable (false) the heal friend system.
function Engine.enableHealFriend(enable)
    engineHealFriendEnable(enable)
end

--- Enables or disables the healing system.
-- This function is a wrapper around the external function engineHealingEnable.
-- @param enable (boolean) - A flag indicating whether to enable (true) or disable (false) the healing system.
function Engine.enableHealing(enable)
    engineHealingEnable(enable)
end

--- Enables or disables the equipment system.
-- This function is a wrapper around the external function engineEquipmentEnable.
-- @param enable (boolean) - A flag indicating whether to enable (true) or disable (false) the equipment system.
function Engine.enableEquipment(enable)
    engineEquipmentEnable(enable)
end

--- Enables or disables the timer system.
-- This function is a wrapper around the external function engineTimerEnable.
-- @param enable (boolean) - A flag indicating whether to enable (true) or disable (false) the timer system.
function Engine.enableTimer(enable)
    engineTimerEnable(enable)
end

--- Enables or disables the cavebot system.
-- This function is a wrapper around the external function engineCaveBotEnable.
-- @param enable (boolean) - A flag indicating whether to enable (true) or disable (false) the cavebot system.
function Engine.enableCaveBot(enable)
    return engineCaveBotEnable(enable)
end

--- Enables or disables all bot functions.
-- This function is a wrapper around the external function engineBotEnable.
-- @param enable (boolean) - A flag indicating whether to enable (true) or disable (false) all bot functions.
function Engine.enableBot(enable)
    engineBotEnable(enable)
end

--- Switches the profile of magic shooter by index.
-- This function is a wrapper around the external function engineMagicShooterSwitchProfile.
-- @param profileIndex (number) - The index of the profile to switch to (from 0 to 9).
function Engine.magicShooterSwitchProfile(profileIndex)
    engineMagicShooterSwitchProfile(profileIndex)
end

--- Gets the current profile index selected on magic shooter.
-- This function is a wrapper around the external function engineMagicShooterGetProfile.
-- @return (number) - The index of current selected profile.
function Engine.magicShooterGetProfile()
    return engineMagicShooterGetProfile()
end

--- Gets the current magic shooter profile name.
--- This function is a wrapper around the external function engineMagicShooterGetProfileName.
--- @param index (number) - The index of the profile to get the name from (from 0 to 9).
--- @return (string) - The name of the current selected profile.
function Engine.magicShooterGetProfileName(index)
    return engineMagicShooterGetProfileName(index)
end

--- Enables or disables the auto SSA system. Refer to native function located on Tools -> PvP -> Auto SSA.
--- This function is a wrapper around the external function engineAutoSSAEnable.
--- @param enable (boolean) - A flag indicating whether to enable (true) or disable (false) the auto SSA system.
function Engine.autoSSAEnable(enable)
    engineAutoSSAEnable(enable)
end

--- Enables or disables the hold target system. Refer to native function located on Tools -> PvP -> Hold Target.
--- This function is a wrapper around the external function engineHoldTargetEnable.
--- @param enable (boolean) - A flag indicating whether to enable (true) or disable (false) the hold target system.
function Engine.holdTargetEnable(enable)
    engineHoldTargetEnable(enable)
end

--- Enables or disables the auto might ring system. Refer to native function located on Tools -> PvP -> Auto Might Ring.
--- This function is a wrapper around the external function engineAutoMightRingEnable.
--- @param enable (boolean) - A flag indicating whether to enable (true) or disable (false) the auto might ring system.
function Engine.autoMightRingEnable(enable)
    engineAutoMightRingEnable(enable)
end

--- Enables or disables the anti-push system. Refer to native function located on Tools -> PvP -> Anti-Push.
--- This function is a wrapper around the external function engineAntiPushEnable.
--- @param enable (boolean) - A flag indicating whether to enable (true) or disable (false) the anti-push system.
function Engine.antiPushEnable(enable)
    engineAntiPushEnable(enable)
end

--- Sets the first anti-push id. Refer to native function located on Tools -> PvP -> Anti-Push.
--- This function is a wrapper around the external function engineSetFirstAntiPushId.
--- @param itemId (number) - The first anti-push item id to set.
function Engine.setFirstAntiPushId(itemId)
    engineSetFirstAntiPushId(itemId)
end

--- Sets the second anti-push id. Refer to native function located on Tools -> PvP -> Anti-Push.
--- This function is a wrapper around the external function engineSetSecondAntiPushId.
--- @param itemId (number) - The second anti-push item id to set.
function Engine.setSecondAntiPushId(itemId)
    engineSetSecondAntiPushId(itemId)
end

--- Enables or disables the rune max system. Refer to native function located on Tools -> PvP -> Rune Max.
--- This function is a wrapper around the external function engineRuneMaxEnable.
--- @param enable (boolean) - A flag indicating whether to enable (true) or disable (false) the rune max system.
function Engine.runeMaxEnable(enable)
    engineRuneMaxEnable(enable)
end

--- Enables or disables the reconnect system. Refer to native function located on Tools -> Reconnect.
--- This function is a wrapper around the external function engineReconnectEnable.
--- @param enable (boolean) - A flag indicating whether to enable (true) or disable (false) the reconnect system.
function Engine.reconnectEnable(enable)
    engineReconnectEnable(enable)
end

--- Gets the current rune max id. Refer to native function located on Tools -> PvP -> Rune Max.
--- This function is a wrapper around the external function engineGetRuneMaxId.
--- @return (number) - The current rune max id.
function Engine.getRuneMaxId()
    return engineGetRuneMaxId()
end

--- Sets the current rune max id. Refer to native function located on Tools -> PvP -> Rune Max.
--- This function is a wrapper around the external function engineSetRuneMaxId.
--- @param runeMaxId (number) - The rune max id to set.
function Engine.setRuneMaxId(runeMaxId)
    engineSetRuneMaxId(runeMaxId)
end

--- Switches the profile of targeting by index.
-- This function is a wrapper around the external function engineTargetingSwitchProfile.
-- @param profileIndex (number) - The index of the profile to switch to (from 0 to 9).
function Engine.targetingSwitchProfile(profileIndex)
    engineTargetingSwitchProfile(profileIndex)
end

--- Gets the current profile index selected on targeting.
-- This function is a wrapper around the external function engineTargetingGetProfile.
-- @return (number) - The index of current selected profile.
function Engine.targetingGetProfile()
    return engineTargetingGetProfile()
end

--- Gets the current targeting profile name.
-- This function is a wrapper around the external function engineTargetingGetProfileName.
-- @param index (number) - The index of the profile to get the name from (from 0 to 9).
-- @return (string) - The name of the current selected profile.
function Engine.targetingGetProfileName(index)
    return engineTargetingGetProfileName(index)
end

--- Switches the profile of equipment by index.
-- This function is a wrapper around the external function engineEquipmentSwitchProfile.
-- @param profileIndex (number) - The index of the profile to switch to (from 0 to 9).
function Engine.equipmentSwitchProfile(profileIndex)
    engineEquipmentSwitchProfile(profileIndex)
end

--- Gets the current profile index selected on equipment.
-- This function is a wrapper around the external function engineEquipmentGetProfile.
-- @return (number) - The index of current selected profile.
function Engine.equipmentGetProfile()
    return engineEquipmentGetProfile()
end

--- Gets the current equipment profile name.
-- This function is a wrapper around the external function engineEquipmentGetProfileName.
-- @param index (number) - The index of the profile to get the name from (from 0 to 9).
-- @return (string) - The name of the current selected profile.
function Engine.equipmentGetProfileName(index)
    return engineEquipmentGetProfileName(index)
end

--- Switches the profile of healing by index.
--- This function is a wrapper around the external function engineHealingSwitchProfile.
--- @param profileIndex (number) - The index of the profile to switch to (from 0 to 9).
function Engine.healingSwitchProfile(profileIndex)
    engineHealingSwitchProfile(profileIndex)
end

--- Gets the current profile index selected on healing.
--- This function is a wrapper around the external function engineHealingGetProfile.
--- @return (number) - The index of current selected profile.
function Engine.healingGetProfile()
    return engineHealingGetProfile()
end

--- Gets the current healing profile name.
--- This function is a wrapper around the external function engineHealingGetProfileName.
--- @param index (number) - The index of the profile to get the name from (from 0 to 9).
--- @return (string) - The name of the current selected profile.
function Engine.healingGetProfileName(index)
    return engineHealingGetProfileName(index)
end

--- Gets the default scripts directory.
-- This function is a wrapper around the external function engineGetScriptsDirectory.
-- @return (string) - The path to default scripts directory.
function Engine.getScriptsDirectory()
    return engineGetScriptsDirectory()
end

--- Returns a hashed version of the user's email to be used as a unique user ID.
-- This function is useful to identify current user. You can use engineGetUserId directly if you need to avoid hooks.
-- @param lowerCase - If true, the email will be converted to lowercase before hashing, ensuring case insensitivity in the generated hash.
function Engine.getUserId(lowerCase)
    lowerCase = lowerCase or false
    return engineGetUserId(lowerCase)
end

--- Gets the remaining time of the license.
--- This function is a wrapper around the external function engineGetLicenseTime.
--- To allow this function, the user should consent to share this information with the script by enabling "Allow Scripts Access License Time" on Engine tab.
--- @return (string) - The last visible license time from ZeroBot overview tab. If this information is not available, it will return nil.
function Engine.getLicenseTime()
    return engineGetLicenseTime()
end

--- Enables or disables specific alarm type.
--- @param alarmType (number) - The alarm type to enable or disable.
--- @param enable (boolean) - A flag indicating whether to enable (true) or disable (false) the alarm type.
function Engine.setAlarm(alarmType, enable)
    engineSetAlarm(alarmType, enable)
end

--- Get the status of a specific alarm type.
--- @param alarmType (number) - The alarm type to check. Refer to Enums.AlarmType.
--- @return (boolean) - Returns true if the alarm type is enabled, false otherwise.
function Engine.isAlarmEnabled(alarmType)
    return engineIsAlarmEnabled(alarmType)
end

--- Check if all alarms are disabled.
--- This function is a wrapper around the external function engineIsAllAlarmsDisabled.
--- @return (boolean) - Returns true if all alarms are disabled, false otherwise.
function Engine.isAllAlarmsDisabled()
    return engineIsAllAlarmsDisabled()
end

--- Load specific script.
-- This function is a wrapper around the external function engineLoadScript.
-- This function runs asynchronously, so it may take some time to load the script, so if you will use Engine.unloadScript right after this function, you should wait for the script to be loaded, wait some delay.
-- @param scriptName (string) - The name of the script to load. This name is based on "Available Scripts" list in "Scripting" tab.
-- @return (boolean) - Returns true if the script is loaded successfully, false if the script doesn't exists.
function Engine.loadScript(scriptName)
    return engineLoadScript(scriptName)
end

--- Unload specific script.
-- This function is a wrapper around the external function engineUnloadScript.
-- @param scriptName (string) - The name of the script to unload. This name is based on "Enabled Scripts" list in "Scripting" tab.
-- @return (boolean) - Returns true if the script was unloaded successfully, false if the script doesn't exists.
function Engine.unloadScript(scriptName)
    return engineUnloadScript(scriptName)
end

--- Reload specific script.
--- This function is a wrapper around the external function engineReloadScript.
--- @param scriptName (string) - The name of the script to reload. This name is based on "Enabled Scripts" list in "Scripting" tab.
--- @return (boolean) - Returns true if the script was reloaded successfully, false if the script doesn't exists.
function Engine.reloadScript(scriptName)
    return engineReloadScript(scriptName)
end

--- Load specific configuration by name. For privacy reasons we don't have a function to list available configurations.
--- This function is a wrapper around the external function engineLoadConfig.
--- @param config (string) - The name of the config file to load. This name is based on available configurations list in "Settings" tab.
function Engine.loadConfig(config)
    return engineLoadConfig(config)
end

--- Check if a specific script is loaded.
--- This function is a wrapper around the external function engineIsScriptLoaded.
--- @param scriptName (string) - The name of the script to check. This name is based on "Enabled Scripts" list in "Scripting" tab.
--- @return (boolean) - Returns true if the script is loaded, false otherwise.
function Engine.isScriptLoaded(scriptName)
    return engineIsScriptLoaded(scriptName)
end