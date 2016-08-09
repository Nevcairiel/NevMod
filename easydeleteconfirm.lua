-- avoid having to type "DELETE" into the confirmation when destroying items
local EasyDeleteConfirm = LibStub("AceAddon-3.0"):GetAddon("NevMod"):NewModule("EasyDeleteConfirm", "AceEvent-3.0")

function EasyDeleteConfirm:OnEnable()
	self:RegisterEvent("DELETE_ITEM_CONFIRM")

	-- create item link container
	self.link = StaticPopup1:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	self.link:SetPoint('CENTER', StaticPopup1EditBox)
	self.link:Hide()

	StaticPopup1:HookScript('OnHide', function(frame) self.link:Hide() end)
end


function EasyDeleteConfirm:DELETE_ITEM_CONFIRM()
	if StaticPopup1EditBox:IsShown() then
		StaticPopup1EditBox:Hide()
		StaticPopup1Button1:Enable()

		local link = select(3, GetCursorInfo())

		self.link:SetText(link)
		self.link:Show()
	end
end
