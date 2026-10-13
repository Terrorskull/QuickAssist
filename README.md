# QuickAssist
World of Warcraft addon

Remember a friendly player with one key, assist their target with another.

Based on SimpleAssist 4.01 by Schnoggo (see `Readme.txt` for the original documentation and history).
This is a modified version for WoW Forever (classic).

## License

Released under the Creative Commons Attribution-NonCommercial 3.0 Unported license (CC BY-NC 3.0), the same license as the original. See `LICENSE` for the attribution details.
Free to use and share with credit to the original author. Not for commercial use.

## Changes from SimpleAssist

### 0.1.0 (2026-10-13)
- Renamed the addon to QuickAssist and started a new version line (the last SimpleAssist-based version was `4.01-wf1`). `QuickAssist.toc` and `QuickAssist.lua` replace the SimpleAssist file names.
- Removed the Request Assistance feature and all of its settings (chat channels, custom message, raid icon), which also removed the settings panel (`settings.lua`, `settings_panel_lib.lua`) and the saved variables.
- Key bindings now have their own "QuickAssist" section in the Key Bindings panel instead of "Other". The binding names changed (`QUICKASSIST_LEARN`, `QUICKASSIST_ASSIST`), so existing key assignments need to be set again. The assist key now also honors a second key assigned to it.
- Assist messages now show the player's primary and secondary name on WoW Forever (for example `Emberfall Quillgrove`), not just the primary name. The assist macro itself still uses the primary name only.
- Assist messages use a larger, outlined version of the standard game font (`GameFontNormalHuge`) instead of the number font. The size is `ALERT_FONT_SIZE` in `QuickAssist.lua`, and the message frame is wider so long names don't wrap. They also disappear sooner: 2 seconds visible and a 1 second fade (`ALERT_HOLD_SECONDS`, `ALERT_FADE_SECONDS`), down from about 6 seconds.
- You can no longer set yourself as the player to assist. The learn key shows a message instead and keeps the current assist.
- Code cleanup: one global (`QuickAssist`) instead of many, the unused `SimpleAssist.xml`, test functions, `SchnoggoAlertInform` hook and unused event registrations removed, and `PLAYER_LEAVE_COMBAT` replaced by `PLAYER_REGEN_ENABLED`. Override key bindings are cleared and reapplied when bindings change and when combat ends.
- Added `LICENSE` with attribution to the original author and the CC BY-NC 3.0 terms.

### 4.01-wf1 (2026-10-13)
- `SimpleAssist.toc`: added the classic interface number, `## Interface: 120000, 16001`, so the addon loads on WoW Forever.
- `settings.lua`: wrapped `UnitName("player")` in extra parentheses before passing it to `SassAddon.PanelText`, so only the character name is passed and not the realm return value.
