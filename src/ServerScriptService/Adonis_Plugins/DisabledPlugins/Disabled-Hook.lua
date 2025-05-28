
return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service
	
	local AdonisHook = game:GetService("ServerScriptService"):WaitForChild("Hayper's Scripts"):WaitForChild("AdonisHook")
	local GetService = script:WaitForChild("GetService")
	local GetServer = script:WaitForChild("GetServer")
	
	GetService.OnInvoke = function()
		return service
	end
	
	GetServer.OnInvoke = function()
		return server
	end
	
	GetService.Parent = AdonisHook
	GetServer.Parent = AdonisHook
end