local NevMod = LibStub("AceAddon-3.0"):NewAddon("NevMod", "AceEvent-3.0", "AceConsole-3.0")

function NevMod:OnInitialize()
	self:FixBuffPositions()
end

function NevMod:FixBuffPositions()
	BuffFrame:ClearAllPoints()
	BuffFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -45, -30)
	BuffFrame.SetPoint = function() end
	BuffFrame:SetFrameStrata("MEDIUM")

	ConsolidatedBuffs:ClearAllPoints()
	ConsolidatedBuffs:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -20, -30)
	ConsolidatedBuffs.SetPoint = function() end
	ConsolidatedBuffs:SetFrameStrata("MEDIUM")
end

function NevMod:OnEnable()
	self:RegisterEvent("MERCHANT_SHOW", "RepairAndSell")
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "UpdateTracking")
	ConsoleExec("cameraDistanceMaxFactor 4")

	MiniMapInstanceDifficulty:ClearAllPoints()
	MiniMapInstanceDifficulty:SetPoint("BOTTOMRIGHT", Minimap, "TOPRIGHT", 8, 10)

	for i=1,4 do
		_G["GroupLootFrame"..i]:SetScale(1.2)
	end

	if sRaidFrames then
		sRaidFrames.statusSpellTable[GetSpellInfo(774)] = 774
		sRaidFrames:AddStatusMap("Buff_774", 50, {"indicator-tr"}, GetSpellInfo(774), {r=1, g=1, b=0, a=1}, false, {playerOnly = true})
	end
end

-- From SmoothDurability
local function CostString(cost)
	local gold = abs(cost / 10000)
	local silver = abs(mod(cost / 100, 100))
	local copper = abs(mod(cost, 100))

	if cost > 10000 then
		return string.format( "|cffffffff%d|r|cffffd700g|r |cffffffff%d|r|cffc7c7cfs|r |cffffffff%d|r|cffeda55fc|r", gold, silver, copper)
	elseif cost > 100 then
		return string.format( "|cffffffff%d|r|cffc7c7cfs|r |cffffffff%d|r|cffeda55fc|r", silver, copper)
	else 
		return string.format("|cffffffff%d|r|cffeda55fc|r", copper )
	end
end

function NevMod:RepairAndSell()
	-- Repair Equipment
	if CanMerchantRepair() then
		local cost = GetRepairAllCost()
		local money = GetMoney()
		if money < cost then
			self:Print( string.format("Autorepair failed, you need %s more.", CostString( cost - money )) )
		elseif cost > 0 then
			local guildRepair = CanGuildBankRepair()
			if guildRepair then
				local funds = GetGuildBankWithdrawMoney()  
				if funds == -1 then  
					funds = GetGuildBankMoney()  
				else  
					funds = math.min(funds, GetGuildBankMoney())  
				end
				if funds > 0 then
					self:Print( string.format("Autorepaired for %s using guild funds %s.", CostString( math.min(cost, funds) ), cost > funds and ("(and %s extra)"):format(CostString( cost - funds )) or ""))
				else
					self:Print( string.format("Autorepaired for %s.", CostString( cost )) )
				end
			else
				self:Print( string.format("Autorepaired for %s.", CostString( cost )) )
			end
			if guildRepair then
				RepairAllItems(guildRepair)
			end
			RepairAllItems()
		end
	end

	-- Sell Junk ( from tekJunkSeller )
	for bag=0,4 do
		for slot=0,GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link and select(3, GetItemInfo(link)) == 0 then
				ShowMerchantSellCursor(1)
				UseContainerItem(bag, slot)
			end
		end
	end
end

local function ToggleTargetTracking(mode)
	local count = GetNumTrackingTypes()
	for id = 1, count do
		local name = GetTrackingInfo(id)
		if name == "Target" then
			SetTracking(id, mode)
			return
		end
	end
end

function NevMod:UpdateTracking()
	local classificiation = UnitClassification("target")
	if classificiation and (classificiation == "rare" or classificiation == "rareelite") then
		ToggleTargetTracking(true)
	else
		ToggleTargetTracking(false)
	end
end
