# Changelog

All changes from SimpleAssist, newest first. QuickAssist is based on SimpleAssist 4.01 by Schnoggo.

## 1.0.0 (2026-10-14)
- First stable release. No functional changes from 0.1.0.
- Releases are now built and uploaded to CurseForge automatically from version tags using the BigWigs packager (`.pkgmeta` and `.github/workflows/release.yml`).

## 0.1.0 (2026-10-13)
- Renamed the addon to QuickAssist and started a new version line (the last SimpleAssist-based version was `4.01-wf1`). `QuickAssist.toc` and `QuickAssist.lua` replace the SimpleAssist file names.
- Removed the Request Assistance feature and all of its settings (chat channels, custom message, raid icon), which also removed the settings panel (`settings.lua`, `settings_panel_lib.lua`) and the saved variables.
- Key bindings now have their own "QuickAssist" section in the Key Bindings panel instead of "Other". The binding names changed (`QUICKASSIST_LEARN`, `QUICKASSIST_ASSIST`), so existing key assignments need to be set again. The assist key now also honors a second key assigned to it.
- Assist messages now show the player's primary and secondary name on WoW Forever (for example `Emberfall Quillgrove`), not just the primary name. The assist macro uses both names too, separated by a space (`/assist Name Secondary`), so players who share a primary name can be told apart. A hyphen does not work in the game's `/assist`.
- Assist messages use a larger, outlined version of the standard game font (`GameFontNormalHuge`) instead of the number font. The size is `ALERT_FONT_SIZE` in `QuickAssist.lua`, and the message frame is wider so long names don't wrap. They also disappear sooner: 2 seconds visible and a 1 second fade (`ALERT_HOLD_SECONDS`, `ALERT_FADE_SECONDS`), down from about 6 seconds.
- You can no longer set yourself as the player to assist. The learn key shows a message instead and keeps the current assist.
- Code cleanup: one global (`QuickAssist`) instead of many, the unused `SimpleAssist.xml`, test functions, `SchnoggoAlertInform` hook and unused event registrations removed, and `PLAYER_LEAVE_COMBAT` replaced by `PLAYER_REGEN_ENABLED`. Override key bindings are cleared and reapplied when bindings change and when combat ends.
- The TOC now targets WoW Forever only (`## Interface: 16001`). The retail interface number was removed because this version has only been tested on WoW Forever. The TOC author line credits Schnoggo and Terrorskull.
- Added `LICENSE` with attribution to the original author and the CC BY-NC 3.0 terms.

## 4.01-wf1 (2026-10-13)
- `SimpleAssist.toc`: added the classic interface number, `## Interface: 120000, 16001`, so the addon loads on WoW Forever.
- `settings.lua`: wrapped `UnitName("player")` in extra parentheses before passing it to `SassAddon.PanelText`, so only the character name is passed and not the realm return value.
