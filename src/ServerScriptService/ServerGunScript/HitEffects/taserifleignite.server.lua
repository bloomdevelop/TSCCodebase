local Humanoid = script.Parent:FindFirstChild("Humanoid")
local Head = script.Parent:FindFirstChild("Head")
local Fires = {}
local FireDamagePerSecond = 2

function wait(TimeToWait)
	if TimeToWait ~= nil then
		local TotalTime = 0
		TotalTime = TotalTime + game:GetService("RunService").Heartbeat:wait()
		while TotalTime < TimeToWait do
			TotalTime = TotalTime + game:GetService("RunService").Heartbeat:wait()
		end
	else
		game:GetService("RunService").Heartbeat:wait()
	end
end

if Humanoid and Head then
	BurnSound = Instance.new("Sound")
	BurnSound.Name = "BurnSound"
	BurnSound.SoundId = "http://www.roblox.com/asset/?id=277635663"
	BurnSound.Parent = Head
	BurnSound.Volume = 0.5
	game.Debris:AddItem(BurnSound,10)
	BurnSound:Play()
	for _,parts in pairs(script.Parent:GetChildren()) do
		if parts.className == "Part" or parts.className == "WedgePart" or parts.className == "CornerWedgePart" or parts.className == "MeshPart" then

			local C = script.FireEffect:GetChildren()
			for i=1,#C do
				if C[i].className == "ParticleEmitter" then
					local Particle = C[i]:Clone()
					table.insert(Fires,Particle)
					Particle.Parent = parts
					delay(0.01,function()
						Particle.Enabled = true
					end)
				end
			end		

		end
	end
	while script.Duration.Value > 0 do
		wait(0.1)
		script.Duration.Value = script.Duration.Value - 0.1
		while Humanoid:FindFirstChild("creator") do
			Humanoid.creator:Destroy()
		end
		local Tag = script.creator:clone()
		Tag.Parent = Humanoid
		game.Debris:AddItem(Tag,5)
		Humanoid:TakeDamage(FireDamagePerSecond*0.1)
	end
	for _, Fire in pairs(Fires) do
		Fire.Enabled = false
	end
	wait(0.2)
	for _, Fire in pairs(Fires) do
		Fire:Destroy()
	end
end
wait()
script:Destroy()
