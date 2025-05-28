local players = game:GetService('Players')

local player = players:GetPlayerFromCharacter(script.Parent)
local character = script.Parent
local humanoid = character:WaitForChild('Humanoid')

local comaServer = script:WaitForChild('Coma_Server')
local comaClient = script:WaitForChild('Coma_Client')

if math.random() <= 0.05 then
	local server = comaServer:Clone()
	server.Parent = character
	server.Disabled = false
	local client = comaClient:Clone()
	client.Parent = character
	client.Disabled = false
end
script:Destroy()