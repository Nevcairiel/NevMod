-- move the buff frame

BuffFrame:ClearAllPoints()
BuffFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -45, -30)
BuffFrame.__SetPoint = BuffFrame.SetPoint
hooksecurefunc(BuffFrame, "SetPoint", function() BuffFrame:ClearAllPoints() BuffFrame:__SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -45, -30) end)
BuffFrame:SetFrameStrata("MEDIUM")