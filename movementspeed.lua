-- add the movement speed to the character stat sheet

function PaperDollFrame_SetMovementSpeed(statFrame, unit)
	statFrame.wasSwimming = nil
	statFrame.unit = unit
	MovementSpeed_OnUpdate(statFrame)

	statFrame.onEnterFunc = MovementSpeed_OnEnter
	statFrame:SetScript("OnUpdate", MovementSpeed_OnUpdate)
	statFrame:Show()
end

CharacterStatsPane.statsFramePool.resetterFunc =
	function(pool, frame)
		frame:SetScript("OnUpdate", nil)
		FramePool_HideAndClearAnchors(pool, frame)
	end
table.insert(PAPERDOLL_STATCATEGORIES[1].stats, { stat = "MOVESPEED"})