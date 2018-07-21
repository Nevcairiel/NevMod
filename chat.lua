--[[
	Configuration 
]]

-- Timestamps
local timeStampFormat = "%X"
local timeStampOutput = "|cFFFFFFFF%s|||r %s"

local timeStampsEnabled = {
	true, -- [1]
	true, -- [2]
	true, -- [3]
	true, -- [4]
	true, -- [5]
	true, -- [6]
	true  -- [7]
}

-- Sticky
local stickyTypes = {
	SAY = true,
	WHISPER = false,
	YELL = false,
	PARTY = true,
	GUILD = true,
	OFFICER = true,
	RAID = true,
	RAID_WARNING = true,
	INSTANCE_CHAT = true,
	CHANNEL = true,
	EMOTE = false
}

-- Channel Names
local channelNamePattern = {
	["%[Guild%]"] = "(G)",
	["%[Party%]"] = "(P)",
	["%[Raid%]"] = "(R)",
	["%[Party Leader%]"] = "(PL)",
	["%[Dungeon Guide%]"] = "(DG)",
	["%[Instance%]"] = "(I)",
	["%[Instance Leader%]"] = "|cffff3399(|rIL|cffff3399)|r",
	["%[Raid Leader%]"] = "|cffff3399(|rRL|cffff3399)|r",
	["%[Raid Warning%]"] = "|cffff0000(|rRW|cffff0000)|r",
	["%[Officer%]"] = "(O)",
	["%[Battleground%]"] = "|cffff3399(|rBG|cffff3399)|r",
	["%[Battleground Leader%]"] = "|cffff0000(|rBGL|cffff0000)|r",
	["%[%d+%.%s(%w*)%]"] = "|cff990066(|r%1|cff990066)|r",
}

-- Mouse Scroll
local scrollLines = 1

-- UrlCopy
local urlStyle = " |cffffffff|Hurl:%s|h[%s]|h|r "

local urlPatterns = {
		-- X://Y url
	{ "^(%a[%w%.+-]+://%S+)", "%1"},
	{ "%f[%S](%a[%w%.+-]+://%S+)", "%1"},
		-- www.X.Y url
	{ "^(www%.[-%w_%%]+%.%S+)", "%1"},
	{ "%f[%S](www%.[-%w_%%]+%.%S+)", "%1"},
		-- "W X"@Y.Z email (this is seriously a valid email)
	--{ pattern = '^(%"[^%"]+%"@[-%w_%%%.]+%.(%a%a+))', matchfunc=Link_TLD},
	--{ pattern = '%f[%S](%"[^%"]+%"@[-%w_%%%.]+%.(%a%a+))', matchfunc=Link_TLD},
		-- X@Y.Z email
	{ "(%S+@[-%w_%%%.]+%.(%a%a+))", "%1"},
		-- XXX.YYY.ZZZ.WWW:VVVV/UUUUU IPv4 address with port and path
	{ "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d/%S+)", "%1"},
	{ "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d/%S+)", "%1"},
		-- XXX.YYY.ZZZ.WWW:VVVV IPv4 address with port (IP of ts server for example)
	{ "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d)%f[%D]", "%1"},
	{ "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d)%f[%D]", "%1"},
		-- XXX.YYY.ZZZ.WWW/VVVVV IPv4 address with path
	{ "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%/%S+)", "%1"},
	{ "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%/%S+)", "%1"},
		-- XXX.YYY.ZZZ.WWW IPv4 address
	{ "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%)%f[%D]", "%1"},
	{ "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%)%f[%D]", "%1"},
		-- X.Y.Z:WWWW/VVVVV url with port and path
	{ "^([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d/%S+)", "%1"},
	{ "%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d/%S+)", "%1"},
		-- X.Y.Z:WWWW url with port (ts server for example)
	{ "^([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d)%f[%D]", "%1"},
	{ "%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d)%f[%D]", "%1"},
		-- X.Y.Z/WWWWW url with path
	{ "^([-%w_%%%.]+[-%w_%%]%.(%a%a+)/%S+)", "%1"},
	{ "%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+)/%S+)", "%1"},
		-- X.Y.Z url
	--{ "^([-%w_%%]+%.[-%w_%%]+%.%S+)", "%1"},
	--{ "%f[%S]([-%w_%%]+%.[-%w_%%]+%.%S+)", "%1"},
}

--[[ 
	-------------------------------------------------------------
	Code
]]
local _G = _G
local format, gsub, strlen, strsub = string.format, string.gsub, string.len, string.sub
local pairs, type, date = pairs, type, date

-- Timestamps + Channel Names + UrlCopy (AddMessage hooks)
do
	local orig = {}
	local function AddMessageHook(frame, text, ...)
		if type(text) == "string" then
			-- Channel Names
			for k, v in pairs(channelNamePattern) do
				text = gsub(text, k, v)
			end
			-- url copy
			if strlen(text) > 7 then
				for i = 1, #urlPatterns do
					local v = urlPatterns[i]
					text = gsub(text, v[1], format(urlStyle, v[2], v[2]))
				end
			end
			-- Time Stamp
			text = format(timeStampOutput, date(timeStampFormat), text)
		end
		return orig[frame](frame, text, ...)
	end

	for i = 1, NUM_CHAT_WINDOWS do
		local c = _G["ChatFrame"..i]
		orig[c] = c.AddMessage
		c.AddMessage = AddMessageHook
	end
	
	local currentLink, origItemRefSetHyperlink
	local function setItemRefHyperlink(tooltip, link, ...)
		if strsub(link, 1, 3) == "url" then
			currentLink = strsub(link, 5)
			StaticPopup_Show("SCMUrlCopyDialog")
			tooltip:Hide()
			return
		end
		return origItemRefSetHyperlink(tooltip, link, ...)
	end
	origItemRefSetHyperlink = ItemRefTooltip.SetHyperlink
	ItemRefTooltip.SetHyperlink = setItemRefHyperlink
	
	StaticPopupDialogs["SCMUrlCopyDialog"] = {
		text = "URL",
		button2 = CLOSE,
		hasEditBox = 1,
		hasWideEditBox = 1,
		showAlert = 1,
		OnShow = function(this)
			local editBox = _G[this:GetName().."EditBox"]
			if editBox then
				editBox:SetText(currentLink)
				editBox:SetFocus()
				editBox:HighlightText(0)
			end
			local button = _G[this:GetName().."Button2"]
			if button then
				button:ClearAllPoints()
				button:SetWidth(200)
				button:SetPoint("CENTER", editBox, "CENTER", 0, -30)
			end
			local icon = _G[this:GetName().."AlertIcon"]
			if icon then
				icon:Hide()
			end
		end,
		EditBoxOnEscapePressed = function(this) this:GetParent():Hide() end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
	}
end

-- Sticky
for k, v in pairs(stickyTypes) do
	ChatTypeInfo[k].sticky = v and 1 or 0
end

-- Buttons
local FixChatButtons
do
	-- Hide the chat shortcut button for emotes/languages/etc
	ChatFrameMenuButton.Show = ChatFrameMenuButton.Hide
	ChatFrameMenuButton:Hide()

	-- Hide the quick join toast button
	QuickJoinToastButton.Show = QuickJoinToastButton.Hide
	QuickJoinToastButton:Hide()

	-- Hide the Chat Channel button
	ChatFrameChannelButton.Show = ChatFrameChannelButton.Hide
	ChatFrameChannelButton:Hide()

	function FixChatButtons(i)
		local f = _G[format("ChatFrame%dButtonFrame", i)]
		 -- Hide the button container
		f.Show = f.Hide
		f:Hide()
		_G[format("ChatFrame%d", i)]:SetClampRectInsets(0,0,0,0) --Allow the chat frame to move to the end of the screen
	end

	for i = 1, NUM_CHAT_WINDOWS do
		FixChatButtons(i)
	end
end

-- Editbox
local FixEditBox
do
	function FixEditBox(i)
		local eb =  _G[format("%s%d%s", "ChatFrame", i, "EditBox")]
		local cf = _G[format("%s%d", "ChatFrame", i)]
		eb:ClearAllPoints()
		eb:SetPoint("BOTTOMLEFT",  cf, "TOPLEFT",  -5, 0)
		eb:SetPoint("BOTTOMRIGHT", cf, "TOPRIGHT", 5, 0)
		eb:SetAltArrowKeyMode(false)
	end

	for i =1, NUM_CHAT_WINDOWS do
		FixEditBox(i)
	end
end

-- Scroll
local FixScroll
do
	local function scroll(self, arg1)
		if arg1 > 0 then
			if IsShiftKeyDown() then
				self:ScrollToTop()
			elseif IsControlKeyDown() then
				self:PageUp()
			else
				for i = 1, scrollLines do
					self:ScrollUp()
				end
			end
		elseif arg1 < 0 then
			if IsShiftKeyDown() then
				self:ScrollToBottom()
			elseif IsControlKeyDown() then
				self:PageDown()
			else
				for i = 1, scrollLines do
					self:ScrollDown()
				end
			end
		end
	end

	function FixScroll(i)
		local cf = _G["ChatFrame"..i]
		cf:SetScript("OnMouseWheel", scroll)
		cf:EnableMouseWheel(true)
	end

	for i = 1, NUM_CHAT_WINDOWS do
		FixScroll(i)
	end
end

for i = 1, NUM_CHAT_WINDOWS do
	_G["ChatFrame"..i].isNevModAugmented = true
end

hooksecurefunc("FCF_OpenTemporaryWindow", function()
	for id, frame in pairs(CHAT_FRAMES) do
		local cf = _G[frame]
		if not cf.isNevModAugmented then
			FixChatButtons(id)
			FixEditBox(id)
			FixScroll(id)
			cf.isNevModAugmented = true
		end
	end
end)

-- disable timestamps
setfenv(ChatFrame_MessageEventHandler, setmetatable({CHAT_TIMESTAMP_FORMAT = false}, {__index = _G}))
