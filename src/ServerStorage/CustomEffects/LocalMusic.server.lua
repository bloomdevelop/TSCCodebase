local players = game:GetService('Players')
local debris = game:GetService('Debris')

local player = players:GetPlayerFromCharacter(script.Parent)
local character = script.Parent
local humanoid = character:WaitForChild('Humanoid')

local sounds = {
	922468419,
	435810894,
	172837202
}

if player.PlayerGui:FindFirstChild('HeadMusic') then player.PlayerGui.HeadMusic:Destroy() end
local sound = Instance.new('Sound')
sound.SoundId = 'rbxassetid://'..sounds[math.random(1, #sounds)]
sound.Volume = 1
sound.Name = 'HeadMusic'
sound.Parent = player.PlayerGui
sound:Play()

function cleanup()
	sound:Destroy()
	sound = nil
	script:Destroy()
end

humanoid.Died:Connect(cleanup)
sound.Ended:Connect(cleanup)