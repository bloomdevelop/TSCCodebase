local players = game:GetService('Players')
local tweenService = game:GetService('TweenService')
local debris = game:GetService('Debris')
local runService = game:GetService('RunService')

local player = players.LocalPlayer
local character = player.Character
local humanoid = character:WaitForChild('Humanoid')
local camera = workspace.CurrentCamera

local info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local blur = Instance.new('BlurEffect')
blur.Size = 0
blur.Parent = camera

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
	tweenService:Create(blur, info, {Size = 0}):Play()
	debris:AddItem(blur, 0.5)
end)

tweenService:Create(blur, info, {Size = 12}):Play()
wait(10)
tweenService:Create(blur, info, {Size = 0}):Play()
debris:AddItem(blur, 0.5)
script:Destroy()