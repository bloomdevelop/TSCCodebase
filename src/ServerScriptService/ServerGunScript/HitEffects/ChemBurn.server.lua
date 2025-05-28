local Humanoid = script.Parent:FindFirstChild("Humanoid")
local Head = script.Parent:FindFirstChild("Head")
local Player = game.Players:GetPlayerFromCharacter(script.Parent)
local Fires = {}
local FireDamagePerSecond = 0.1
local infectedCheckModule = require(game:GetService("ReplicatedStorage").InfectedCheckModule)

if Player then
	if infectedCheckModule(Player) then
		FireDamagePerSecond *= 50
	end
end

if Humanoid and Head then
	BurnSound = Instance.new("Sound")
	BurnSound.Name = "BurnSound"
	BurnSound.SoundId = "http://www.roblox.com/asset/?id=4086192869"
	BurnSound.Parent = Head
	BurnSound.Volume = 1
	game.Debris:AddItem(BurnSound,10)
	task.delay(0,function()
		BurnSound:Play()
	end)
	for _,parts in pairs(script.Parent:GetChildren()) do
		if parts.className == "Part" or parts.className == "WedgePart" or parts.className == "CornerWedgePart" or parts.className == "MeshPart" then

			local C = script.FireEffect:GetChildren()
			for i=1,#C do
				if C[i].className == "ParticleEmitter" then
					local Particle = C[i]:Clone()
					table.insert(Fires,Particle)
					Particle.Parent = parts
					task.delay(0.01,function()
						Particle.Enabled = true
					end)
				end
			end		

		end
	end
	while script.Duration.Value > 0 do
		task.wait(0.1)
		script.Duration.Value = script.Duration.Value - 0.1
		while Humanoid:FindFirstChild("creator") do
			Humanoid.creator:Destroy()
		end
		local Tag = script.creator:clone()
		Tag.Parent = Humanoid
		game.Debris:AddItem(Tag,5)
		Humanoid:TakeDamage(FireDamagePerSecond)
		if not infectedCheckModule(Player) then
			local LatexValues = Humanoid.Parent:FindFirstChild("LatexValues") or Humanoid.Parent:WaitForChild("LatexValues")
			if LatexValues.InfectionLevel.Value > 0 then
				LatexValues.InfectionLevel.Value = 0
			end
			LatexValues = nil
		end
	end
	for _, Fire in pairs(Fires) do
		Fire.Enabled = false
	end
	for _, Fire in pairs(Fires) do
		Fire:Destroy()
	end
end
task.wait()
script:Destroy()
