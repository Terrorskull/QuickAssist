# QuickAssist
World of Warcraft addon

Based on SimpleAssist 4.01 by Schnoggo (see `Readme.txt` for the original documentation and history).
This copy is a modified version for WoW Forever (classic).

## License

Released under the Creative Commons Attribution-NonCommercial 3.0 Unported license (CC BY-NC 3.0), the same license as the original. See `LICENSE` for the attribution details.
Free to use and share with credit to the original author. Not for commercial use.

## Changes from the retail version

### Unreleased
- Renamed the addon to QuickAssist: `SimpleAssist.toc` is now `QuickAssist.toc` and the title is `QuickAssist`. Saved variables and the other file names are unchanged for now.
- Added `LICENSE` with attribution to the original author and the CC BY-NC 3.0 terms.
- Fixed the addon name lookups that broke after the rename.
- Removed the Request Assistance feature and all of its settings (chat channels, custom message, raid icon), which also removed the settings panel (`settings.lua`, `settings_panel_lib.lua`) and the saved variables.
- Key bindings now have their own "QuickAssist" section in the Key Bindings panel instead of "Other". The binding names changed (`QUICKASSIST_LEARN`, `QUICKASSIST_ASSIST`), so existing key assignments need to be set again. The assist key now also honors a second key assigned to it.
- Removed unused code: `SimpleAssist.xml` (never loaded), test functions, and the `CHAT_MSG_CHANNEL`, `VARIABLES_LOADED`, `PLAYER_ENTERING_WORLD` and `PLAYER_LEAVE_COMBAT` event registrations.
### 4.01-wf1 (2026-10-13)
- `SimpleAssist.toc`: added the classic interface number, `## Interface: 120000, 16001`, so the addon loads on WoW Forever.
- `settings.lua`: wrapped `UnitName("player")` in extra parentheses before passing it to `SassAddon.PanelText`, so only the character name is passed and not the realm return value.
