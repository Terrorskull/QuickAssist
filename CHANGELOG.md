# Changelog

QuickAssist is based on SimpleAssist 4.01 by Schnoggo. Newest first.

## 1.4.0 (2026-10-19)
- QuickAssist now remembers who you were assisting when you reload the UI or log back in. Each character remembers their own player.
- When you log in or reload with a player still set to assist, QuickAssist now says so in chat.
- The player's name is now shown in their class color in the `/quickassist status` message and the login message. If QuickAssist doesn't know the class yet (for example you typed the name and they weren't nearby), the name is green until that player is in your group or your target.
- Type `/quickassist set Name` to choose a player to assist by name, without having to target them first.

## 1.3.1 (2026-10-17)
- Fixed being able to set an enemy or an NPC as the player to assist while in combat. Only friendly players can be set now, and you get a red message if you try something else.

## 1.3.0 (2026-10-17)
- Messages now have colors: green when you set a player, gray when you clear, yellow while a change waits for combat to end, and red if you try to assist yourself.
- Short sounds now play when you set a player, clear the player, or try to set yourself. Type `/quickassist sound` to turn them off or on again.
- Type `/quickassist status` to see who you are assisting.

## 1.2.1 (2026-10-16)
- Fixed a reminder that your keys aren't set showing up at login even when they were set.

## 1.2.0 (2026-10-15)
- QuickAssist now works on WoW retail as well as WoW Forever.

## 1.1.0 (2026-10-14)
- New players are now reminded at login to set their keys. The reminder goes away once both keys are set.
- Added the `/quickassist` command to open the Key Bindings panel. `/qa` works too, unless another addon already uses it.

## 1.0.0 (2026-10-14)
- First stable release. Nothing has changed since 0.1.0.

## 0.1.0 (2026-10-13)
- Renamed to QuickAssist and now supports WoW Forever only.
- Removed the Request Assistance feature and its settings panel.
- Key bindings now have their own "QuickAssist" section in the Key Bindings panel. You will need to set your keys again.
- The assist key can now have a second key assigned to it.
- Assist messages and the assist macro now use the player's primary and secondary name, so players who share a primary name can be told apart.
- Assist messages are larger, easier to read, and disappear sooner.
- You can no longer set yourself as the player to assist. The learn key shows a message and keeps your current assist.

## 4.01-wf1 (2026-10-13)
- Fixed the addon not loading on WoW Forever.
- Fixed the settings panel showing the realm along with the character name.
