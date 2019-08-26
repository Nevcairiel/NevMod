if not WorldQuestTrackerAddon then return end

--[[local hook_enabled = false
local Hook_IsQuestCriteriaForBounty(questID, bountyQuestID)
	if IsQuestCriteriaForBounty(questID, bountyQuestID) then
		return true
	end

	if not hook_enabled then
		return false
	end

	-- Nazjatar and Mechaon
	if WorldMapFrame.mapID == 1355 or WorldMapFrame.mapID == 1462 then
		return true
	end

	return false
end

local env = setmetatable({ IsQuestCriteriaForBounty = Hook_IsQuestCriteriaForBounty }, { __index = _G })
setfenv(WorldQuestTrackerAddon.UpdateWorldQuestsOnWorldMap, env)

hooksecurefunc(WorldQuestTrackerAddon, "BuildMapChildrenTable", function() hook_enabled = true end)
]]

local WQTFilter = LibStub("AceAddon-3.0"):GetAddon("NevMod"):NewModule("WQTFilter", "AceHook-3.0")
function WQTFilter:OnEnable()
	WorldQuestTrackerAddon.db.profile.filter_force_show_brokenshore = true
	WorldQuestTrackerAddon.IsArgusZone = function(mapID)
		if mapID == 1355 then -- Nazjatar
			return true
		elseif mapID == 1462 then -- Mechagon
			return true
		end
		return false
	end
end

