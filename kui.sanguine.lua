if not KuiNameplates then
	return
end

local mod = KuiNameplates:NewPlugin('SanguineIcon', 101)

function mod:Create(f)
	local sanguine = f.handler:CreateAuraFrame({
		max = 1,
		size = 32,
		squareness = 1,
		point = {'BOTTOMRIGHT','RIGHT','LEFT'},
		rows = 1,
		filter = 'HELPFUL',
		whitelist = {
			[226510] = true, -- Sanguine Ichor
		},
	})

	sanguine:SetFrameLevel(0)
	sanguine:SetWidth(32)
	sanguine:SetHeight(32)
	sanguine:SetPoint('BOTTOMRIGHT', f.bg, 'TOPRIGHT', 0, 10)

	f.SanguineIcon = sanguine
end

function mod:Initialise()
	self:RegisterMessage('Create')
end
