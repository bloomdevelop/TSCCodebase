local players = game:GetService('Players')
local runService = game:GetService('RunService')

local player = players.LocalPlayer
local character = player.Character
local humanoid = character:WaitForChild('Humanoid')

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

while humanoid:GetState() ~= Enum.HumanoidStateType.Dead and not character:FindFirstChild('SCP-198') do
	humanoid:UnequipTools()
	wait()
end