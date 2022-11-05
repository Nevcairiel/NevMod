-- automatically enable minimap target tracking when targeting a rare
local GetNumTrackingTypes = GetNumTrackingTypes or C_Minimap.GetNumTrackingTypes
local GetTrackingInfo = GetTrackingInfo or C_Minimap.GetTrackingInfo
local SetTracking = SetTracking or C_Minimap.SetTracking

if not GetNumTrackingTypes then return end
local Tracking = LibStub("AceAddon-3.0"):GetAddon("NevMod"):NewModule("Tracking", "AceEvent-3.0")

function Tracking:OnEnable()
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "UpdateTracking")
end

local function ToggleTargetTracking(mode)
	local count = GetNumTrackingTypes()
	for id = 1, count do
		local name = GetTrackingInfo(id)
		if name == "Target" then
			SetTracking(id, mode)
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
