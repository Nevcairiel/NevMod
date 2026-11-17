-- automatically enable minimap target tracking when targeting a rare
local Tracking = LibStub("AceAddon-3.0"):GetAddon("NevMod"):NewModule("Tracking", "AceEvent-3.0")

function Tracking:OnEnable()
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "UpdateTracking")
end

local function ToggleTargetTracking(mode)
	local count = C_Minimap.GetNumTrackingTypes()
	for id = 1, count do
		local info = C_Minimap.GetTrackingInfo(id)
		if info.name == "Target" then
			C_Minimap.SetTracking(id, mode)
			return
		end
	end
end

function Tracking:UpdateTracking()
	local classificiation = UnitClassification("target")
	if classificiation and (classificiation == "rare" or classificiation == "rareelite") then
		ToggleTargetTracking(true)
	else
		ToggleTargetTracking(false)
	end
end
