local PS = game:GetService('Players')
local TS = game:GetService('TextService')
local functionId = "EditText"

local preset = {
	"UwU",
	"OwO",
	"rawr~",
	"hewwo",
	"hewe owo!",
	"i am fwuffy",
	">w<",
	"teehee owo"
}

--function remove(msg: string, filter: string)
--	local f = ""
--	local t = msg.len()
--	for i=t, 1, -1 do
--		print(msg.unpack())
--	end
--end

local function doFilter(speaker, message, channelName)
	local msg = string.lower(message.Message)
	if msg == "ez"
		or msg == 'ez.'
		or msg == '.ez'
		or string.find(msg," ez")
		or string.find(msg,"ez ")
		or string.find(msg," ez ")
	then
		message.Message = preset[math.random(1,6)]
	end
	
	--if
	--	(string.find(msg, "isb") and string.find(msg, "cis")) or
	--	(string.find(msg, "hot") and string.find(msg, "cis"))
	--then
		
	--	message.Message = string.gsub(message.Message, "hot", "[ REDACTED ]")
	--	message.Message = string.gsub(message.Message, "isb", "[ REDACTED ]")
	--	message.Message = string.gsub(message.Message, "cis", "[ REDACTED ]")
	--end
	
	--for filter, on in next, customFilter do
	--	if not on then
	--		return
	--	end
	--	if string.find(message.Message:lower(), filter) then
	--		string.gsub(message.Message:lower(), filter, "[ REDACTED ]")
	--	end
	--end
	
	--if string.find(message.Message:lower(), "isb") then
	--	string.gsub(message.Message:lower(), "isb", "[ REDACTED ]")
	--end
	
	if speaker and PS[speaker] and PS[speaker]:GetAttribute("UwUSpeach") == true then
		message.Message = string.gsub(message.Message,"r","w")
		message.Message = string.gsub(message.Message,"R","W")
		message.Message = string.gsub(message.Message,"l","w")
		message.Message = string.gsub(message.Message,"L","W")
		message.Message = string.gsub(message.Message,"m","mw")
		message.Message = string.gsub(message.Message,"M","mW")
		message.Message = string.gsub(message.Message,"v","vw")
		message.Message = string.gsub(message.Message,"V","VW")
		message.Message = string.gsub(message.Message,"p","pw")
		message.Message = string.gsub(message.Message,"P","PW")
		message = TS:FilterStringAsync(message.Message,PS[speaker].UserId,Enum.TextFilterContext.PublicChat)
	end
	
	if speaker and PS[speaker] and PS[speaker]:GetAttribute("TrollSpeach") == true then
		message.Message = string.gsub(message.Message,"r",":troll:")
		message.Message = string.gsub(message.Message,"R","trolololo")
		message.Message = string.gsub(message.Message,"l","troll")
		message.Message = string.gsub(message.Message,"L","trolled")
		message.Message = string.gsub(message.Message,"E","you've been trolled")
		message.Message = message.Message .. ":troll:"
		message = TS:FilterStringAsync(message.Message,PS[speaker].UserId,Enum.TextFilterContext.PublicChat)
	end
end

local function runChatModule(ChatService)
	ChatService:RegisterFilterMessageFunction(functionId, doFilter)
end

return runChatModule