# GozzimHUD
## Description
- GozzimHUD is a collection of scripts for ZeroBot that provides various utilities to enhance your Tibia gameplay. 
- It features a simple UI to enable and disable scripts on the fly.

## Installation
1. Put the `GozzimHUD.lua` script and `GozzimScripts` folder in your ZeroBot-Scripts folder, usually located at `~/Documents/ZeroBot/Scripts`.
2. In ZeroBot, go to the `Scripting` tab and load the `GozzimHUD.lua` script.
3. Use the Config Icon <img style="vertical-align: middle; align-content: center" src="https://github.com/user-attachments/assets/bbb1b45a-633e-4447-b706-e6110a86c648"> in the bottom left to enable or disable the scripts you want.
4. Hit `Save & Exit` to save your settings for the character you are logged into.

## Features

### <img style="float: left; margin-right: 8px; margin-top: -7px;" src="https://github.com/user-attachments/assets/407075f4-b785-478f-896d-3eb360159656"/> Auto Open Doors
- Automatically opens doors as you approach them.

### <img style="float: left; margin-right: 8px; margin-top: -4px;" src="https://github.com/user-attachments/assets/4d72cc23-c9c6-4de5-890f-43d8a459f6eb"/> Auto Eat
- Automatically eats food from your inventory when hungry.
- Accepts Fire Mushroom, Brown Mushroom, Red Mushroom in that order and changes icon depending on available food.
- Not eating in protection zone.

### <img style="float: left; margin-right: 8px; margin-top: -7px;" src="https://github.com/user-attachments/assets/45f91167-7bae-440d-b40f-cfdc652b2a9d"/> Auto Haste
- Automatically casts `Utani Hur` or `Utani Gran Hur` depending on your vocation, always keeping Haste up.
- Not casted when in a protection zone.

### <img style="float: left; margin-right: 8px; margin-top: -7px;" src="https://github.com/user-attachments/assets/81a74ba0-69f0-4375-8a6c-6748ea46765f"/> Keep Target
- Ensures your character holds the current target, preventing it from being lost.
- When activated, reattacks last target when in range.

### <img style="float: left; margin-right: 8px; margin-top: -8px;" src="https://github.com/user-attachments/assets/ee594a21-409a-4757-8868-cde3040a67da"/> Auto Shoot
- Automatically shoots runes at your target.
- The Rune to be shot is configured in the `Rune Max` setting of ZeroBot.
- Changes Icon depending on the selected Rune.

### <img style="float: left; margin-right: 8px; margin-top: -7px;" src="https://github.com/user-attachments/assets/5c5e5ccf-2d69-44a5-bfa3-fb49ef22fd5c"/> Auto Rage
- Automatically uses the `Utito Tempo` spell and keeps it active.
- Casts when two or more creatures are in range.

### <img style="float: left; margin-right: 8px; margin-top: -8px;" src="https://github.com/user-attachments/assets/a418164b-bb1c-4a4e-be46-42cdc33b46cc"/> Magic Wall
- Allows you to shoot a Magic Wall 2 squares in front of the current target.
- Use hotkey `x` to shoot.

### <img style="float: left; margin-right: 8px; margin-top: -8px;" src="https://github.com/user-attachments/assets/4a92c5db-7a2a-4763-85ad-edf57a9e8c90"/> Tank Mode (SSA & Might Ring)
- Automatically equips a Stone Skin Amulet and a Might Ring.
- Replaces Amulet and Ring when charges are used up automatically.

### <img style="float: left; margin-right: 8px; margin-top: -7px;" src="https://github.com/user-attachments/assets/0e8cf0ab-377e-4054-b2e9-fd14d48967a5"/> Auto Loot
- Automatically loots nearby dead creatures.
- When enabled, always loots whenever you get experience.

### <img style="float: left; margin-right: 8px; margin-top: -7px;" src="https://github.com/user-attachments/assets/d57cc868-05d2-4e9c-972f-9ff1a4d15b64"/> Auto Skin
- Automatically skins creatures in range when dead.

### <img style="float: left; margin-right: 8px; margin-top: -7px;" src="https://github.com/user-attachments/assets/e804b103-fd88-4629-b5f9-450292c560ef"/> Fishing
- Automatically fishes in nearby water tiles.

### <img style="float: left; margin-right: 8px; margin-top: -7px;" src="https://github.com/user-attachments/assets/16b20e1f-7c5d-4ac5-b30d-d1a44108bb84"/> Anti-Push
- Prevents your character from being pushed by putting items below.
- Activates the ZeroBot Internal Anti-Push function.
- Uses the items configured in ZeroBot Anti-Push.

### <img style="float: left; margin-right: 8px; margin-top: -7px;" src="https://github.com/user-attachments/assets/c05435df-4ac3-42b2-805b-4855e11013aa"/> Toggle Effects
- Provides a way to toggle various in-game visual effects on or off.
- Requires the ZeroBot `Disable Magic Effects` setting under `Engine` to have the hotkey `L`

### <img style="float: left; margin-right: 8px; margin-top: -9px;" src="https://github.com/user-attachments/assets/d2a6a563-725e-4be9-b588-ddf737f709b9"/> Auto Exiva
- Automatically uses the `Exiva` spell in an interval to find other players.
- Uses the last exiva target or alternatively the last attacked target.
- To manually configure target, manually exiva a player once, then activate.
- Only casts the spell if the target is not on your screen.
- The Dracola's Eye button <img style="vertical-align: middle;" src="https://github.com/user-attachments/assets/9b5ff0e9-702f-4802-9cf5-07706d9631fd"> enforces this even when the player is standing next to you.

### <img style="float: left; margin-right: 8px; margin-top: -8px;" src="https://github.com/user-attachments/assets/eb50b967-f1f0-46a8-ac52-1bebac05e295"/> Character Info
- Displays information about players, monsters and NPCs on your screen.
- The information includes name, level, vocation and floor.
- Highly configurable by hitting the paper icon next to the settings icon.
- The Script gets its data from spell casts and talking as well as look information. So Auto-Look is not required.
- Saves all previously seen player information and your settings.

### <img style="float: left; margin-right: 8px; margin-top: -8px;" src="https://github.com/user-attachments/assets/49d382db-7200-41f7-a83e-14579e6aca6c"/> Exercise
- Automatically uses exercise weapons on training dummies.
- Selects the correct weapon based on vocation and skills.
- Automatically uses the next available weapon when one breaks.
- Only works in a protection zone.

### Oberon
- A helper script for the Oberon boss fight.

### FPS/Ping
- Displays your current FPS and latency.

## Credits
Scripts for ZeroBot created by [Gozzim](https://github.com/Gozzim).

## License
This code and content is released under the [GNU AGPL-3.0 license](https://github.com/Gozzim/GozzimHUD/blob/master/LICENSE).
