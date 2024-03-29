-- HereBeDragons debug helper
local HBD = LibStub("HereBeDragons-2.0", true)
if HBD then
	local f = CreateFrame("Frame")
	local elapsed_total = 0
	local warned = {}

	function checkInstanceId()
		local x,y,instance = HBD:GetPlayerWorldPosition()
		local zone = HBD:GetPlayerZone()
		if instance and instance ~= -1 and HBD.mapData[zone] and HBD.mapData[zone].instance ~= instance and zone ~= -1 and not warned[instance] then
			print(format("HereBeDragons-2.0: Instance ID %d does not match %d for zone %d", instance, HBD.mapData[zone].instance, zone))
			warned[instance] = true
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
	HBD.RegisterCallback("NevMod", "PlayerZoneChanged", function(_, zone, mapType) print(format("NevMod: Location changed to %s %s (%s)", tostring(zone), tostring(mapType), HBD:GetLocalizedMap(zone) or "")) checkInstanceId() end)

	HBD.___DIIDO = setmetatable(HBD.___DIIDO, { __newindex = function(t, k, v) rawset(t, k, v); print(format("HBD: Found a new dynamic instance ID override %d -> %d, in zone %d", k, v, (HBD:GetPlayerZone()))) end })
end
