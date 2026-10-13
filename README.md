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

### 4.01-wf1 (2026-10-13)
- `SimpleAssist.toc`: added the classic interface number, `## Interface: 120000, 16001`, so the addon loads on WoW Forever.
- `settings.lua`: wrapped `UnitName("player")` in extra parentheses before passing it to `SassAddon.PanelText`, so only the character name is passed and not the realm return value.
