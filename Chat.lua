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
	YELL = true,
	PARTY = true,
	GUILD = true,
	OFFICER = true,
	RAID = true,
	RAID_WARNING = true,
	BATTLEGROUND = true,
	CHANNEL = true,
	EMOTE = false
}

-- Channel Names
local channelNamePattern = {
	["%[Guild%]"] = "(G)",
	["%[Party%]"] = "(P)",
	["%[Raid%]"] = "(R)",
	["%[Raid Leader%]"] = "|cffff3399(|rRL|cffff3399)|r",
	["%[Raid Warning%]"] = "|cffff0000(|rRW|cffff0000)|r",
	["%[Officer%]"] = "(O)",
	["%[%d+%. WorldDefense%]"] = "|cff990066(|rWD|cff990066)|r",
	["%[%d+%. General%]"] = "|cff990066(|rGEN|cff990066)|r",
	["%[%d+%. LocalDefense%]"] = "|cff990066(|rLD|cff990066)|r",
	["%[%d+%. Trade%]"] = "|cff990066(|rT|cff990066)|r",
	["%[%d+%. GuildRecruitment %- .*%]"] = "|cff990066(|rGR|cff990066)|r",
	["%[Battleground%]"] = "|cffff3399(|rBG|cffff3399)|r",
	["%[Battleground Leader%]"] = "|cffff0000(|rBGL|cffff0000)|r",
	["%[%d+%.%s(%w*)%]"] = "|cff990066(|r%1|cff990066)|r",
}

-- Mouse Scroll
local scrollLines = 1

-- UrlCopy
local urlStyle = " |cffffffff|Hurl:%s|h[%s]|h|r "

local urlPatterns = {
	{ " www%.([_A-Za-z0-9-]+)%.([_A-Za-z0-9-%.&/]+)%s?", "http://www.%1.%2"},
	{ " (%a+)://(%S+)%s?", "%1://%2"},
	{ " ([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", "%1@%2%3%4"},
	{ " ([_A-Za-z0-9-]+)%.([_A-Za-z0-9-]+)%.(%S+)%s?", "%1.%2.%3"},
	{ " ([_A-Za-z0-9-]+)%.([_A-Za-z0-9-]+)%.(%S+)%:([_0-9-]+)%s?", "%1.%2.%3:%4"},
	{ " ([_A-Za-z0-9-]+)%.(%a%a%a)%s?", "%1.%2"},
}

local hideLoot = { 
	[40752] = true, -- Emblem of Heroism
	[40753] = true, -- Emblem of Valor
	[43228] = true, -- Stone Keeper's Shard
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
	
	local currentLink, origItemRef
	local function setItemRef(link, ...)
		if strsub(link, 1, 3) == "url" then
			currentLink = strsub(link, 5)
			StaticPopup_Show("SCMUrlCopyDialog")
			return
		end
		return origItemRef(link, ...)
	end
	origItemRef = _G.SetItemRef
	_G.SetItemRef = setItemRef
	
	StaticPopupDialogs["SCMUrlCopyDialog"] = {
		text = "URL",
		button2 = TEXT(CLOSE),
		hasEditBox = 1,
		hasWideEditBox = 1,
		showAlert = 1,
		OnShow = function()
			local editBox = _G[this:GetName().."WideEditBox"]
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
		EditBoxOnEscapePressed = function() this:GetParent():Hide() end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
	}
end

-- Sticky
for k, v in pairs(stickyTypes) do
	if v then
		ChatTypeInfo[k].sticky = 1
	else
		ChatTypeInfo[k].sticky = 0
	end
end

-- Buttons
do
	local function hide(self) self:Hide() end
	
	ChatFrameMenuButton:Hide()
	
	local frame
	for i = 1, NUM_CHAT_WINDOWS do
		frame = _G["ChatFrame"..i.."UpButton"]
		frame:SetScript("OnShow", hide)
		frame:Hide()
		
		frame = _G["ChatFrame"..i.."DownButton"]
		frame:SetScript("OnShow", hide)
		frame:Hide()
		
		frame = _G["ChatFrame"..i.."BottomButton"]
		frame:SetScript("OnShow", hide)
		frame:Hide()
	end
end

-- Editbox
do
	local eb = ChatFrameEditBox
	eb:ClearAllPoints()
	eb:SetPoint("BOTTOMLEFT",  "ChatFrame1", "TOPLEFT",  -5, 0)
	eb:SetPoint("BOTTOMRIGHT", "ChatFrame1", "TOPRIGHT", 5, 0)
end

-- Scroll
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
	
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame"..i]
		cf:SetScript("OnMouseWheel", scroll)
		cf:EnableMouseWheel(true)
	end
end

local function lootfilter(msg)
	local link = msg:match("^.* receives loot: (.-)x?%d*%.$")
	if link and hideLoot[tonumber(link:match("item:(%d+)"))] then
		return true
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", lootfilter)

local function dalaYell(msg)
	if msg:find("^Reinforcements are needed on the Wintergrasp") then
		return true
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_YELL", dalaYell)
