if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then return end

-- Time delay
local tDelay = 0

-- Fast loot function
local function FastLoot()
    if GetTime() - tDelay >= 0.3 then
        tDelay = GetTime()
        if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
            for i = GetNumLootItems(), 1, -1 do
                LootSlot(i)
            end
            tDelay = GetTime()
        end
    end
end

-- event frame
local faster = CreateFrame("Frame")
faster:RegisterEvent("LOOT_READY")
faster:SetScript("OnEvent", FastLoot)
