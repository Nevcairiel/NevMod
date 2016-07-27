local EquipSetSwitcher = LibStub("AceAddon-3.0"):GetAddon("NevMod"):NewModule("EquipSetSwitcher", "AceEvent-3.0")

function EquipSetSwitcher:OnEnable()
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
end

function EquipSetSwitcher:PLAYER_SPECIALIZATION_CHANGED()
	if not CanUseEquipmentSets() or not IsLoggedIn() then return end

	local tree = GetSpecialization()
	if not tree or tree == 0 then return end

	local _, spec, _, _, _, role = GetSpecializationInfo(tree)
	spec, role = spec:lower(), role:lower()

	for i = 1, GetNumEquipmentSets() do
		local name = GetEquipmentSetInfo(i)
		if spec == name:lower() or role == name:lower() then
			EquipmentManager_EquipSet(name)
			break
		end
	end
end
