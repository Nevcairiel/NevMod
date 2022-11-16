-- automatically repair and sell trash when visiting a vendor
local RepairAndSell = LibStub("AceAddon-3.0"):GetAddon("NevMod"):NewModule("RepairAndSell", "AceEvent-3.0", "AceConsole-3.0")

local GetContainerNumSlots = C_Container and C_Container.GetContainerNumSlots or GetContainerNumSlots
local GetContainerItemLink = C_Container and C_Container.GetContainerItemLink or GetContainerItemLink
local UseContainerItem = C_Container and C_Container.UseContainerItem or UseContainerItem

function RepairAndSell:OnEnable()
	self:RegisterEvent("MERCHANT_SHOW", "RepairAndSell")
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

function RepairAndSell:RepairAndSell()
	-- Repair Equipment
	if CanMerchantRepair() then
		local cost = GetRepairAllCost()
		local money = GetMoney()
		if money < cost then
			self:Print( string.format("Autorepair failed, you need %s more.", CostString( cost - money )) )
		elseif cost > 0 then
			local guildRepair = CanGuildBankRepair and CanGuildBankRepair()
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
				if ShowMerchantSellCursor then
					ShowMerchantSellCursor(1)
				else
					SetCursor("BUY_CURSOR")
				end
				UseContainerItem(bag, slot)
			end
		end
	end
	ResetCursor()
end
