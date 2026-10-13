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
-- nil (nothing pending) | player name | PENDING_CLEAR
local pending;

local button = CreateFrame("CheckButton", BUTTON_NAME, UIParent, "ActionBarButtonTemplate");
button:SetAttribute("type", "macro");
button:SetAttribute("macrotext", DEFAULT_MACRO);
button:ClearAllPoints();
-- putting the button off-screen to make it invisible
button:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 50, 50);

local events = CreateFrame("Frame");


--- Our head's up display for this addon
local function PopMsg(msg)
	QuickAssistAlertFrame:AddMessage(msg, 1, 1, 1, 1, 3);
end


--- Point the assist key at a player, or reset it to assist the current target.
-- Setting a secure attribute is not allowed during combat.
-- @param name of player to assist, or nil to clear
local function SetAssist(name)
	if (name) then
		button:SetAttribute("macrotext", "/assist " .. name);
		PopMsg(L.ASSIST_SET .. ": " .. name);
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

	if (InCombatLockdown()) then
		if (name == nil) then
			pending = PENDING_CLEAR;
			PopMsg(L.CLEAR_PENDING);
		else
			pending = name;
			PopMsg(L.ASSIST_PENDING .. name);
		end
		return;
	end

	if (name == nil) then
		SetAssist(nil);
	-- unit could technically be "target" here... (changed from player to target for Battle of Darrowshire and similar events)
	elseif (UnitIsPlayer(unit) and UnitIsFriend("target", unit)) then
		SetAssist(name);
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
				SetAssist(pending);
			end
			pending = nil;
		end
	end
end);
events:RegisterEvent("UPDATE_BINDINGS");
events:RegisterEvent("PLAYER_REGEN_ENABLED");
