-- Table to hold player-related functions
Player = {}

--- Get the player's unique ID.
-- This function is a wrapper around the external function playerGetId.
-- @return The player's unique ID, or 0 if isn't in-game.
function Player.getId()
	return playerGetId()
end

--- Get the player's name.
-- This function is a wrapper around the external function playerGetName.
-- @return The player's name, or nil if isn't in-game.
function Player.getName()
	return playerGetName()
end

--- Get the player's current health.
-- This function is a wrapper around the external function playerGetHealth.
-- @return The player's current health, or last value if isn't in-game.
function Player.getHealth()
	return playerGetHealth()
end

--- Get the player's current mana.
-- This function is a wrapper around the external function playerGetMana.
-- @return The player's current mana, or last value if isn't in-game.
function Player.getMana()
	return playerGetMana()
end

--- Get the player's current health as a percentage.
-- This function is a wrapper around the external function playerGetHealthPercent.
-- @return The player's current health as a percentage, or last value if isn't in-game.
function Player.getHealthPercent()
	return playerGetHealthPercent()
end

--- Get the player's current mana as a percentage.
-- This function is a wrapper around the external function playerGetManaPercent.
-- @return The player's current mana as a percentage, or last value if isn't in-game.
function Player.getManaPercent()
	return playerGetManaPercent()
end

--- Get the player's current magic shield value.
-- This function is a wrapper around the external function playerGetMagicShield.
-- @return The player's current magic shield value, or last value if isn't in-game.
function Player.getMagicShield()
	return playerGetMagicShield()
end

--- Get the player's maximum magic shield capacity.
-- This function is a wrapper around the external function playerGetMaxMagicShield.
-- @return The player's maximum magic shield capacity, or last value if isn't in-game.
function Player.getMaxMagicShield()
	return playerGetMaxMagicShield()
end

--- Get the player's current capacity.
-- This function is a wrapper around the external function playerGetCapacity.
-- @return The player's current capacity, or last value if isn't in-game.
function Player.getCapacity()
	return playerGetCapacity()
end

--- Get the player's current soul points.
-- This function is a wrapper around the external function playerGetSoulPoints.
-- @return The player's current soul points, or last value if isn't in-game.
function Player.getSoulPoints()
	return playerGetSoulPoints()
end

--- Return if player is hungry.
-- This function is a wrapper around the external function playerIsHungry.
-- @return The player's hungry state, or last value if isn't in-game.
function Player.isHungry()
	return playerIsHungry()
end

--- Get the player's current stamina in minutes.
-- This function is a wrapper around the external function playerGetStamina.
-- @return The player's current stamina in minutes, or last value if isn't in-game.
function Player.getStamina()
	return playerGetStamina()
end

--- Get the player's current level.
-- This function is a wrapper around the external function playerGetLevel.
-- @return The player's current level, or last value if isn't in-game.
function Player.getLevel()
	return playerGetLevel()
end

--- Get the player's current level percentage.
-- This function is a wrapper around the external function playerGetLevelPercent.
-- @return The player's current level percentage, or last value if isn't in-game.
function Player.getLevelPercent()
	return playerGetLevelPercent()
end

--- Get the player's current experience.
--- This function is a wrapper around the external function playerGetExperience.
--- @return The player's current experience, or last value if isn't in-game.
function Player.getExperience()
	return playerGetExperience()
end

--- Retrieves the XP boost remaining time in seconds of the player.
-- This function is a wrapper around the external function playerGetXpBoostTime.
--- @return number The remaining time of the XP boost in seconds, or last value if isn't in-game.
function Player.getXpBoostTime()
	return playerGetXpBoostTime()
end

--- Get the player's skills.
-- This function is a wrapper around the external function playerGetSkills.
-- This information will be available if you logged in with bot injected, so it can gather skills informations
-- @return The player's current skills by level and percentage as table, or last value if isn't in-game.
-- Example output:
-- {
--     "lifeLeechDamage": 2500,
--     "manaLeechChance": 0,
--     "manaLeechDamage": 0,
--     "fist": 10,
--     "axe": 10,
--     "club": 10,
--     "sword": 10,
--     "distance": 10,
--     "shield": 10,
--     "fishing": 10,
--     "magic": 0,
--     "fistPercent": 0,
--     "axePercent": 0,
--     "clubPercent": 0,
--     "swordPercent": 0,
--     "distancePercent": 0,
--     "shieldPercent": 0,
--     "fishingPercent": 0,
--     "magicPercent": 0,
--     "criticalChance": 0,
--     "criticalDamage": 0,
--     "lifeLeechChance": 0
-- }
function Player.getSkills()
	return playerGetSkills()
end

--- Get the ID of the player's current target.
-- This function is a wrapper around the external function playerGetTargetId.
-- @return The ID of the player's current target, or last value if isn't in-game.
function Player.getTargetId()
	return playerGetTargetId()
end

--- Get the ID of the player's current follow target.
-- This function is a wrapper around the external function playerGetFollowId.
-- @return The ID of the player's current follow target, or last value if isn't in-game.
function Player.getFollowId()
	return playerGetFollowId()
end

--- Get the item information of specific player's inventory slot.
-- This function is a wrapper around the external function playerGetInventorySlot.
-- @param slot (number) - The inventory slot to get item information, refer the parameter value as Enums.InventorySlot
-- @return The item information of specific the player's inventory slot, or nil if there's no item. Table format: {id=0,count=0,tier=0,holdingCount=0}
function Player.getInventorySlot(slot)
	return playerGetInventorySlot(slot)
end

--- Get the status of specified state index of player.
-- This function is a wrapper around the external function playerGetState.
-- @param index (number) - The state index to check if is active, refer the parameter value as Enums.States
-- @return The state status if is active on player or not, or nil if there's no state from specified param index
function Player.getState(index)
	return playerGetState(index)
end

--- Get the player opened containers.
-- This function is a wrapper around the external function playerGetContainers.
-- @return A table containing all open container indexes, or nil if there's no container opened
function Player.getContainers()
	return playerGetContainers()
end

-- Get current player dusts amount.
-- This function is a wrapper around the external function playerGetDusts.
-- @return The player's current dusts amount, or last value if isn't in-game.
function Player.getDusts()
	return playerGetDusts()
end

-- Get maximum dusts amount.
-- This function is a wrapper around the external function playerGetDustsMaximum.
-- @return The player's maximum dusts amount, or last value if isn't in-game.
function Player.getDustsMaximum()
	return playerGetDustsMaximum()
end

-- Get the player's total gold balance.
-- This function is a wrapper around the external function playerGetTotalGoldBalance.
-- @return The player's total gold balance, or last value if isn't in-game. This value is generally updated when you open some window in-game that have this information, some cases like: open market, open prey window & etc.
function Player.getTotalGoldBalance()
	return playerGetTotalGoldBalance()
end

--- Join into other player party if the invitation request is pending.
-- This function is a wrapper around the external function playerJoinParty.
-- @param targetId (number) - The target player id who are invitating you
function Player.joinParty(targetId)
	playerJoinParty(targetId)
end

--- Invite other player to your party.
-- This function is a wrapper around the external function playerInviteParty.
-- @param targetId (number) - The target player to invite
function Player.inviteParty(targetId)
	playerInviteParty(targetId)
end

--- Enable shared experience state on your party.
-- This function is a wrapper around the external function playerEnableSharedExpParty.
-- @param enabled (boolean) - Enabled state
function Player.enableSharedExpParty(enabled)
	playerEnableSharedExpParty(enabled)
end

--- Pass the party leadership to another player.
--- This function is a wrapper around the external function playerPassLeadershipParty.
--- @param targetId (number) - The target player id to pass the leadership
function Player.passLeadershipParty(targetId)
	playerPassLeadershipParty(targetId)
end

-- Get the player's blessing state.
-- This function is a wrapper around the external function playerGetBlessingState.
function Player.getBlessingState()
	return playerGetBlessingState()
end

-- Get player's serene state.
-- This function is a wrapper around the external function playerIsSerene.
-- @return If player is in serene state, or last value if isn't in-game.
function Player.isSerene()
	return playerIsSerene()
end

-- Get the player's harmony.
-- This function is a wrapper around the external function playerGetHarmony.
-- @return The player's current harmony, or last value if isn't in-game.
function Player.getHarmony()
	return playerGetHarmony()
end

-- Get the player's enabled passive type. (Only for Monk vocation).
-- This function is a wrapper around the external function playerGetMonkPassiveType.
-- @return The player's current enabled passive type, or last value if isn't in-game. Refer to Enums.MonkPassiveType for the returned value.
function Player.getMonkPassiveType()
	return playerGetMonkPassiveType()
end

-- Get the player's unjustified data.
-- This function is a wrapper around the external function playerGetUnjustifiedData.
-- Output example: {
--    dayProgress = 0,
--    dayLeft = 0,
--    weekProgress = 0,
--    weekLeft = 0,
--    monthProgress = 0,
--    monthLeft = 0,
--    skullDuration = 0
--}
-- This information will only be available if server sent it (not when you injected the bot after logged in), if isn't available it's recommended to relogin your character.
-- @return The player's current unjustified data as a table, or last value if isn't in-game.
function Player.getUnjustifiedData()
	return playerGetUnjustifiedData()
end

--- Leave the current party.
--- This function is a wrapper around the external function playerLeaveParty.
function Player.leaveParty()
	playerLeaveParty()
end