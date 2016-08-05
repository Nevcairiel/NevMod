-- set the max camera distance
local CameraDistance = LibStub("AceAddon-3.0"):GetAddon("NevMod"):NewModule("CameraDistance", "AceEvent-3.0")

function CameraDistance:OnInitialize()
	self:RegisterEvent("VARIABLES_LOADED")
	CameraPanelOptions.cameraDistanceMaxFactor.maxValue = 2.6
end

function CameraDistance:VARIABLES_LOADED()
	SetCVar("cameraDistanceMaxFactor", "2.6")
end
