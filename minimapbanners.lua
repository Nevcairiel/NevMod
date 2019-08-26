-- move minimap banners
if not MiniMapInstanceDifficulty then return end
MiniMapInstanceDifficulty:ClearAllPoints()
MiniMapInstanceDifficulty:SetPoint("BOTTOMRIGHT", Minimap, "TOPRIGHT", 8, 10)
GuildInstanceDifficulty:ClearAllPoints()
GuildInstanceDifficulty:SetPoint("BOTTOMRIGHT", Minimap, "TOPRIGHT", 8, 10)
MiniMapChallengeMode:ClearAllPoints()
MiniMapChallengeMode:SetPoint("BOTTOMRIGHT", Minimap, "TOPRIGHT", 8, 10)