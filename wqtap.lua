local WorldQuestTracker = LibStub("AceAddon-3.0"):GetAddon("WorldQuestTrackerAddon", true)
if not WorldQuestTracker then return end

function WorldQuestTracker.RewardIsArtifactPower (itemLink)
	WorldQuestTrackerScanTooltip:SetOwner (WorldFrame, "ANCHOR_NONE")
	WorldQuestTrackerScanTooltip:SetHyperlink (itemLink)

	local text = WorldQuestTrackerScanTooltipTextLeft1:GetText()
	if (text and text:match ("|cFFE6CC80")) then
		local power = WorldQuestTrackerScanTooltipTextLeft3:GetText()
		if (power) then
			if (WorldQuestTracker.GameLocale == "frFR") then
				power = power:gsub ("%s", ""):gsub ("%p", ""):match ("%d+")
			else
				local million = power:match("[%d.,]+ " .. SECOND_NUMBER)
				if million then
					million = million:match("[%d.,]+"):gsub(LARGE_NUMBER_SEPERATOR, "")
					power = tonumber(million) * 1000000
				else
					power = power:gsub ("%p", ""):match("%d+");
				end
			end
			power = tonumber (power)
			return true, power or 0
		end
	end

	local text2 = WorldQuestTrackerScanTooltipTextLeft2:GetText() --thanks @Prejudice182 on curseforge
	if (text2 and text2:match ("|cFFE6CC80")) then
		local power = WorldQuestTrackerScanTooltipTextLeft4:GetText()
		if (power) then
			if (WorldQuestTracker.GameLocale == "frFR") then
				power = power:gsub ("%s", ""):gsub ("%p", ""):match ("%d+")
			else
				local million = power:match("[%d.,]+ " .. SECOND_NUMBER)
				if million then
					million = million:match("[%d.,]+"):gsub(LARGE_NUMBER_SEPERATOR, "")
					power = tonumber(million) * 1000000
				else
					power = power:gsub ("%p", ""):match("%d+");
				end
			end
			power = tonumber (power)
			return true, power or 0
		end
	end
end
