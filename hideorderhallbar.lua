-- hide the orderhall commandbar
if not OrderHall_LoadUI then return end
hooksecurefunc("OrderHall_LoadUI",
	function()
		if OrderHallCommandBar then
			OrderHallCommandBar:SetScript("OnShow", nil)
			OrderHallCommandBar:SetScript("OnHide", nil)
			OrderHallCommandBar:UnregisterAllEvents()
		end
	end)
hooksecurefunc("OrderHall_CheckCommandBar", function() if OrderHallCommandBar then OrderHallCommandBar:Hide() end end)