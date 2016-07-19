-- debug "not in raid group" spam

local SendAddonMessage_o = SendAddonMessage
SendAddonMessage = function(prefix, text, distr, ...)
	if distr == "RAID" and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		geterrorhandler()(debugstack())
	end
	return SendAddonMessage_o(prefix, text, distr, ...)
end
