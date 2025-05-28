local players = game:GetService('Players')
local runService = game:GetService('RunService')

local player = players:GetPlayerFromCharacter(script.Parent)
local character = script.Parent
local humanoid = character:WaitForChild('Humanoid')

local gui = script:WaitForChild('ComaGui')

local function wait(waitTime: number)
	local deltaTime = 0

	if waitTime and waitTime > 0 then
		while deltaTime < waitTime do
			deltaTime = deltaTime + runService.Heartbeat:wait()
		end
	else
		deltaTime = deltaTime + runService.Heartbeat:wait()
	end
	return deltaTime
end

humanoid.Died:Connect(function()
	if player and player.PlayerGui:FindFirstChild(gui.Name) then player.PlayerGui.ComaGui:Destroy() end
	script:Destroy()
end)

if player then gui:Clone().Parent = player.PlayerGui end
wait(math.random(20, 60))
if player and player.PlayerGui:FindFirstChild(gui.Name) then player.PlayerGui.ComaGui:Destroy() end
humanoid:TakeDamage(math.huge)
script:Destroy()