-- move the buff frame

-- on retail sue edit mode
if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then return end

BuffFrame:ClearAllPoints()
BuffFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -45, -30)
BuffFrame.__SetPoint = BuffFrame.SetPoint
hooksecurefunc(BuffFrame, "SetPoint", function() BuffFrame:ClearAllPoints() BuffFrame:__SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -45, -30) end)
BuffFrame:SetFrameStrata("MEDIUM")
