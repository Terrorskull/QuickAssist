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
-- nil (nothing pending) | {name = , display = , class = } | PENDING_CLEAR
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
local db = {sound = true, assists = {}};


--- Key that identifies this character in the saved variables
local function CharacterKey()
	return UnitName("player") .. "-" .. GetRealmName();
end


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


--- A player name for chat lines, in the player's class color. Green when the class
-- is not known, the same green as the "Assist set" message.
-- @param display name to show
-- @param class token of the player's class (e.g. "WARRIOR"), or nil if unknown
local function ColoredName(display, class)
	local color = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class];
	if (color) then
		return format("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, display);
	end
	return "|cff66ff66" .. display .. "|r";
end


-- The class of the player being assisted (nil: not known yet)
local learnedClass;

-- The macro name of the player being assisted, to find them again (nil: none learned)
local learnedName;


--- Point the assist key at a player, or reset it to assist the current target.
-- Setting a secure attribute is not allowed during combat.
-- @param name of player to assist, or nil to clear
-- @param display name to show in messages
-- @param silent true to skip the message and sound (used when restoring at login)
-- @param class token of the player's class, or nil if unknown
local function SetAssist(name, display, silent, class)
	if (name) then
		button:SetAttribute("macrotext", "/assist " .. name);
		learnedName = name;
		learnedDisplay = display;
		learnedClass = class;
		db.assists[CharacterKey()] = {name = name, display = display, class = class};
		if (not silent) then
			PopMsg(L.ASSIST_SET .. ": " .. display, unpack(GREEN));
			if (db.sound) then
				PlaySound(SOUND_SET, "SFX");
			end
		end
	else
		button:SetAttribute("macrotext", DEFAULT_MACRO);
		learnedName = nil;
		learnedDisplay = nil;
		learnedClass = nil;
		db.assists[CharacterKey()] = nil;
		if (not silent) then
			PopMsg(L.CLEARED, unpack(GRAY));
			if (db.sound) then
				PlaySound(SOUND_CLEARED, "SFX");
			end
		end
	end
end


--- Change the player to assist now, or queue the change until combat ends.
-- @param name of player to assist, or nil to clear
-- @param display name to show in messages
-- @param silent true to skip the message and sound when applied right away
-- @param class token of the player's class, or nil if unknown
local function QueueOrSet(name, display, silent, class)
	if (InCombatLockdown()) then
		if (name == nil) then
			pending = PENDING_CLEAR;
			PopMsg(L.CLEAR_PENDING, unpack(YELLOW));
		else
			pending = {name = name, display = display, class = class};
			PopMsg(L.ASSIST_PENDING .. display, unpack(YELLOW));
		end
		return;
	end
	SetAssist(name, display, silent, class);
end


-- Units that can be checked to find a player by name
local LOOKUP_UNITS = {"target", "mouseover", "focus"};
for i = 1, 4 do
	tinsert(LOOKUP_UNITS, "party" .. i);
end
for i = 1, 40 do
	tinsert(LOOKUP_UNITS, "raid" .. i);
end


--- The class of a player, found by looking through the units we can see.
-- @param name macro name of the player
-- @return class token, or nil if the player is not among those units
local function FindClass(name)
	local wanted = strlower(name);
	for _, unit in ipairs(LOOKUP_UNITS) do
		if (UnitIsPlayer(unit)) then
			local macroName = MacroName(unit);
			if (macroName and strlower(macroName) == wanted) then
				return (select(2, UnitClass(unit)));
			end
		end
	end
end


--- If the class of the player being assisted is not known yet, try to find it.
-- The class is saved so it is known next time.
local function RefreshClass()
	if (learnedName and not learnedClass) then
		learnedClass = FindClass(learnedName);
		if (learnedClass) then
			db.assists[CharacterKey()].class = learnedClass;
		end
	end
end


--- Refuse an attempt to assist yourself, with a message and a sound.
local function RefuseSelf()
	PopMsg(L.CANNOT_ASSIST_SELF, unpack(RED)); -- assisting yourself would do nothing useful
	if (db.sound) then
		PlaySound(SOUND_REFUSED, "SFX");
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
		RefuseSelf();
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

	QueueOrSet(name, display, nil, (select(2, UnitClass(unit)))); -- no class when there is no unit
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
	local command, argument = strmatch(strtrim(msg or ""), "^(%S*)%s*(.-)$");
	command = strlower(command);
	if ("" == command) then
		if (not OpenKeyBindings()) then
			print(L.KEYS_CANNOT_OPEN);
		end
	elseif ("sound" == command) then
		db.sound = not db.sound;
		print(db.sound and L.SOUND_ON or L.SOUND_OFF);
	elseif ("set" == command) then
		if ("" == argument) then
			print(L.SET_NEEDS_NAME);
		elseif (strlower(argument) == strlower(UnitName("player"))) then
			RefuseSelf();
		else
			-- typed as is, so a player's second name can contain a space
			QueueOrSet(argument, argument, nil, FindClass(argument));
		end
	elseif ("status" == command) then
		RefreshClass();
		print(learnedDisplay and (L.STATUS_ASSISTING .. ColoredName(learnedDisplay, learnedClass)) or L.STATUS_NONE);
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
		QuickAssistDB.assists = QuickAssistDB.assists or {}; -- the player each character assists
		db = QuickAssistDB;

		-- bring back the player this character was assisting before the reload or relog
		local saved = db.assists[CharacterKey()];
		if (saved) then
			QueueOrSet(saved.name, saved.display, true, saved.class);
		end

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
		-- learnedDisplay is nil here when the restore waits for combat to end
		if (learnedDisplay) then
			RefreshClass();
			print(L.STILL_ASSISTING .. ColoredName(learnedDisplay, learnedClass));		end

	elseif (event == "GROUP_ROSTER_UPDATE") then
		RefreshClass(); -- the player may have just joined our group

	elseif (event == "UPDATE_BINDINGS") then
		UpdateBindings();

	elseif (event == "PLAYER_REGEN_ENABLED") then -- left combat
		UpdateBindings();
		if (pending ~= nil) then
			if (PENDING_CLEAR == pending) then
				SetAssist(nil);
			else
				SetAssist(pending.name, pending.display, nil, pending.class);
			end
			pending = nil;
		end
	end
end);
events:RegisterEvent("PLAYER_LOGIN");
events:RegisterEvent("PLAYER_ENTERING_WORLD");
events:RegisterEvent("UPDATE_BINDINGS");
events:RegisterEvent("PLAYER_REGEN_ENABLED");
events:RegisterEvent("GROUP_ROSTER_UPDATE");
