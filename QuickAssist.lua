-- QuickAssist: remember a friendly player and assist their target with one key.
-- Based on SimpleAssist by Schnoggo.

local _, ns = ...; -- ns is shared by every file in this addon
local L = ns.L;

-- The only global we export. Bindings.xml calls into it.
QuickAssist = ns;

local BUTTON_NAME = "QuickAssistActionButton";
local DEFAULT_MACRO = "/assist target"; -- used until a player has been learned
local PENDING_CLEAR = {}; -- marks a "clear the learned player" request made during combat

-- A learn request made during combat, applied once combat ends:
-- nil (nothing pending) | {name = , display = } | PENDING_CLEAR
local pending;

-- WoW Forever players have a primary and a secondary name (no realm)
local SURNAME_SEPARATOR = Constants and Constants.CharacterNameSeparatorConsts
	and Constants.CharacterNameSeparatorConsts.CHARACTERNAME_SURNAME_SEPARATOR or "-";

local button = CreateFrame("CheckButton", BUTTON_NAME, UIParent, "ActionBarButtonTemplate");
button:SetAttribute("type", "macro");
button:SetAttribute("macrotext", DEFAULT_MACRO);
button:ClearAllPoints();
-- putting the button off-screen to make it invisible
button:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 50, 50);

local events = CreateFrame("Frame");

-- Alert text: the game's own font, but larger and outlined so it stands out
local ALERT_FONT_SIZE = 32;
local alertFont = CreateFont("QuickAssistAlertFont");
alertFont:SetFont((GameFontNormalHuge:GetFont()), ALERT_FONT_SIZE, "OUTLINE");
QuickAssistAlertFrame:SetFontObject(alertFont);
QuickAssistAlertFrame:SetJustifyH("CENTER");

-- How long a message stays: full strength, then fading out (seconds)
local ALERT_HOLD_SECONDS = 2;
local ALERT_FADE_SECONDS = 1;
QuickAssistAlertFrame:SetTimeVisible(ALERT_HOLD_SECONDS);
QuickAssistAlertFrame:SetFadeDuration(ALERT_FADE_SECONDS);


--- Our head's up display for this addon
local function PopMsg(msg, r, g, b)
	QuickAssistAlertFrame:AddMessage(msg, r or 1, g or 1, b or 1, 1); -- uses the frame's visible and fade times
end

-- Message colors (red, green, blue)
local GREEN = {0.4, 1, 0.4};
local GRAY = {0.75, 0.75, 0.75};
local YELLOW = {1, 0.82, 0};
local RED = {1, 0.3, 0.3};

-- Sound IDs (plain numbers work on every client, even without the SOUNDKIT table)
local SOUND_SET = 850; -- main menu open
local SOUND_CLEARED = 838; -- ability icon drop
local SOUND_REFUSED = 847; -- quest failed

-- The player currently being assisted, as shown in messages (nil: none learned)
local learnedDisplay;

-- Saved between sessions. Set up at login, when saved variables are available.
local db = {sound = true};


--- The primary name of a unit and, for players on WoW Forever, the secondary name.
local function NameParts(unit)
	local primary, secondary = UnitName(unit);
	if (primary and secondary and "" ~= secondary
		and UnitIsPlayer(unit) and RegionalUniqueNamesEnabled and RegionalUniqueNamesEnabled()) then
		return primary, secondary;
	end
	return primary;
end


--- The name to show for a unit: primary and secondary name, or just the name.
local function DisplayName(unit)
	local primary, secondary = NameParts(unit);
	return secondary and (primary .. SURNAME_SEPARATOR .. secondary) or primary;
end


--- The name to use in the /assist macro. The game accepts the primary and secondary
-- name separated by a space (a hyphen does not work), which tells apart players
-- who share a primary name.
local function MacroName(unit)
	local primary, secondary = NameParts(unit);
	return secondary and (primary .. " " .. secondary) or primary;
end


--- Point the assist key at a player, or reset it to assist the current target.
-- Setting a secure attribute is not allowed during combat.
-- @param name of player to assist, or nil to clear
-- @param display name to show in messages
local function SetAssist(name, display)
	if (name) then
		button:SetAttribute("macrotext", "/assist " .. name);
		learnedDisplay = display;
		PopMsg(L.ASSIST_SET .. ": " .. display, unpack(GREEN));
		if (db.sound) then
			PlaySound(SOUND_SET, "SFX");
		end
	else
		button:SetAttribute("macrotext", DEFAULT_MACRO);
		learnedDisplay = nil;
		PopMsg(L.CLEARED, unpack(GRAY));
		if (db.sound) then
			PlaySound(SOUND_CLEARED, "SFX");
		end
	end
end


--- Bind our button to the key(s) the player chose for "Assist Learned Player"
local function UpdateBindings()
	if (InCombatLockdown()) then
		return; -- override bindings can't be changed in combat, we retry when combat ends
	end
	ClearOverrideBindings(events);
	for _, key in ipairs({GetBindingKey("QUICKASSIST_ASSIST")}) do
		SetOverrideBindingClick(
			events, -- owner frame
			false, -- isPriority, even false is higher than normal bindings
			key,
			BUTTON_NAME
		);
	end
end


--- "Learn" the given unit (normally the target) as the player to assist.
-- With no such unit, the learned player is cleared.
-- During combat the change is queued until combat ends.
-- @param unit ID of unit to be set as assist
function ns.Learn(unit)
	local name = MacroName(unit); -- nil when there is no such unit
	local display = DisplayName(unit);

	if (name ~= nil and UnitIsUnit(unit, "player")) then
		PopMsg(L.CANNOT_ASSIST_SELF, unpack(RED)); -- assisting yourself would do nothing useful
		if (db.sound) then
			PlaySound(SOUND_REFUSED, "SFX");
		end
		return; -- the player currently being assisted stays as it is
	end

	-- Checked before the combat queue, so a hostile or NPC target is never queued
	if (name ~= nil and not (UnitIsPlayer(unit) and UnitIsFriend("player", unit))) then
		PopMsg(L.CANNOT_ASSIST_NOT_PLAYER, unpack(RED));
		if (db.sound) then
			PlaySound(SOUND_REFUSED, "SFX");
		end
		return;
	end

	if (InCombatLockdown()) then
		if (name == nil) then
			pending = PENDING_CLEAR;
			PopMsg(L.CLEAR_PENDING, unpack(YELLOW));
		else
			pending = {name = name, display = display};
			PopMsg(L.ASSIST_PENDING .. display, unpack(YELLOW));
		end
		return;
	end

	if (name == nil) then
		SetAssist(nil);
	else
		SetAssist(name, display);
	end
end


--- Bound to the "Assist Learned Player" key.
-- This function is a dummy. The key is overridden to click our button (see
-- UpdateBindings). It exists so the binding shows up in the Key Bindings panel.
function ns.DoAssist()
end


--- Open the game's Key Bindings panel. Which API exists depends on the client.
-- @return true if a panel was opened
local function OpenKeyBindings()
	if (KeyBindingFrame_LoadUI) then
		KeyBindingFrame_LoadUI(); -- creates KeyBindingFrame on first use
		if (KeyBindingFrame) then
			ShowUIPanel(KeyBindingFrame);
			return true;
		end
	end
	-- the Settings window wants the category's numeric ID, not its name
	if (Settings and Settings.OpenToCategory and Settings.KEYBINDINGS_CATEGORY_ID) then
		return (pcall(Settings.OpenToCategory, Settings.KEYBINDINGS_CATEGORY_ID));
	end
	return false;
end


--- Whether some other slash command already uses the given word (e.g. "/qa")
local function SlashInUse(word)
	for command in pairs(SlashCmdList) do
		if ("QUICKASSIST" ~= command) then
			local i = 1;
			local alias = _G["SLASH_" .. command .. i];
			while (alias) do
				if (alias:lower() == word) then
					return true;
				end
				i = i + 1;
				alias = _G["SLASH_" .. command .. i];
			end
		end
	end
	return false;
end


-- /quickassist is always ours. The short /qa is added at login, if nobody else has it.
SLASH_QUICKASSIST1 = "/quickassist";
SlashCmdList["QUICKASSIST"] = function(msg)
	local command = strlower(strtrim(msg or ""));
	if ("" == command) then
		if (not OpenKeyBindings()) then
			print(L.KEYS_CANNOT_OPEN);
		end
	elseif ("sound" == command) then
		db.sound = not db.sound;
		print(db.sound and L.SOUND_ON or L.SOUND_OFF);
	elseif ("status" == command) then
		print(learnedDisplay and (L.STATUS_ASSISTING .. learnedDisplay) or L.STATUS_NONE);
		print(db.sound and L.SOUND_ON or L.SOUND_OFF);
	else
		print(L.USAGE);
	end
end;


events:SetScript("OnEvent", function(frame, event)
	if (event == "PLAYER_LOGIN") then
		QuickAssistDB = QuickAssistDB or {};
		if (QuickAssistDB.sound == nil) then
			QuickAssistDB.sound = true; -- sound is on until the player turns it off
		end
		db = QuickAssistDB;

		-- every addon has loaded by now, so we can see whether /qa is taken
		if (not SlashInUse("/qa")) then
			SLASH_QUICKASSIST2 = "/qa";
		end

	elseif (event == "PLAYER_ENTERING_WORLD") then
		-- Remind new players until both keys are set. This waits until we are in the world
		-- because on a fresh login the saved bindings are not loaded yet at PLAYER_LOGIN.
		events:UnregisterEvent("PLAYER_ENTERING_WORLD"); -- once per session, not on every zone change
		if (not GetBindingKey("QUICKASSIST_LEARN") or not GetBindingKey("QUICKASSIST_ASSIST")) then
			print(L.KEYS_NOT_SET);
		end

	elseif (event == "UPDATE_BINDINGS") then
		UpdateBindings();

	elseif (event == "PLAYER_REGEN_ENABLED") then -- left combat
		UpdateBindings();
		if (pending ~= nil) then
			if (PENDING_CLEAR == pending) then
				SetAssist(nil);
			else
				SetAssist(pending.name, pending.display);
			end
			pending = nil;
		end
	end
end);
events:RegisterEvent("PLAYER_LOGIN");
events:RegisterEvent("PLAYER_ENTERING_WORLD");
events:RegisterEvent("UPDATE_BINDINGS");
events:RegisterEvent("PLAYER_REGEN_ENABLED");
