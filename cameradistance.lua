-- set the max camera distance
local CameraDistance = LibStub("AceAddon-3.0"):GetAddon("NevMod"):NewModule("CameraDistance", "AceEvent-3.0")

function CameraDistance:OnInitialize()
	self:RegisterEvent("VARIABLES_LOADED")
end

function CameraDistance:VARIABLES_LOADED()
	SetCVar("cameraDistanceMaxZoomFactor", "2.6")
end
