local requests = {}


local module = {}

module.Request = function(request)
	local CTime = os.date('!*t')
	table.insert(requests,'['..CTime['hour']..':'..CTime['min']..':'..CTime['sec']..']'..' : '..request..'\n')
end

module.Return = function()
	local str = ""
	for v = 1, #requests do
		if string.len(str) <= 1990 then
			str = str .. requests[1]
			table.remove(requests,1)
		else
			break
		end
	end
	return str
end

return module
