local requests = {}

local module = {}

module.Request = function(name,id,msg)
	local date = os.date('%x')
	local Ctime = os.date('%X')
	table.insert(requests,{game.Workspace:GetAttribute("guid"),date,Ctime,name..'/'..id,msg})
end

module.Return = function()
	local v = requests
	requests = {}
	return v
end

return module
