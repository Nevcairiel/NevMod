local FrenzyRegenSkin = LibStub("AceAddon-3.0"):GetAddon("NevMod"):NewModule("FrenzyRegenSkin")

function FrenzyRegenSkin:OnEnable()
	if frenzyRegenFrame then
		frenzyRegenFrame:SetSize(258, 26)
	end
end
