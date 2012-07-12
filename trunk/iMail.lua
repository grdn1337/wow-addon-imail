-----------------------------------
-- Setting up scope and libs
-----------------------------------

local AddonName, iMail = ...;
LibStub("AceEvent-3.0"):Embed(iMail);

local L = LibStub("AceLocale-3.0"):GetLocale(AddonName);

local _G = _G;
local format = _G.string.format;

-------------------------------
-- Registering with iLib
-------------------------------

LibStub("iLib"):Register(AddonName, nil, iMail);

------------------------------------------
-- Variables, functions and colors
------------------------------------------

local newMails = false;

local COLOR_GOLD = "|cfffed100%s|r";
local COLOR_GREEN= "|cff00ff00%s|r";

-----------------------------
-- Setting up the LDB
-----------------------------

iMail.ldb = LibStub("LibDataBroker-1.1"):NewDataObject(AddonName, {
	type = "data source",
	text = "",
	icon = "Interface\\Minimap\\Tracking\\Mailbox",
});

iMail.ldb.OnEnter = function(anchor)
	if( not newMails or iMail:IsTooltip("Main") ) then
		return;
	end
	
	iMail:HideAllTooltips();
	
	local tip = iMail:GetTooltip("Main", "UpdateBroker");
	tip:SetAutoHideDelay(0.25, anchor);
	tip:SmartAnchorTo(anchor);
	tip:Show();
end

iMail.ldb.OnLeave = function() end

----------------------
-- Initializing
----------------------

function iMail:Boot()
	self:RegisterEvent("UPDATE_PENDING_MAIL", "MailUpdate");
	self:RegisterEvent("MAIL_INBOX_UPDATE", "MailProcess");
	self:RegisterEvent("MAIL_SHOW", "MailProcess");
	
	_G.MiniMapMailFrame.Show = _G.MiniMapMailFrame.Hide;
	_G.MiniMapMailFrame:Hide();
	
	self:MailUpdate();
end
iMail:RegisterEvent("PLAYER_ENTERING_WORLD", "Boot");

------------------------------------------
-- UpdateTooltip
------------------------------------------

function iMail:MailUpdate()
	newMails = _G.HasNewMail() and true or false;
	self:UpdateBroker();
end

function iMail:MailProcess()
	newMails = false;
		
	for i = 1, _G.GetInboxNumItems() do
		local _, _, _, _, _, _, _, _, wasRead = _G.GetInboxHeaderInfo(i);
		if( not wasRead ) then
			newMails = true;
		end
	end
	
	self:UpdateBroker();
end

------------------------------------------
-- UpdateTooltip
------------------------------------------

function iMail:UpdateBroker(tip)
	if( newMails ) then
		self.ldb.text = (COLOR_GREEN):format(L["New Mails"]);
	else
		self.ldb.text = L["No Mails"];
	end
	
	if( tip ) then
		tip:Clear();
		tip:SetColumnLayout(1, "LEFT");
		
		local sender1, sender2, sender3 = _G.GetLatestThreeSenders();
		
		if( sender1 or sender2 or sender3 ) then
			tip:AddLine((COLOR_GOLD):format(_G.HAVE_MAIL_FROM));
		else
			tip:AddLine((COLOR_GOLD):format(_G.HAVE_MAIL));
		end
		
		if( sender1 ) then
			tip:AddLine(sender1);
		end
		if( sender2 ) then
			tip:AddLine(sender2);
		end
		if( sender3 ) then
			tip:AddLine(sender3);
		end
	end
end