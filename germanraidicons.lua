-- replace german raid icons by the universal {rtX} token
local raidIcons = {
	["%{[sS][tT][eE][rR][nN]%}"] = "{rt1}",
	["%{[kK][rR][eE][iI][sS]%}"] = "{rt2}",
	["%{[dD][iI][aA][mM][aA][nN][tT]%}"] = "{rt3}",
	["%{[dD][rR][eE][iI][eE][cC][kK]%}"] = "{rt4}",
	["%{[mM][oO][nN][dD]%}"] = "{rt5}",
	["%{[qQ][uU][aA][dD][rR][aA][tT]%}"] = "{rt6}",
	["%{[kK][rR][eE][uU][zZ]%}"] = "{rt7}",
	-- \195\132 Ä, \195\164 ä
	["%{[tT][oO][tT][eE][nN][sS][cC][hH]\195[\132\164][dD][eE][lL]%}"] = "{rt8}",
}

-- raid icons
local function filter(self, event, msg, ...)
	if msg then
		for k, v in pairs(raidIcons) do
			msg = msg:gsub(k, v)
		end
	end
	return false, msg, ...
end
for _,event in pairs{"SAY", "YELL", "GUILD", "GUILD_OFFICER", "WHISPER", "WHISPER_INFORM", "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "BATTLEGROUND", "BATTLEGROUND_LEADER", "CHANNEL"} do
	ChatFrame_AddMessageEventFilter("CHAT_MSG_"..event, filter)
end
