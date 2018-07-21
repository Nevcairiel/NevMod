-- set the max camera distance
local NoHonorCooldownCount = LibStub("AceAddon-3.0"):GetAddon("NevMod"):NewModule("NoHonorCooldownCount", "AceEvent-3.0")

function NoHonorCooldownCount:OnInitialize()
	if PVPQueueFrame then
		PVPQueueFrame.HonorInset.HonorLevelDisplay.noCooldownCount = true
	else
		self:RegisterEvent("ADDON_LOADED")
	end
end

function NoHonorCooldownCount:ADDON_LOADED(_event, addon)
	if addon == "Blizzard_PVPUI" then
		PVPQueueFrame.HonorInset.HonorLevelDisplay.noCooldownCount = true
	end
end
