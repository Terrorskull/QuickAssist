# QuickAssist

A small World of Warcraft addon for WoW Forever. Remember a friendly player with one key, then assist their target with another.

It replaces the usual `/assist <name>` macro: no macro to edit when the player you follow changes, just target them and press a key.

![The QuickAssist section in the Key Bindings panel](docs/keybindings.png)

## Install

1. Download `QuickAssist-0.1.0.zip` from the [latest release](https://github.com/Terrorskull/QuickAssist/releases/latest).
2. Unzip it into your WoW Forever `Interface/AddOns` folder, so you end up with `AddOns/QuickAssist/QuickAssist.toc`.
3. If the game is already running, type `/reload`. A restart isn't needed.

## Usage

Open the Key Bindings panel (Esc > Options > Key Bindings) and find the **QuickAssist** section.

- **Set Player to Assist**: target a friendly player and press this key. You'll see "Assist set: Name Secondary".
- **Assist Learned Player**: press this key to target that player's target.

Good to know:
- Until you learn someone, the assist key just assists your current target, so you can bind it to your normal assist key.
- Press **Set Player to Assist** with nothing targeted to clear the learned player.
- You can't set yourself as the player to assist.
- If you change the player during combat, the change is queued and applied when combat ends.
- Players have a primary and a secondary name on WoW Forever. QuickAssist uses both, so two players who share a primary name can be told apart.

There are no settings and no slash commands.

## Compatibility

Tested on WoW Forever (interface `16001`). It has not been tested on retail or other clients.

## Credits and license

QuickAssist is a modified version of [SimpleAssist](https://www.curseforge.com/wow/addons/simpleassist) 4.01 by Schnoggo. The original documentation is in `Readme.txt`.

Released under the Creative Commons Attribution-NonCommercial 3.0 Unported license (CC BY-NC 3.0), the same license as the original. Free to use and share with credit to the original author. Not for commercial use. See `LICENSE` for the details.

## Changes

See [CHANGELOG.md](CHANGELOG.md) for what changed from SimpleAssist.
