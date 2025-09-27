-- Table to represent Spells and its associated functions
Spells = {}

--- Get the ID of a spell by its name.
-- This function is a wrapper around the external function spellGetIdByName.
-- @param name (string) - The name of the spell.
-- @return The ID of the spell, or -1 if there's no spell available.
function Spells.getIdByName(name)
    return spellGetIdByName(name)
end

--- Get the ID of a spell by its words.
-- This function is a wrapper around the external function spellGetIdByWords.
-- @param words (string) - The words of the spell.
-- @return The ID of the spell, or -1 if there's no spell available.
function Spells.getIdByWords(words)
    return spellGetIdByWords(words)
end

--- Check if a spell is in cooldown.
-- This function is a wrapper around the external function spellIsInCooldown.
-- @param id (number) - The ID of the spell.
-- @return True if the spell is in cooldown, false otherwise.
function Spells.isInCooldown(id)
    return spellIsInCooldown(id)
end

--- Get the left cooldown time of a specific spell.
-- This function is a wrapper around the external function spellGetLeftCooldownTime.
-- @param id (number) - The ID of the spell.
-- @return The left cooldown time of the spell, or -1 for following conditions: the spell doesn't exist, the spell is not in cooldown.
function Spells.getLeftCooldownTime(id)
    return spellGetLeftCooldownTime(id)
end

-- Get the left cooldown time of a specific spell group.
-- This function is a wrapper around the external function spellGetLeftGroupCooldownTime.
-- @param groupId (number) - The ID of the spell group, refer to this parameter as Enums.SpellGroups
-- @return The left cooldown time of the spell group, or -1 for following conditions: the spell group doesn't exist, the spell group is not in cooldown.
function Spells.getLeftGroupCooldownTime(groupId)
    return spellGetLeftGroupCooldownTime(groupId)
end

--- Check if a spell group is in cooldown.
-- This function is a wrapper around the external function spellGroupIsInCooldown.
-- @param groupId (number) - The ID of the spell group, refer tthis parameter as Enums.SpellGroups
-- @return True if the spell group is in cooldown, false otherwise.
function Spells.groupIsInCooldown(groupId)
    return spellGroupIsInCooldown(groupId)
end
