local NevMod = LibStub("AceAddon-3.0"):NewAddon("NevMod", "AceEvent-3.0", "AceConsole-3.0")

local lgist = LibStub("LibGroupInSpecT-1.1", true)
if lgist then
	lgist.debug = false
end

function NevMod:OnInitialize()
	self:FixBuffPositions()

	-- hide the orderhall commandbar
	hooksecurefunc("OrderHall_LoadUI",
		function()
			if OrderHallCommandBar then
				OrderHallCommandBar:SetScript("OnShow", nil)
				OrderHallCommandBar:SetScript("OnHide", nil)
				OrderHallCommandBar:UnregisterAllEvents()
			end
		end)
	hooksecurefunc("OrderHall_CheckCommandBar", function() if OrderHallCommandBar then OrderHallCommandBar:Hide() end end)
end

function NevMod:FixBuffPositions()
	BuffFrame:ClearAllPoints()
	BuffFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -45, -30)
	BuffFrame.SetPoint = function() end
	BuffFrame:SetFrameStrata("MEDIUM")
end

function NevMod:OnEnable()
	self:RegisterEvent("MERCHANT_SHOW", "RepairAndSell")
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "UpdateTracking")
	ConsoleExec("cameraDistanceMaxFactor 4")

	MiniMapInstanceDifficulty:ClearAllPoints()
	MiniMapInstanceDifficulty:SetPoint("BOTTOMRIGHT", Minimap, "TOPRIGHT", 8, 10)
	GuildInstanceDifficulty:ClearAllPoints()
	GuildInstanceDifficulty:SetPoint("BOTTOMRIGHT", Minimap, "TOPRIGHT", 8, 10)
	MiniMapChallengeMode:ClearAllPoints()
	MiniMapChallengeMode:SetPoint("BOTTOMRIGHT", Minimap, "TOPRIGHT", 8, 10)

	for i=1,4 do
		_G["GroupLootFrame"..i]:SetScale(1.2)
	end

	AUCTIONATOR_V_TIPS = 0
	AUCTIONATOR_A_TIPS = 0
	AUCTIONATOR_D_TIPS = 0
end

local HBD = LibStub("HereBeDragons-1.0", true)
if HBD then
	local f = CreateFrame("Frame")
	local elapsed_total = 0

	function checkInstanceId()
		local x,y,instance = HBD:GetPlayerWorldPosition()
		local zone = HBD:GetPlayerZone()
		if HBD.mapData[zone] and HBD.mapData[zone].instance ~= instance and zone ~= -1 then
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

--[[
local SendAddonMessage_o = SendAddonMessage
SendAddonMessage = function(prefix, text, distr, ...)
	if distr == "RAID" and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		geterrorhandler()(debugstack())
	end
	return SendAddonMessage_o(prefix, text, distr, ...)
end
--]]
