-- filter annoying chat messages

local filters = {
	CHAT_MSG_MONSTER_YELL = {
		"^Victory in Tol Barad is ours!",
	},
}

local function chatFilter(self, event, msg, ...)
	if filters[event] then
		for i, text in pairs(filters[event]) do
			if msg:find(text) then
				return true
			end
		end
	end
	return false, msg, ...
end

for event in pairs(filters) do
	ChatFrame_AddMessageEventFilter(event, chatFilter)
end
