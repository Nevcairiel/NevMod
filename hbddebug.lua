-- HereBeDragons debug helper
local HBD = LibStub("HereBeDragons-1.0", true)
if HBD then
	local f = CreateFrame("Frame")
	local elapsed_total = 0

	function checkInstanceId()
		local x,y,instance = HBD:GetPlayerWorldPosition()
		local zone = HBD:GetPlayerZone()
		if instance and HBD.mapData[zone] and HBD.mapData[zone].instance ~= instance and zone ~= -1 then
			print(format("HereBeDragons-1.0: Instance ID %d does not match %d for zone %d", instance, HBD.mapData[zone].instance, zone))
		end
	end

	f:SetScript("OnUpdate", function(frame, elapsed)
		elapsed_total = elapsed_total + elapsed
		if elapsed_total > 1 then
			checkInstanceId()
			elapsed_total = 0
		end
	end
	)
	LibStub("HereBeDragons-1.0").RegisterCallback("NevMod", "PlayerZoneChanged", function(_, zone, level, mapFile, isMicro) print(format("NevMod: Location changed to %d %d %s %s", zone, level, tostring(mapFile), tostring(isMicro))); checkInstanceId() end)
end
