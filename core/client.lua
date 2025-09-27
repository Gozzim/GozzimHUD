Client = {}

--- Check if the client is currently connected.
-- This function is a wrapper around the external function clientIsConnected.
-- @return true if the client is currently connected, false otherwise.
function Client.isConnected()
    return clientIsConnected()
end

--- Check if a specified hotkey is currently pressed.
-- This function is a wrapper around the external function clientIsKeyPressed.
-- @param key (number) - The key code. Example: A (0x65)
-- @param flags (string) - The flags for modifiers. Refer the parameter value as Enums.FlagModifiers, apply bit or operation for multiple flags
-- @return true if the specified key is currently pressed, false otherwise.
function Client.isKeyPressed(key, flags)
	return clientIsKeyPressed(key, flags)
end

--- Show a message on center of game screen.
-- This function is a wrapper around the external function clientShowMessage.
-- @param message (string) - The message to be shown
function Client.showMessage(message)
	clientShowMessage(message)
end

--- Disconnects the client using X-Log native function.
-- This function is a wrapper around the external function clientXLog.
function Client.XLog()
	clientXLog()
end

--- Get client game window dimensions.
-- This function is a wrapper around the external function clientGetGameWindowDimensions.
-- @return the following structure in table {x=0,y=0,width=0,height=0}
function Client.getGameWindowDimensions()
	return clientGetGameWindowDimensions()
end

--- Get the current latency from the client latency indicator UI.
-- This function is a wrapper around the external function clientGetLatency.
-- @return The current latency in milliseconds, if the information isn't available will return -1.
function Client.getLatency()
	return clientGetLatency()
end

--- Get the current latency from the server.
-- This function is a wrapper around the external function clientGetServerLatency.
-- @return The current server latency in milliseconds, if the information isn't available will return 0.
function Client.getServerLatency()
	return clientGetServerLatency()
end

--- Get the loot black/white list json content.
--- This function is a wrapper around the external function clientGetLootBlackWhitelist.
--- @param playerId (number) - The player id to get the loot black/white list.
--- @return The loot black/white list json content, if the information isn't available will return an empty string.
function Client.getLootBlackWhitelist(playerId)
	return clientGetLootBlackWhitelist(playerId)
end

--- Set the loot black/white list json content.
--- This function is a wrapper around the external function clientSetLootBlackWhitelist.
--- @param playerId (number) - The player id to replace the loot black/white list.'
--- @param content (string) - The json content to be set.
function Client.setLootBlackWhitelist(playerId, content)
	clientSetLootBlackWhitelist(playerId, content)
end

--- Get all items data available from the client.
--- This function is a wrapper around the external function clientGetAllItems.
--- @return The items data in table format, every item will contains id and flags field, but some items can have extra data depending of it type. All informations can be based on this project: https://github.com/Arch-Mina/Assets-Editor
--- The flags field is a bitwise representation of the item flags, you can use the Enums.ThingFlagAttr to get the item flags.
--- Example: local isGround = bit.band(item.flags, Enums.ThingFlagAttr.Ground) ~= 0
function Client.getAllItems()
	return clientGetAllItems()
end

--- Get the current OT world name. This function is experimental, please test it before the usage to see if it's compatible with the OT target version.
--- This function is a wrapper around the external function clientGetWorldName.
--- @return The current OT world name, if the information isn't available will return an empty string.
function Client.getWorldName()
	return clientGetWorldName()
end

--- Login into the client using the provided email, password and character index.
--- IMPORTANT: The developer should check if the character can logout, this function logout's the character first and then login into the specified credentials.
--- This function is a wrapper around the external function clientLogin.
--- @param email (string) - The email to be used for login.
--- @param password (string) - The password to be used for login.
--- @param characterIndex (number) - The character index to be used for login.
function Client.login(email, password, characterIndex)
	clientLogin(email, password, characterIndex)
end

--- Send logout action to server.
--- This function is a wrapper around the external function clientLogout.
--- @return true if the logout action was sent to server, false otherwise.
function Client.logout()
	return clientLogout()
end

--- Focus the client window.
-- This function is a wrapper around the external function clientFocus.
-- Note from Windows documentation: An application cannot force a window to the foreground while the user is working with another window. Instead, Windows flashes the taskbar button of the window to notify the user.
function Client.focus()
	clientFocus()
end

-- Send a key press event to the client.
-- This function is a wrapper around the external function clientSendHotkey.
-- You can base the key and modifier params on HotkeyManager.parseKeyCombination function returns.
-- @param key (number) - The key code.
-- @param modifier (number) - The modifier flags.
function Client.sendHotkey(key, modifier)
	local gameModifier = 0
	if bit.band(modifier, Enums.FlagModifiers.SHIFT) == Enums.FlagModifiers.SHIFT then
		gameModifier = bit.bor(gameModifier, 0x02000000)
	end
	if bit.band(modifier, Enums.FlagModifiers.CONTROL) == Enums.FlagModifiers.CONTROL then
		gameModifier = bit.bor(gameModifier, 0x04000000)
	end
	if bit.band(modifier, Enums.FlagModifiers.ALT) == Enums.FlagModifiers.ALT then
		gameModifier = bit.bor(gameModifier, 0x08000000)
	end
	if bit.band(modifier, Enums.FlagModifiers.NUMLOCK) == Enums.FlagModifiers.NUMLOCK then
		gameModifier = bit.bor(gameModifier, 0x20000000)
	end

	clientSendHotkey(key, gameModifier)
end

--- Get the current cursor position translated into the map position.
--- This function is a wrapper around the external function clientGetCursorMapPosition.
--- @return the following structure in table {x=0,y=0,z=0}
function Client.getCursorMapPosition()
	return clientGetCursorMapPosition()
end

--- Get the current fight mode.
--- This function is a wrapper around the external function clientGetFightMode.
--- @return the current fight mode, otherwise the last known fight mode. Refer to Enums.FightModes for possible values.
function Client.getFightMode()
	return clientGetFightMode()
end

--- Set the current fight mode.
--- Note: this function doesn't updates the fight mode instantly, it will be updated on the next game frame.
--- This function is a wrapper around the external function clientSetFightMode.
--- @param fightMode (number) - The fight mode to be set. Refer to Enums.FightModes for possible values.
function Client.setFightMode(fightMode)
	clientSetFightMode(fightMode)
end

--- Get the current chase mode.
--- This function is a wrapper around the external function clientGetChaseMode.
--- @return the current chase mode, otherwise the last known chase mode. Refer to Enums.ChaseModes for possible values.
function Client.getChaseMode()
	return clientGetChaseMode()
end

--- Set the current chase mode.
--- Note: this function doesn't updates the chase mode instantly, it will be updated on the next game frame.
--- This function is a wrapper around the external function clientSetChaseMode.
--- @param chaseMode (number) - The chase mode to be set. Refer to Enums.ChaseModes for possible values.
function Client.setChaseMode(chaseMode)
	clientSetChaseMode(chaseMode)
end

--- Set game window title.
--- This function is a wrapper around the external function clientSetWindowTitle.
--- @param title (string) - The title to be set.
function Client.setWindowTitle(title)
	clientSetWindowTitle(title)
end

-- Get the Tibia client version.
-- This function is a wrapper around the external function clientGetVersion.
-- @return The Tibia client version as a string (example: 14.00.f275d0), if not available will return nil.
function Client.getVersion()
    return clientGetVersion()
end

-- Get the current trade shop window openned state.
-- This function is a wrapper around the external function clientIsTradeShopOpen.
-- @return true if the trade shop window is open, false otherwise. Note: the bot will only have this information if the player has opened or closed the trade shop window.
function Client.isTradeShopOpen()
	return clientIsTradeShopOpen()
end

--- Returns if in-game chat is enabled.
--- This function is a wrapper around the external function clientIsChatEnabled.
--- @return (boolean) - Returns true if in-game chat is enabled, false otherwise.
function Client.isChatEnabled()
    return clientIsChatEnabled()
end

--- Toggle in-game chat enabled/disabled state. After usage, the developer should wait the next game frame to get the updated state using Client.isChatEnabled function.
--- This function is a wrapper around the external function clientToggleChatEnabled.
--- @return (boolean) - Returns true if the in-game chat is enabled, false otherwise.
function Client.toggleChatEnabled()
    clientToggleChatEnabled()
end

--- Flash the client window.
--- This function is a wrapper around the external function clientFlashWindow.
function Client.flashWindow()
	clientFlashWindow()
end

--- Get the current frames per second (FPS) of the client.
--- This function is a wrapper around the external function clientGetFps.
--- @return The last available frames per second (FPS) of the client, got from UI FPS indicator, if the information isn't available will return 0 or the last one available.
function Client.getFps()
	return clientGetFps()
end