local players = game:GetService('Players')
local debris = game:GetService('Debris')
local runService = game:GetService('RunService')

local player = players:GetPlayerFromCharacter(script.Parent)
local character = script.Parent
local humanoid = character:WaitForChild('Humanoid')

local forceUnequip = script:WaitForChild('ForceUnequip')

local ended = false
local WSCache = Instance.new('NumberValue', character)
WSCache.Value = humanoid.WalkSpeed
WSCache.Name = 'WalkSpeedCache'
local JPCache = Instance.new('NumberValue', character)
JPCache.Value = humanoid.JumpPower
JPCache.Name = 'JumpPowerCache'

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

humanoid.Died:Connect(function() script:Destroy() end)

runService.Heartbeat:Connect(function()
	if not ended then
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		humanoid.PlatformStand = true
	else
		humanoid.WalkSpeed = WSCache.Value
		humanoid.JumpPower = JPCache.Value
		humanoid.PlatformStand = false
	end
end)

ended = false
humanoid.WalkSpeed = 0
humanoid.JumpPower = 0
humanoid.PlatformStand = true
local unequip = forceUnequip:Clone()
unequip.Parent = character
unequip.Disabled = false
wait(35)
ended = true
humanoid.WalkSpeed = WSCache.Value
humanoid.JumpPower = JPCache.Value
humanoid.PlatformStand = false
unequip:Destroy()
script:Destroy()