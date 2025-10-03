# GozzimHUD
## Description
- GozzimHUD is a collection of scripts for ZeroBot that provides various utilities to enhance your Tibia gameplay. 
- It features a simple UI to enable and disable scripts on the fly.

## Installation
1. Put the `GozzimHUD.lua` script and `GozzimScripts` folder in your ZeroBot-Scripts folder, usually located at `~/Documents/ZeroBot/Scripts`.
2. In ZeroBot, go to the `Scripting` tab and load the `GozzimHUD.lua` script.
3. Use the Config Icon in the bottom left to enable or disable the scripts you want.
4. Hit `Save & Exit` to save your settings for the character you are logged into.

## Features

### Auto Open Doors
- Automatically opens doors as you approach them.

### Auto Eat
- Automatically eats food from your inventory when hungry.
- Accepts Fire Mushroom, Brown Mushroom, Red Mushroom in that order and changes icon depending on available food.

### Auto Haste
- Automatically casts `Utani Hur` or `Utani Gran Hur` depending on your vocation, always keeping Haste up.
- Not casted when in a protection zone.

### Keep Target
- Ensures your character holds the current target, preventing it from being lost.
- When activated, reattacks last target when in range.

### Auto Shoot
- Automatically shoots runes at your target.
- The Rune to be shot is configured in the `Rune Max` setting of ZeroBot.
- Changes Icon depending on the selected Rune.

### Auto Rage
- Automatically uses the `Utito Tempo` spell and keeps it active.
- Casts when two or more creatures are in range.

### Magic Wall
- Allows you to shoot a Magic Wall 2 squares in front of the current target.
- Use hotkey `x` to shoot.

### Tank Mode (SSA & Might Ring)
- Automatically equips a Stone Skin Amulet and a Might Ring.
- Replaces Amulet and Ring when charges are used up automatically.

### Auto Loot
- Automatically loots nearby dead creatures.
- When enabled, always loots whenever you get experience.

### Auto Skin
- Automatically skins creatures in range when dead.

### Fishing
- Automatically fishes in nearby water tiles.

### Anti-Push
- Prevents your character from being pushed by putting items below.
- Activates the ZeroBot Internal Anti-Push function.
- Uses the items configured in ZeroBot Anti-Push.

### Toggle Effects
- Provides a way to toggle various in-game visual effects on or off.
- Requires the ZeroBot `Disable Magic Effects` setting under `Engine` to have the hotkey `L`

### Auto Exiva
- Automatically uses the `Exiva` spell in an interval to find other players.
- Uses the last exiva target or alternatively the last attacked target.
- To manually configure target, manually exiva a player once, then activate.
- Only casts the spell if the target is not on your screen.
- They dracola eye button enforces this even when the player is standing next to you.

### Character Info
- Displays information about players, monsters and NPCs on your screen.
- The information includes name, level, vocation and floor.
- Highly configurable by hitting the paper icon next to the settings icon.
- Saves all previously seen player information and your settings.

### Oberon
- A helper script for the Oberon boss fight.

### FPS/Ping
- Displays your current FPS and latency.

## Credits
Scripts for ZeroBot created by [Gozzim](https://github.com/Gozzim).

## License
This code and content is released under the [GNU AGPL-3.0 license](https://github.com/Gozzim/GozzimHUD/blob/master/LICENSE).
