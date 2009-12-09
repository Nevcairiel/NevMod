local NevMod = LibStub("AceAddon-3.0"):NewAddon("NevMod", "AceEvent-3.0", "AceConsole-3.0")

function NevMod:OnInitialize()
	self:FixBuffPositions()
end

function NevMod:FixBuffPositions()
	ConsolidatedBuffs:ClearAllPoints()
	ConsolidatedBuffs:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -20, -30)
	ConsolidatedBuffs.SetPoint = function() end
end

function NevMod:OnEnable()
	self:RegisterEvent( "MERCHANT_SHOW", "RepairAndSell" )
	ConsoleExec("cameraDistanceMaxFactor 4")
end

-- From SmoothDurability
local function CostString( cost )
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
				self:Print( string.format("Autorepaired for %s using guild funds %s.", CostString( math.min(cost, funds) ), cost > funds and ("(and %s extra)"):format(CostString( cost - funds )) or ""))
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
