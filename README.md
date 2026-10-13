# SimpleAssist
World of Warcraft addon

Original addon by Schnoggo (see `Readme.txt` for the original documentation and history).
This copy is a modified version for WoW Forever (classic), based on the retail SimpleAssist 4.01.

## Changes from the retail version

### 4.01-wf1 (2026-10-13)
- `SimpleAssist.toc`: added the classic interface number, `## Interface: 120000, 16001`, so the addon loads on WoW Forever.
- `settings.lua`: wrapped `UnitName("player")` in extra parentheses before passing it to `SassAddon.PanelText`, so only the character name is passed and not the realm return value.
