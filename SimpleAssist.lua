local ADDON_NAME = ...; -- folder name, passed by WoW to every file in the TOC

-- Globals:
-- ========
-- our big global object:
SassAddon = {
	addon_loaded = false,
	pending_learn = nil
};


-- boot frame:
local boot_frame = CreateFrame("Frame")
boot_frame:RegisterEvent("ADDON_LOADED")
boot_frame:SetScript(
  "OnEvent", function(frame,event, addon, ...)
		if frame == boot_frame then
	    SassAddon.init(event, addon);
		end
  end
);


-- My local functions:
-- ====================


--- Once the addon is loaded, register all our events and create our frames
--
function SassAddon.init(event, addon)
	if event == "ADDON_LOADED" and addon == ADDON_NAME then

		if ( false == SassAddon.addon_loaded ) then -- only need to load once
			SassAddon.addon_loaded = true;

			SassAddon.eventframe = CreateFrame("Frame" ); -- the frame to listen to all our events
			local ev = SassAddon.eventframe; -- local shortcut

			local f =  CreateFrame("CheckButton", "SimpleAssistActionButton", UIParent, "ActionBarButtonTemplate");

			f:SetAttribute("type", "macro");
			f:SetAttribute("width", "30");
			f:SetAttribute("height", "30");
			f:SetAttribute("macrotext", "/assist target");
			f:ClearAllPoints();
			-- putting the button off-screen to make it invisible
			f:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 50, 50); -- (point, frame, relativePoint , x, y);

			ev:RegisterEvent("UPDATE_BINDINGS");
			ev:RegisterEvent("PLAYER_REGEN_ENABLED"); -- leaving combat
			ev:SetScript("OnEvent", SassAddon.HandleEvent);
		end --SassAddon.addon_loaded
	end -- ADDON_LOADED
end


--- Main WoW Event handler
function SassAddon.HandleEvent(frame, event, ...)
	if (event == "UPDATE_BINDINGS") then
		SimpleAssist_UpdateBindings();

	elseif (event == "PLAYER_REGEN_ENABLED") then
		if (SassAddon.pending_learn ~= nil) then -- we have a "learn" pending from combat
			if ("pending clear" == SassAddon.pending_learn) then
				SimpleAssistActionButton:SetAttribute("macrotext", "/assist target");
				SimpleAssist_PopMsg(SASSTEXT.CLEARED);
			else
				-- expand the macro code here
				SimpleAssistActionButton:SetAttribute("macrotext", "/assist " .. SassAddon.pending_learn);
				SimpleAssist_PopMsg(SASSTEXT.ASSIST_SET ..": " .. SassAddon.pending_learn);
			end
			SassAddon.pending_learn = nil;
		end
	end
end


function SimpleAssist_UpdateBindings()
 if nil ~= SimpleAssistActionButton then
			local key1, key2 = GetBindingKey("Assist Learned Player");
				if (key1) then -- SetOverrideBindingClick(owner, isPriority, "KEY", "ButtoName"[,"mouseButton"]);
					SetOverrideBindingClick(
						SassAddon.eventframe, -- owner frame
						false, -- isPriority, even false is higher than normal bindings
						key1,
						"SimpleAssistActionButton" -- buttonName
					);
			end
		end -- button has been instantiated
end


-- In Game Functions:

---
-- "Learn" the current target as the unit to assist
-- {unit} = ID of unit to be set as assist (from Target)
--
function  SimpleAssist_LearnAssist(unit)

	if (InCombatLockdown()) then
		local thisUnitName=UnitName(unit);
		if (thisUnitName==nil) then
			SassAddon.pending_learn="pending clear"; -- use a name with a space and no upper-case
			SimpleAssist_PopMsg(SASSTEXT.CLEAR_PENDING);
		else
			SassAddon.pending_learn=thisUnitName;
			SimpleAssist_PopMsg(SASSTEXT.ASSIST_PENDING .. thisUnitName);
		end
	else
		SimpleAssist_PrivateLearnAssist(unit);
	end
end -- function


---
-- The actual function to learn the unit to assist
-- Since this can't be called during combat,
-- it will be called by SimpleAssist_LearnAssist
-- @param  unit to remember. if no unit, clear the remembered "assistee"
function SimpleAssist_PrivateLearnAssist(unit)

	if (UnitName(unit) == nil) then
		SimpleAssistActionButton:SetAttribute("macrotext", "/assist target");
		SimpleAssist_PopMsg(SASSTEXT.CLEARED);
	end

	if (UnitIsPlayer(unit)) then
		if (UnitIsFriend("target", unit)) then -- unit could technically be "target" here... (changed from player to target for Battle of Darrowshire and similar events
				local thisUnitName=UnitName(unit);
				-- expand the macro code here
				SimpleAssistActionButton:SetAttribute("macrotext", "/assist "..thisUnitName);
				SimpleAssist_PopMsg(SASSTEXT.ASSIST_SET ..": " .. thisUnitName);
		end -- friend
	end -- player
end


function SimpleAssist_PopMsg(msg)
-- Our head's up display for this AddOn
-- Inputs: {msg} = message to display in the HUD
    if (SchnoggoAlertInform) then
    	SchnoggoAlertInform(msg);
    else
		SimpleAssistAlertFrame:AddMessage(msg, 1, 1, 1, 1, 3);
    end
end

function SimpleAssist_DoAssist()
-- this function is now a dummy. It exists only so that a keybinding can be set.

end
