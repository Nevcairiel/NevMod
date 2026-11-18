--[[
	Unit tooltip style, modelled after TinyTip

	Name (Realm)             colored by reaction
	<Guild or NPC title>
	70 Orc Shaman            or for NPCs: 70 Elite Humanoid (Corpse)

	Runs as a tooltip data post call, after Blizzard has built the tooltip. While addon restrictions
	are active, the identity of NPCs (name, creature type, line text) is secret. Secret strings can
	still be concatenated and set as text, but not compared, so everything that needs to look at
	such a text is skipped and the rest of the style still applies.

	The position of the tooltip is left to Edit Mode.
]]

--[[
	Configuration
]]

-- Show the realm of players from other realms behind their name
-- (Forever has no realms, players always show their first name and surname there)
local showRealm = true

-- Show the race of players on the level line
local showRace = true

-- Show the creature type of NPCs and pets on the level line
local showCreatureType = true

-- Tint the background by reaction for players and pets, and grey for dead or tapped units
local tintBackground = true

-- Remove the "PvP" line
local hidePvPLine = true

-- Text colors
local friendlyPlayerColor = { 0.0, 0.67, 1.0 }
local deadColor = { 0.54, 0.54, 0.54 }
local ownGuildColor = { 0.58, 0.0, 0.83 }
local levelColor = { 1.0, 0.8, 0.0 } -- units that can't be attacked, others use the difficulty color
local detailColor = { 0.87, 0.93, 0.67 } -- race and creature type

-- Background colors
local backgroundColors = {
	hostile = { 0.5, 0.0, 0.0 },
	hostileNoAttack = { 0.5, 0.2, 0.1 }, -- hostile player that you can't attack
	neutral = { 0.5, 0.5, 0.0 },
	friendlyPlayer = { 0.0, 0.0, 0.5 },
	friendlyNPC = { 0.0, 0.5, 0.0 },
	dead = { 0.54, 0.54, 0.54 },
}

-- Classification tags on the level line, with their color
local classifications = {
	elite = { ELITE, { 1.0, 0.8, 0.0 } },
	worldboss = { BOSS, { 1.0, 0.0, 0.0 } },
	rare = { ITEM_QUALITY3_DESC, { 1.0, 0.4, 1.0 } },
	rareelite = { ITEM_QUALITY3_DESC .. " " .. ELITE, { 1.0, 0.67, 1.0 } },
}

local tappedText = "Tapped"

--[[
	-------------------------------------------------------------
	Code
]]
local _G = _G
local floor = math.floor
local issecretvalue = issecretvalue

local GameTooltip = GameTooltip
local UnitTooltipType = Enum.TooltipDataType.Unit
local UnitLevelLineType = Enum.TooltipDataLineType.UnitLevel
local UnitTypeLineType = Enum.TooltipDataLineType.UnitType
local UnitDeadLineType = Enum.TooltipDataLineType.UnitDead

-- WoW Forever: players have a first name and a surname instead of a realm
local isForever = WOW_PROJECT_ID == WOW_PROJECT_CAMELOT
local surnameSeparator = Constants.CharacterNameSeparatorConsts and Constants.CharacterNameSeparatorConsts.CHARACTERNAME_SURNAME_SEPARATOR or " "

local function Hex(r, g, b)
	return ("%02x%02x%02x"):format(floor(r * 255 + 0.5), floor(g * 255 + 0.5), floor(b * 255 + 0.5))
end

local function Colorize(text, color)
	return "|cff" .. Hex(color[1], color[2], color[3]) .. text .. "|r"
end

local function GetLine(index)
	return _G["GameTooltipTextLeft" .. index]
end

-- The unit shown by the tooltip
local function GetTooltipUnit(data)
	local guid = data.guid
	if guid and not issecretvalue(guid) then
		local unit = UnitTokenFromGUID(guid)
		if unit and not issecretvalue(unit) then
			return unit
		end
		return nil
	end

	-- The guid is secret for restricted units and can't be resolved or compared. Unit tooltips
	-- are shown for the unit under the mouse, in the world as well as on unit frames.
	if UnitExists("mouseover") then
		return "mouseover"
	end
end

-- Index of the level line
local function FindLevelLine(data, guildName)
	local lines = data.lines
	if not lines then
		return nil
	end

	for _, line in ipairs(lines) do
		local lineType = line.type
		if line.lineIndex and not issecretvalue(lineType) and lineType == UnitLevelLineType then
			return line.lineIndex
		end
	end

	-- not tagged, look for the text instead
	for _, line in ipairs(lines) do
		local text = line.leftText
		if line.lineIndex and line.lineIndex > 1 and text and not issecretvalue(text) and text ~= guildName and text:find(LEVEL, 1, true) then
			return line.lineIndex
		end
	end
end

local function GetClassColor(classFile)
	local color = classFile and not issecretvalue(classFile) and RAID_CLASS_COLORS[classFile]
	if color then
		return { color.r, color.g, color.b }
	end
	return { 1, 1, 1 }
end

local function GetLevelColor(unit, level)
	if not UnitCanAttack("player", unit) then
		return levelColor
	end
	if level <= 0 then
		local color = QuestDifficultyColors["impossible"]
		return { color.r, color.g, color.b }
	end
	local color = GetCreatureDifficultyColor(level)
	return { color.r, color.g, color.b }
end

local function BuildLevelLine(unit, isPlayer, isPlayerControlled, isDead, isTapped)
	local grey = (isDead or isTapped) and deadColor
	local level = UnitLevel(unit)

	local text = Colorize(level > 0 and level or "??", grey or GetLevelColor(unit, level))

	if isPlayer then
		if showRace then
			local race = UnitRace(unit)
			if race then
				text = text .. " " .. Colorize(race, grey or detailColor)
			end
		end

		local className, classFile = UnitClass(unit)
		if className then
			text = text .. " " .. Colorize(className, grey or GetClassColor(classFile))
		end
	else
		if not isPlayerControlled then
			local classification = classifications[UnitClassification(unit)]
			if classification then
				text = text .. " " .. Colorize(classification[1], grey or classification[2])
			end
		end

		if showCreatureType then
			local creatureType = (isPlayerControlled and UnitCreatureFamily(unit)) or UnitCreatureType(unit)
			if creatureType then
				text = text .. " " .. Colorize(creatureType, grey or detailColor)
			end
		end
	end

	if grey then
		text = text .. " " .. Colorize("(" .. (isDead and CORPSE or tappedText) .. ")", grey)
	end

	return text
end

-- Reaction colors, returns the color of the name and of the background
local function GetReactionColors(unit, isPlayerControlled)
	local reaction = UnitReaction(unit, "player")

	if (isPlayerControlled and UnitCanAttack(unit, "player")) or (not isPlayerControlled and reaction and reaction <= 2) then
		-- hostile
		local color = FACTION_BAR_COLORS[reaction or 2] or FACTION_BAR_COLORS[2]
		local background = backgroundColors.hostile
		if isPlayerControlled and not UnitCanAttack("player", unit) then
			background = backgroundColors.hostileNoAttack
		end
		return color.r, color.g, color.b, background
	elseif (isPlayerControlled and UnitCanAttack("player", unit)) or (not isPlayerControlled and reaction and reaction <= 4) then
		-- neutral
		local color = FACTION_BAR_COLORS[4]
		return color.r, color.g, color.b, backgroundColors.neutral
	end

	-- friendly
	local background = isPlayerControlled and backgroundColors.friendlyPlayer or backgroundColors.friendlyNPC

	-- secret for restricted units
	local isPvP = UnitIsPVP(unit)
	if not issecretvalue(isPvP) and isPvP then
		local color = FACTION_BAR_COLORS[6]
		return color.r, color.g, color.b, background
	elseif isPlayerControlled then
		return friendlyPlayerColor[1], friendlyPlayerColor[2], friendlyPlayerColor[3], background
	end

	local color = FACTION_BAR_COLORS[reaction or 5] or FACTION_BAR_COLORS[5]
	return color.r, color.g, color.b, background
end

local function IsOwnGuild(guildName)
	if not guildName or issecretvalue(guildName) or not IsInGuild() then
		return false
	end
	local ownGuild = GetGuildInfo("player")
	return ownGuild ~= nil and not issecretvalue(ownGuild) and ownGuild == guildName
end

local backgroundTinted = false

local function StyleUnitTooltip(tooltip, data)
	if tooltip ~= GameTooltip or tooltip:IsForbidden() then
		return
	end

	local nameLine = GetLine(1)
	if not nameLine or not nameLine:IsShown() then
		return
	end

	local unit = GetTooltipUnit(data)
	if not unit or not UnitExists(unit) then
		return
	end

	local isPlayer = UnitIsPlayer(unit)
	local isPlayerControlled = UnitPlayerControlled(unit)
	local isTapped = UnitIsTapDenied(unit)
	local isDead = UnitIsDeadOrGhost(unit)

	-- Name line, players only: plain name without title, and the realm or surname
	if isPlayer then
		local name, realm = UnitName(unit)
		if name and not issecretvalue(name) then
			-- in Forever the second value is the surname, and there are no realms
			if realm and not issecretvalue(realm) and realm ~= "" then
				if isForever then
					name = name .. surnameSeparator .. realm
				elseif showRealm then
					name = name .. " (" .. realm .. ")"
				end
			end
			nameLine:SetText(name)
		end
	end

	-- Name color
	local r, g, b, background = GetReactionColors(unit, isPlayerControlled)
	if isDead or isTapped then
		r, g, b = deadColor[1], deadColor[2], deadColor[3]
		background = backgroundColors.dead
	end
	nameLine:SetTextColor(r, g, b)

	local guildName
	if isPlayer then
		guildName = GetGuildInfo(unit)
		if issecretvalue(guildName) then
			guildName = nil
		end
	end

	local levelIndex = FindLevelLine(data, guildName)

	-- Lines between the name and the level: guild or NPC title in brackets, all in the name color
	if levelIndex and levelIndex >= 3 then
		local titleLine = GetLine(2)
		local title = titleLine and titleLine:IsShown() and titleLine:GetText()
		if title then
			-- the title may be secret, which still allows it to be concatenated
			titleLine:SetText("<" .. title .. ">")
			if IsOwnGuild(guildName) then
				titleLine:SetTextColor(ownGuildColor[1], ownGuildColor[2], ownGuildColor[3])
			else
				titleLine:SetTextColor(r, g, b)
			end
		end

		for index = 3, levelIndex - 1 do
			local line = GetLine(index)
			if line then
				line:SetTextColor(r, g, b)
			end
		end
	end

	-- Level line, battle pets keep the one from Blizzard as it shows the pet level
	if levelIndex and not UnitIsWildBattlePet(unit) and not UnitIsBattlePetCompanion(unit) then
		local levelLine = GetLine(levelIndex)
		if levelLine then
			levelLine:SetText(BuildLevelLine(unit, isPlayer, isPlayerControlled, isDead, isTapped))
		end
	end

	-- Background
	if tintBackground and tooltip.NineSlice and (isPlayerControlled or isDead or isTapped) then
		tooltip.NineSlice:SetCenterColor(background[1], background[2], background[3])
		backgroundTinted = true
	end
end

TooltipDataProcessor.AddTooltipPostCall(UnitTooltipType, StyleUnitTooltip)

-- Blizzard resets the background when the tooltip hides, but not when it is reused for something
-- else while still shown.
GameTooltip:HookScript("OnTooltipCleared", function(tooltip)
	if backgroundTinted then
		backgroundTinted = false
		if tooltip.NineSlice then
			local r, g, b = TOOLTIP_DEFAULT_BACKGROUND_COLOR:GetRGB()
			tooltip.NineSlice:SetCenterColor(r, g, b, 1)
		end
	end
end)

-- Removed lines
-- A line pre call that returns true consumes the line, so it is never added to the tooltip.

-- Blizzard shows the creature type of NPCs and the class of players on its own line below the
-- level, which is replaced by "Corpse" when dead. All of these are part of the level line here.
local function IsRedundantLine(data, lineData, text)
	local unit = GetTooltipUnit(data)
	if not unit or not UnitExists(unit) or UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
		return false
	end

	-- only when the level line that takes over the information is there
	if not FindLevelLine(data) then
		return false
	end

	local lineType = lineData.type
	if issecretvalue(lineType) then
		lineType = nil
	end
	if text and issecretvalue(text) then
		text = nil
	end

	if UnitIsDeadOrGhost(unit) and (lineType == UnitDeadLineType or text == CORPSE) then
		return true
	end

	if UnitIsPlayer(unit) then
		-- only the plain class, a line with more than that (like the specialization) stays
		local className = UnitClass(unit)
		return text ~= nil and className ~= nil and not issecretvalue(className) and text == className
	end

	if not showCreatureType then
		return false
	end
	if lineType == UnitTypeLineType then
		return true
	end

	-- not tagged, compare the text instead
	local creatureType = (UnitPlayerControlled(unit) and UnitCreatureFamily(unit)) or UnitCreatureType(unit)
	return text ~= nil and creatureType ~= nil and not issecretvalue(creatureType) and text == creatureType
end

TooltipDataProcessor.AddLinePreCall(TooltipDataProcessor.AllTypes, function(tooltip, lineData)
	if tooltip ~= GameTooltip then
		return
	end

	local info = tooltip:GetProcessingTooltipInfo()
	local data = info and info.tooltipData
	if not data or data.type ~= UnitTooltipType then
		return
	end

	local text = lineData.leftText
	if hidePvPLine and text and not issecretvalue(text) and text == PVP_ENABLED then
		return true
	end

	return IsRedundantLine(data, lineData, text)
end)
