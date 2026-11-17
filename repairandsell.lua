-- automatically repair and sell junk when visiting a vendor
local RepairAndSell = LibStub("AceAddon-3.0"):GetAddon("NevMod"):NewModule("RepairAndSell", "AceEvent-3.0", "AceConsole-3.0")

function RepairAndSell:OnEnable()
	self:RegisterEvent("MERCHANT_SHOW")
end

function RepairAndSell:MERCHANT_SHOW()
	self:Repair()
	self:SellJunk()
end

function RepairAndSell:Repair()
	if not CanMerchantRepair() then
		return
	end

	local cost, canRepair = GetRepairAllCost()
	if not canRepair or cost <= 0 then
		return
	end

	-- guild funds first, as far as they are available
	local guildFunds = 0
	if CanGuildBankRepair() then
		guildFunds = GetGuildBankMoney()
		local withdrawLimit = GetGuildBankWithdrawMoney()
		if withdrawLimit ~= -1 then
			guildFunds = math.min(guildFunds, withdrawLimit)
		end
		guildFunds = math.min(guildFunds, cost)
	end

	local ownCost = cost - guildFunds
	local money = GetMoney()
	if money < ownCost then
		self:Print(("Autorepair failed, you need %s more."):format(GetMoneyString(ownCost - money)))
		return
	end

	if guildFunds > 0 then
		RepairAllItems(true)
	end
	if ownCost > 0 then
		RepairAllItems()
	end
	PlaySound(SOUNDKIT.ITEM_REPAIR)

	if guildFunds <= 0 then
		self:Print(("Autorepaired for %s."):format(GetMoneyString(cost)))
	elseif ownCost > 0 then
		self:Print(("Autorepaired for %s using guild funds (and %s extra)."):format(GetMoneyString(guildFunds), GetMoneyString(ownCost)))
	else
		self:Print(("Autorepaired for %s using guild funds."):format(GetMoneyString(guildFunds)))
	end
end

function RepairAndSell:SellJunk()
	if not C_MerchantFrame.IsSellAllJunkEnabled() then
		return
	end

	local numJunk = C_MerchantFrame.GetNumJunkItems()
	if numJunk > 0 then
		C_MerchantFrame.SellAllJunkItems()
		self:Print(("Sold %d junk |4item:items;."):format(numJunk))
	end
end
