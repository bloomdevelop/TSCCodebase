local Object = script.Parent

local Effects = script:GetChildren()
for i,effect in pairs(Effects) do
	effect.Parent = Object
end

local SplashDamage = 80
local Radius = 60
local GrenadeArmorFactor = 50

function OnExplosionHit(Character, hitDistance, blastCenter)
	local Humanoid = Character:FindFirstChild("Humanoid")
	if hitDistance and blastCenter then
		local DistanceFactor = hitDistance/Radius
		DistanceFactor = 1-DistanceFactor
		if Humanoid then
			if Humanoid.Health > 0 then
				if  Humanoid.Parent:FindFirstChild("Saude")~= nil then
					if  Humanoid.Parent.Saude.Protecao.HelmetVida.Value > 0 and Humanoid.Parent.Saude.Protecao.VestVida.Value > 0 then

						if GrenadeArmorFactor <= (Humanoid.Parent.Saude.Protecao.VestBlastProtect.Value + Humanoid.Parent.Saude.Protecao.HelmetBlastProtect.Value) then

							local VestMult = ((100 - GrenadeArmorFactor)/(Humanoid.Parent.Saude.Protecao.VestBlastProtect.Value))
							local HelmMult = ((100 - GrenadeArmorFactor)/(Humanoid.Parent.Saude.Protecao.HelmetBlastProtect.Value))

							if VestMult > 1 then
								VestMult = 1
							elseif VestMult < 0 then
								VestMult = 0
							end

							if HelmMult > 1 then
								HelmMult = 1
							elseif HelmMult < 0 then
								HelmMult = 0
							end

							local HitDamage = (DistanceFactor*SplashDamage) * (GrenadeArmorFactor/(Humanoid.Parent.Saude.Protecao.VestBlastProtect.Value + Humanoid.Parent.Saude.Protecao.HelmetBlastProtect.Value))
							local VestDamage = ((DistanceFactor*SplashDamage) * VestMult)
							local HelmDamage = ((DistanceFactor*SplashDamage) * HelmMult)
							--print("Colete + Helm: " ..HitDamage)
							if VestDamage <= 0 then
								VestDamage = 1
							end
							if HelmDamage <= 0 then
								HelmDamage = 1
							end
							if HitDamage <= 0 then
								HitDamage = 1
							end
							Humanoid.Parent.Saude.Protecao.HelmetVida.Value = Humanoid.Parent.Saude.Protecao.HelmetVida.Value - HelmDamage
							Humanoid.Parent.Saude.Protecao.VestVida.Value = Humanoid.Parent.Saude.Protecao.VestVida.Value - VestDamage
							Humanoid:TakeDamage(HitDamage)
						else
							local HitDamage = DistanceFactor*SplashDamage
							--print(HitDamage)
							Humanoid:TakeDamage(HitDamage)
						end

					elseif Humanoid.Parent.Saude.Protecao.HelmetVida.Value > 0 and Humanoid.Parent.Saude.Protecao.VestVida.Value <= 0 then
						if GrenadeArmorFactor <= (Humanoid.Parent.Saude.Protecao.HelmetBlastProtect.Value) then

							local HelmMult = ((100 - GrenadeArmorFactor)/(Humanoid.Parent.Saude.Protecao.HelmetBlastProtect.Value))						

							if HelmMult > 1 then
								HelmMult = 1
							elseif HelmMult < 0 then
								HelmMult = 0
							end

							local HitDamage = (DistanceFactor*SplashDamage) * (GrenadeArmorFactor/(Humanoid.Parent.Saude.Protecao.VestBlastProtect.Value + Humanoid.Parent.Saude.Protecao.HelmetBlastProtect.Value))
							local HelmDamage = ((DistanceFactor*SplashDamage) * HelmMult)

							--print("Helm: " ..HitDamage)

							if HelmDamage <= 0 then
								HelmDamage = 1
							end
							if HitDamage <= 0 then
								HitDamage = 1
							end

							Humanoid.Parent.Saude.Protecao.HelmetVida.Value = Humanoid.Parent.Saude.Protecao.HelmetVida.Value - HelmDamage
							Humanoid:TakeDamage(HitDamage)
						else
							local HitDamage = DistanceFactor*SplashDamage
							--print(HitDamage)
							Humanoid:TakeDamage(HitDamage)
						end

					elseif Humanoid.Parent.Saude.Protecao.HelmetVida.Value <= 0 and Humanoid.Parent.Saude.Protecao.VestVida.Value > 0 then
						if GrenadeArmorFactor <= (Humanoid.Parent.Saude.Protecao.VestBlastProtect.Value) then

							local VestMult = ((100 - GrenadeArmorFactor)/(Humanoid.Parent.Saude.Protecao.VestBlastProtect.Value))

							if VestMult > 1 then
								VestMult = 1
							elseif VestMult < 0 then
								VestMult = 0
							end


							local HitDamage = (DistanceFactor*SplashDamage) * (GrenadeArmorFactor/(Humanoid.Parent.Saude.Protecao.VestBlastProtect.Value + Humanoid.Parent.Saude.Protecao.HelmetBlastProtect.Value))
							local VestDamage = ((DistanceFactor*SplashDamage) * VestMult)

							--print("Colete: " ..HitDamage)
							if VestDamage <= 0 then
								VestDamage = 1
							end
							if HitDamage <= 0 then
								HitDamage = 1
							end
							Humanoid.Parent.Saude.Protecao.VestVida.Value = Humanoid.Parent.Saude.Protecao.VestVida.Value - VestDamage
							Humanoid:TakeDamage(HitDamage)
						else
							local HitDamage = DistanceFactor*SplashDamage
							--print(HitDamage)
							Humanoid:TakeDamage(HitDamage)
						end

					elseif Humanoid.Parent.Saude.Protecao.HelmetVida.Value <= 0 and Humanoid.Parent.Saude.Protecao.VestVida.Value <= 0 then
						local HitDamage = DistanceFactor*SplashDamage
						--print(HitDamage)
						Humanoid:TakeDamage(HitDamage)
					end
				else
					local HitDamage = DistanceFactor*SplashDamage
					--print(HitDamage)
					Humanoid:TakeDamage(HitDamage)
				end
			end
		end
	end
end

function Explode()
	local Orange = Color3.fromRGB(255, 193, 105)
	local Gray = Color3.fromRGB(193, 178, 172)
	Object.Explosion.LightEmission = 1
	Object.Explosion.LightInfluence = 0
	Object.Explosion.Color = ColorSequence.new(Orange,Orange)
	local Light = Instance.new("PointLight")
	Light.Color = Color3.fromRGB(255, 233, 187)
	Light.Brightness = 1
	Light.Range = 15
	Light.Shadows = true
	Light.Parent = Object
	local Explosion = Instance.new("Explosion")
	Explosion.BlastRadius = Radius*.875
	Explosion.BlastPressure = 0
	Explosion.Position = Object.Position
	Explosion.Parent = Object
	Explosion.Visible = false
	Explosion.Hit:Connect(function(hit, distance)
		if hit.Name == "HumanoidRootPart" and hit.Parent:FindFirstChild("Humanoid") then
			OnExplosionHit(hit.Parent, distance, Object.Position)
		end
	end)
	local Children = Object:GetChildren()
	for i=1,#Children do
		if Children[i]:IsA("ParticleEmitter") then
			Children[i].Enabled = false
		end
	end
	wait(.05)
	Object.Explosion.LightEmission = 0
	Object.Explosion.LightInfluence = 1
	Object.Explosion.Color = ColorSequence.new(Gray,Gray)
	Light:Destroy()
end

--helpfully checks a table for a specific value
function contains(t, v)
	for _, val in pairs(t) do
		if val == v then
			return true
		end
	end
	return false
end
--use this to determine if you want this human to be harmed or not, returns boolean

function boom()
	Object.Explode:Play()
	Object.Explosion:Emit(100)
	Object.Smoke1:Emit(150)
	Object.Smoke2:Emit(50)
	Object.Smoke3:Emit(50)
	Object.Debris:Emit(200)
	Object.Debris2:Emit(900)
	Object.Debris3:Emit(900)	
	for i,v in pairs(Effects) do
		game.Debris:AddItem(v, 10)
	end
	Explode()
end

boom()
script:Destroy()