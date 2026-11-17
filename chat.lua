--[[
	Chat tweaks

	Everything in here is built to keep Blizzard's chat message handling untainted, so that
	secret chat values (chat messaging lockdown) keep working. In particular AddMessage is never
	replaced and no chat global strings are overridden.
]]

--[[
	Configuration
]]

-- Timestamps, applied through the built-in timestamp setting (false to leave the setting alone)
local timestampFormat = TIMESTAMP_FORMAT_HHMMSS_24HR or "%H:%M:%S "

-- Sticky chat types
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
	EMOTE = false,
}

-- Short channel tags, keyed by the global string that holds the long tag
local shortChannelTags = {
	CHAT_GUILD_GET = "(G)",
	CHAT_OFFICER_GET = "(O)",
	CHAT_PARTY_GET = "(P)",
	CHAT_PARTY_LEADER_GET = "(PL)",
	CHAT_PARTY_GUIDE_GET = "(DG)",
	CHAT_RAID_GET = "(R)",
	CHAT_RAID_LEADER_GET = "|cffff3399(|rRL|cffff3399)|r",
	CHAT_RAID_WARNING_GET = "|cffff0000(|rRW|cffff0000)|r",
	CHAT_INSTANCE_CHAT_GET = "(I)",
	CHAT_INSTANCE_CHAT_LEADER_GET = "|cffff3399(|rIL|cffff3399)|r",
}

-- Tag for numbered channels, "[2. Trade - City]" turns into this with the channel number and the
-- first word of the name
local numberedChannelTag = "|cff990066(|r%s. %s|cff990066)|r"

-- Lines scrolled per mouse wheel step (shift: top/bottom, ctrl: one page)
local scrollLines = 1

-- Clickable URLs
local urlLinkFormat = "|cffffffff|Haddon:NevMod:url:%s|h[%s]|h|r"

local urlEvents = {
	"CHAT_MSG_SAY",
	"CHAT_MSG_YELL",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_COMMUNITIES_CHANNEL",
}

--[[
	-------------------------------------------------------------
	Code
]]
local _G = _G
local type, pairs, ipairs = type, pairs, ipairs
local issecretvalue = issecretvalue

-- Timestamps
if timestampFormat then
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:SetScript("OnEvent", function()
		if C_CVar.GetCVar("showTimestamps") ~= timestampFormat then
			C_CVar.SetCVar("showTimestamps", timestampFormat)
		end
	end)
end

-- Sticky
for chatType, sticky in pairs(stickyTypes) do
	local info = ChatTypeInfo[chatType]
	local value = sticky and 1 or 0
	-- only touch entries that actually differ, to keep the rest of the table untainted
	if info and info.sticky ~= value then
		info.sticky = value
	end
end

-- Short channel tags
-- The long tags are baked into the line by Blizzard's message formatting, and neither that code
-- nor its format strings can be changed without tainting it. So the line is rewritten right after
-- it was added. Lines with secret text can't be rewritten and keep their long tag.
local ShortenChannelTags
do
	local linkedTags = {} -- tags shown inside a channel link, long tag -> short tag
	local plainTags = {} -- tags without a link, list of { "[Long Tag]", short tag }

	for globalName, short in pairs(shortChannelTags) do
		local format = _G[globalName]
		local tag = type(format) == "string" and format:match("%[(.-)%]")
		if tag then
			if format:find("|Hchannel:", 1, true) then
				linkedTags[tag] = short
			else
				plainTags[#plainTags + 1] = { "[" .. tag .. "]", short }
			end
		end
	end

	local function ReplaceLinkedTag(linkStart, tag, linkEnd)
		local short = linkedTags[tag]
		if not short then
			local number, name = tag:match("^(%d+)%.%s*([^%s%]]+)")
			if number then
				short = numberedChannelTag:format(number, name)
			end
		end
		if short then
			return linkStart .. short .. linkEnd
		end
	end

	function ShortenChannelTags(text)
		if not text:find("[", 1, true) then
			return text
		end

		local count
		text, count = text:gsub("(|Hchannel:[^|]*|h)%[([^%]]*)%](|h)", ReplaceLinkedTag, 1)
		if count > 0 then
			return text
		end

		for _, plain in ipairs(plainTags) do
			local s, e = text:find(plain[1], 1, true)
			if s then
				-- only at the start of the line, allowing for a timestamp in front of it
				local prefix = text:sub(1, s - 1)
				if #prefix <= 12 and not prefix:find("[%[|]") then
					return prefix .. plain[2] .. text:sub(e + 1)
				end
			end
		end

		return text
	end
end

local function OnMessageAdded(frame, text)
	if issecretvalue(text) or type(text) ~= "string" then
		return
	end

	local shortened = ShortenChannelTags(text)
	if shortened == text then
		return
	end

	local function IsAddedMessage(message)
		return not issecretvalue(message) and message == text
	end

	local function ReplaceText(message, ...)
		return shortened, ...
	end

	frame:TransformMessages(IsAddedMessage, ReplaceText)
end

-- Clickable URLs
-- Done in a message filter, which Blizzard skips on its own while the message is secret.
do
	local function IsPortOrPath(rest)
		return rest:find("^:%d+$") or rest:find("^:%d+/") or rest:find("^/")
	end

	local function IsURL(word)
		-- X://Y url
		if word:find("^%a[%w%.+-]+://%S") then
			return true
		end
		-- www.X.Y url
		if word:find("^www%.[-%w_%%]+%.%S") then
			return true
		end
		-- X@Y.Z email
		if word:find("^[^@]+@[-%w_%%%.]+%.%a%a+$") then
			return true
		end
		-- IPv4 address, optionally with port and/or path
		local rest = word:match("^%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?(.*)$")
		if rest then
			return rest == "" or IsPortOrPath(rest)
		end
		-- X.Y.Z domain with port and/or path
		rest = word:match("^[-%w_%%%.]*[-%w_%%]%.%a%a+([:/].*)$")
		if rest then
			return IsPortOrPath(rest)
		end
		return false
	end

	local function LinkWord(word)
		-- leave anything with escape sequences alone (links, textures, ...)
		if word:find("|", 1, true) then
			return
		end

		-- punctuation after the url belongs to the sentence
		local url, trailing = word:match("^(.-)([%.,!%?]*)$")
		if #url > 4 and IsURL(url) then
			return urlLinkFormat:format(url, url) .. trailing
		end
	end

	local function UrlFilter(chatFrame, event, message, ...)
		if issecretvalue(message) or type(message) ~= "string" or #message < 5 then
			return false
		end

		local linked = message:gsub("%S+", LinkWord)
		if linked ~= message then
			return false, linked, ...
		end
		return false
	end

	for _, event in ipairs(urlEvents) do
		ChatFrameUtil.AddMessageEventFilter(event, UrlFilter)
	end

	StaticPopupDialogs["NEVMOD_URL_COPY"] = {
		text = "URL",
		button1 = CLOSE,
		hasEditBox = 1,
		editBoxWidth = 350,
		OnShow = function(dialog, data)
			local editBox = dialog:GetEditBox()
			editBox:SetMaxLetters(0)
			editBox:SetText(data)
			editBox:SetFocus()
			editBox:HighlightText()
		end,
		EditBoxOnEnterPressed = StaticPopup_StandardEditBoxOnEscapePressed,
		EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1,
	}

	-- "addon" links are dispatched through this event
	EventRegistry:RegisterCallback("SetItemRef", function(_, link)
		local url = type(link) == "string" and link:match("^addon:NevMod:url:(.+)$")
		if url then
			StaticPopup_Show("NEVMOD_URL_COPY", nil, nil, url)
		end
	end, "NevModChat")
end

-- Buttons
-- Parenting to a hidden frame keeps them hidden no matter who calls Show on them.
local hiddenParent = CreateFrame("Frame")
hiddenParent:Hide()

-- the quick join toast button and the text to speech button live outside of the button frame
if QuickJoinToastButton then
	QuickJoinToastButton:SetParent(hiddenParent)
end
if TextToSpeechButtonFrame then
	TextToSpeechButtonFrame:SetParent(hiddenParent)
end

local function ResetClampInsets(frame)
	frame:SetClampRectInsets(0, 0, 0, 0)
end

-- Scroll
local function OnMouseWheel(frame, delta)
	if delta > 0 then
		if IsShiftKeyDown() then
			frame:ScrollToTop()
		elseif IsControlKeyDown() then
			frame:PageUp()
		else
			frame:ScrollByAmount(scrollLines)
		end
	elseif delta < 0 then
		if IsShiftKeyDown() then
			frame:ScrollToBottom()
		elseif IsControlKeyDown() then
			frame:PageDown()
		else
			frame:ScrollByAmount(-scrollLines)
		end
	end
end

-- Per chat frame setup
local augmentedFrames = {}

local function AugmentChatFrame(frame)
	if augmentedFrames[frame] then
		return
	end
	augmentedFrames[frame] = true

	-- Short channel tags
	hooksecurefunc(frame, "AddMessage", OnMessageAdded)

	-- Buttons: hide the button frame, this includes the menu and channel buttons on the first frame
	if frame.buttonFrame then
		frame.buttonFrame:SetParent(hiddenParent)
	end

	-- Allow the chat frame to move to the edge of the screen
	ResetClampInsets(frame)
	if frame.UpdateClampOffsets then
		hooksecurefunc(frame, "UpdateClampOffsets", ResetClampInsets)
	end

	-- Editbox: on top of the chat frame, arrow keys work without holding alt
	local editBox = frame.editBox
	if editBox then
		editBox:ClearAllPoints()
		editBox:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -5, 0)
		editBox:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 5, 0)
		editBox:SetAltArrowKeyMode(false)
	end

	-- Scroll
	frame:EnableMouseWheel(true)
	frame:SetScript("OnMouseWheel", OnMouseWheel)
end

local function AugmentChatFrames()
	for _, name in pairs(CHAT_FRAMES) do
		local frame = _G[name]
		if frame then
			AugmentChatFrame(frame)
		end
	end
end

AugmentChatFrames()

-- temporary windows (whisper windows, pet battle log, ..) are created on demand
hooksecurefunc("FCF_OpenTemporaryWindow", AugmentChatFrames)
