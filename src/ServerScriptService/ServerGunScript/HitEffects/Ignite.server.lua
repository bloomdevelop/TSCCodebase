local Humanoid = script.Parent:FindFirstChild("Humanoid")
local Head = script.Parent:FindFirstChild("Head")
local Player = game.Players:GetPlayerFromCharacter(script.Parent)
local Fires = {}
local FireDamagePerSecond = 5
local infectedCheckModule = require(game:GetService("ReplicatedStorage").InfectedCheckModule)

if Player then
	if infectedCheckModule(Player) then
		FireDamagePerSecond *= 2
	end
end

if Humanoid and Head and Player then
	BurnSound = Instance.new("Sound",Head)
	BurnSound.Name = "BurnSound"
	BurnSound.SoundId = "http://www.roblox.com/asset/?id=32791565"
	BurnSound.Volume = 1
	game.Debris:AddItem(BurnSound,10)
	delay(0,function()
		BurnSound:Play()
	end)
	for _,parts in pairs(script.Parent:GetChildren()) do
		if parts.className == "Part" or parts.className == "WedgePart" or parts.className == "CornerWedgePart" or parts.className == "MeshPart" then
			local C = script.FireEffect:GetChildren()
			for i = 1,#C do
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
		local LatexValues = Humanoid.Parent:FindFirstChild("LatexValues")
		local LatexType = LatexValues and LatexValues:FindFirstChild("LatexType")
		local Immune = false
		if (LatexType) then
			if LatexType.Value == "FireFox" then
				Immune = true
			end
		end
		if not Immune then
			Humanoid:TakeDamage((FireDamagePerSecond*0.1))
		end
	end
	for _, Fire in pairs(Fires) do
		Fire.Enabled = false
	end
	for _, Fire in pairs(Fires) do
		Fire:Destroy()
	end
end
wait()
script:Destroy()
