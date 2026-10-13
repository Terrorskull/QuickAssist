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
local function PopMsg(msg)
	QuickAssistAlertFrame:AddMessage(msg, 1, 1, 1, 1); -- uses the frame's visible and fade times
end


--- The name to show for a unit. On WoW Forever this is the primary and the
-- secondary name, elsewhere just the name.
local function DisplayName(unit)
	local primary, secondary = UnitName(unit);
	if (primary and secondary and "" ~= secondary
		and UnitIsPlayer(unit) and RegionalUniqueNamesEnabled and RegionalUniqueNamesEnabled()) then
		return primary .. SURNAME_SEPARATOR .. secondary;
	end
	return primary;
end


--- Point the assist key at a player, or reset it to assist the current target.
-- Setting a secure attribute is not allowed during combat.
-- @param name of player to assist, or nil to clear
-- @param display name to show in messages
local function SetAssist(name, display)
	if (name) then
		button:SetAttribute("macrotext", "/assist " .. name);
		PopMsg(L.ASSIST_SET .. ": " .. display);
	else
		button:SetAttribute("macrotext", DEFAULT_MACRO);
		PopMsg(L.CLEARED);
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
	local name = UnitName(unit);
	local display = DisplayName(unit);

	if (name ~= nil and UnitIsUnit(unit, "player")) then
		PopMsg(L.CANNOT_ASSIST_SELF); -- assisting yourself would do nothing useful
		return; -- the player currently being assisted stays as it is
	end

	if (InCombatLockdown()) then
		if (name == nil) then
			pending = PENDING_CLEAR;
			PopMsg(L.CLEAR_PENDING);
		else
			pending = {name = name, display = display};
			PopMsg(L.ASSIST_PENDING .. display);
		end
		return;
	end

	if (name == nil) then
		SetAssist(nil);
	-- unit could technically be "target" here... (changed from player to target for Battle of Darrowshire and similar events)
	elseif (UnitIsPlayer(unit) and UnitIsFriend("target", unit)) then
		SetAssist(name, display);
	end
end


--- Bound to the "Assist Learned Player" key.
-- This function is a dummy. The key is overridden to click our button (see
-- UpdateBindings). It exists so the binding shows up in the Key Bindings panel.
function ns.DoAssist()
end


events:SetScript("OnEvent", function(frame, event)
	if (event == "UPDATE_BINDINGS") then
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
events:RegisterEvent("UPDATE_BINDINGS");
events:RegisterEvent("PLAYER_REGEN_ENABLED");
