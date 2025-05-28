local SSS = game:GetService("ServerScriptService")
local module = require(SSS.RopesScriptFolder.SignModule)

local remote = script.Parent:WaitForChild("Remote")
local tool = script.Parent
local decal = tool.Model.Board:WaitForChild("Decal")

remote.OnServerEvent:Connect(function(plr,ID)
	module.Request(ID,decal)
end)