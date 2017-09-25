-- [BONES]
-- Created by Intoxx (Eadwin-Defias-Brotherhood EU)
-- Update : 25/09/2017
-- LICENCE : MIT
------------------------------ VARIABLES ------------------------------
local NAME = "Bones";
local VERSION = "0.4";

local BUFF_LIST = {
	["Jolly Roger"] = {
		id = 199603,
		enabled = false,
		name = nil,
		icon = nil,
		texture = nil,
		frame = nil,
		cooldown = nil
	},
	["Grand Melee"] = {
		id = 193358,
		enabled = false,
		name = nil,
		icon = nil,
		texture = nil,
		frame = nil,
		cooldown = nil
	},
	["Shark Infested Waters"] = {
		id = 193357,
		enabled = false,
		name = nil,
		icon = nil,
		texture = nil,
		frame = nil,
		cooldown = nil
	},
	["True Bearing"] = {
		id = 193359,
		enabled = false,
		name = nil,
		icon = nil,
		texture = nil,
		frame = nil,
		cooldown = nil
	},
	["Buried Treasure"] = {
		id = 199600,
		enabled = false,
		name = nil,
		icon = nil,
		texture = nil,
		frame = nil,
		cooldown = nil
	},
	["Broadsides"] = {
		id = 193356,
		enabled = false,
		name = nil,
		icon = nil,
		texture = nil,
		frame = nil,
		cooldown = nil
	}
};

local mainframe;
local icon_size = 48;
local TooltipsEnabledBool = true;

SLASH_COMMAND1 = "/bones";

SlashCmdList["COMMAND"] = function(msg)
	if msg == 'help' then
		print_help();
	elseif msg == 'version' then
		print_version();
	elseif msg == 'unlock' then
		unlockMainFrame();
		print(text{color="yellow", msg="["..NAME.." - mainframe] unlocked"});
	elseif msg == 'lock' then
		lockMainFrame();
		print(text{color="yellow", msg="["..NAME.." - mainframe] locked"});
	elseif msg == 'tooltips_on' then
		enableTooltips(true);
		print(text{color="yellow", msg="["..NAME.." - tooltips] enabled"});
	elseif msg == 'tooltips_off' then
		enableTooltips(false);
		print(text{color="yellow", msg="["..NAME.." - tooltips] disabled"});
	elseif msg == 'reset' then
		reset();
	else -- [FIX ME] add config UI
		print_help(); -- temporary
	end
end

------------------------------ LOGIC ------------------------------

function text(arg)
	--
	-- This function return a string in the specified color --
	--
	local colors = {
		white = "|cFFFFFFFF",
		red = "|cFFFF0000",
		green = "|cFF00FF00",
		blue = "|cFF0000FF",
		yellow = "|cFFFFFF00"
	};

	return (colors[arg.color]..arg.msg);
end

function print_help()
	print(text{color="yellow", msg="["..NAME.." - help]"});
	print(text{color="yellow", msg="- '/bones help' print this help"});
	print(text{color="yellow", msg="- '/bones version' print addon's version"});
	print(text{color="yellow", msg="- '/bones unlock' to unlock the mainframe"});
	print(text{color="yellow", msg="- '/bones lock' to lock the mainframe"});
	print(text{color="yellow", msg="- '/bones tooltips_on' to enable tooltips on buffs"});
	print(text{color="yellow", msg="- '/bones tooltips_off' to disable tooltips on buffs"});
	print(text{color="yellow", msg="- '/bones reset' to reset bones"});
end

function print_version()
	print(text{color="yellow", msg="["..NAME.."] version "..VERSION});
end

function player_log_in()
	print(
		text{color="yellow", msg="["..NAME.."] by "} ..
		text{color="red", msg="Intoxx (Eadwin-Defias-Brotherhood EU)"} ..
		text{color="white", msg=" "..VERSION.. " loaded (see /bones help)"}
	);
end

function reset()
	print(text{color="yellow", msg="["..NAME.."] mainframe reset"});
	resetMainFrame();
	enableTooltips(TooltipsEnabledBool);
end

----- Events -----
function OnEvent(self, event, arg1)
	--
	-- Main event handler function --
	--
	if(event == "PLAYER_LOGIN") then -- When the addon is loaded with first load and /reload
		-- We call the init function
		player_log_in();
	end
end

function OnUpdate()
	--print("checkCooldowns");
	for i, buff in pairs(BUFF_LIST) do
		local n,_,_,_,_,duration,expiration = UnitBuff("player", buff.name)

		if n then -- and buff.enabled == false then
			if buff.enabled then -- [FIX ME] add a timelapse to update
				-- Buff exists but is already show, do we need to update
				showBuffWithCooldown(buff, duration, expiration);
			else
				-- Buff exists and need to be show
				showBuffWithCooldown(buff, duration, expiration);
			end
		elseif n == nil and buff.enabled == true then
			-- Buff doesn't exist, need to hide it
			hideBuffWithCooldown(buff);
		end
	end
end

------------------------------ MainFrame ------------------------------
function createMainFrame()
	mainframe = CreateFrame("Frame", "MainFrame", UIParent)
	-- The code below makes the mainframe visible, and is not necessary to enable dragging.
	mainframe:ClearAllPoints();
	mainframe:SetPoint("CENTER", UIParent, "CENTER", 0, -230);
	mainframe:SetWidth(icon_size*6);
	mainframe:SetHeight(icon_size);

	mainframe.texture = mainframe:CreateTexture("ARTWORK");
	mainframe.texture:SetAllPoints();
	mainframe.texture:SetTexture(1.0, 0.5, 0);
	mainframe.texture:SetAlpha(0);

	mainframe:SetMovable(true)
	mainframe:EnableMouse(false)
	mainframe:SetClampedToScreen(true); -- Remove if problem with multiple screen
end

function registerMainFrame()
	mainframe:RegisterForDrag("LeftButton")
	mainframe:SetScript("OnDragStart", mainframe.StartMoving)
	mainframe:SetScript("OnDragStop", mainframe.StopMovingOrSizing)

	mainframe:RegisterEvent("PLAYER_LOGIN");
	mainframe:RegisterEvent("UNIT_AURA", "player");
	mainframe:RegisterEvent("ADDON_LOADED");
	mainframe:RegisterEvent("PLAYER_LOGOUT");
	mainframe:SetScript('OnUpdate', OnUpdate)
	mainframe:SetScript("OnEvent", OnEvent);
end

function resetMainFrame()
	mainframe:ClearAllPoints();
	mainframe:SetPoint("CENTER", UIParent, "CENTER", 0, -230);
	mainframe:SetWidth(icon_size*6);
	mainframe:SetHeight(icon_size);
end

function unlockMainFrame()
	mainframe.texture:SetAlpha(0.5);
	mainframe:EnableMouse(true);
end

function lockMainFrame()
	mainframe.texture:SetAlpha(0);
	mainframe:EnableMouse(false);
end

------------------------------ Buffs, Cooldowns and Tooltips ------------------------------
function createBuffWithCooldown(buff, x, y)
	-- Create frame
	buff.frame = CreateFrame("Frame", nil, mainframe);
	buff.frame:SetSize(icon_size, icon_size);
	buff.frame:SetPoint("LEFT", mainframe, x, y);

	-- Create texture
	buff.texture = buff.frame:CreateTexture();
	buff.texture:SetAllPoints();
	buff.texture:SetTexture(buff.icon);

	-- Create cooldown --
	buff.cooldown = CreateFrame("Cooldown", nil, buff.frame, "CooldownFrameTemplate");
	buff.cooldown:SetAllPoints();
	buff.cooldown:SetHideCountdownNumbers(false);

	hideBuffWithCooldown(buff);
end

function createEachBuffWithCooldown()
	local x = 0;

	for i, buff in pairs(BUFF_LIST) do
		buff.name,_,buff.icon = GetSpellInfo(buff.id);
		createBuffWithCooldown(buff, x, 0);
		x = x + 48;
	end
end

function showBuffWithCooldown(buff, duration, expiration)
	--print("["..buff.name.."] present, enabling buff");
	local startTime = expiration-duration;
	buff.enabled = true;
	buff.frame:Show();
	--buff.cooldown:SetCooldown(expiration-duration, duration);
	CooldownFrame_Set(buff.cooldown, startTime, duration-1, 1)
end

function hideBuffWithCooldown(buff)
	--print("["..buff.name.."] is not present, disabling buff");
	buff.enabled = false;
	buff.frame:Hide();
	CooldownFrame_Clear(buff.cooldown);
end

function enableTooltips(enabled)
	for i, buff in pairs(BUFF_LIST) do
		if enabled then
			buff.frame:EnableMouse(true);
			buff.frame:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_LEFT");
				GameTooltip:SetSpellByID(buff.id);
				GameTooltip:Show();
			end);
			buff.frame:SetScript("OnLeave", function(self)
				GameTooltip:Hide();
			end);
		else
			buff.frame:EnableMouse(false);
			buff.frame:SetScript("OnEnter", nil);
			buff.frame:SetScript("OnLeave", nil);
		end
	end
end
------------------------------ CONFIG ------------------------------
function showConfig()
	-- [FIX ME]
end

------------------------------ MAIN ------------------------------
createMainFrame();
createEachBuffWithCooldown();
enableTooltips(TooltipsEnabledBool);
registerMainFrame();