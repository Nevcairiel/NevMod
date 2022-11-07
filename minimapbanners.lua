-- move minimap banners
if MiniMapInstanceDifficulty then
	MiniMapInstanceDifficulty:ClearAllPoints()
	MiniMapInstanceDifficulty:SetPoint("BOTTOMRIGHT", Minimap, "TOPRIGHT", 8, 10)
end
if GuildInstanceDifficulty then
	GuildInstanceDifficulty:ClearAllPoints()
	GuildInstanceDifficulty:SetPoint("BOTTOMRIGHT", Minimap, "TOPRIGHT", 8, 10)
end
if MiniMapChallengeMode then
	MiniMapChallengeMode:ClearAllPoints()
	MiniMapChallengeMode:SetPoint("BOTTOMRIGHT", Minimap, "TOPRIGHT", 8, 10)
end
