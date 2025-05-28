local replicatedStorage = game:GetService('ReplicatedStorage')
local serverStorage = game:GetService('ServerStorage')
local collectionService = game:GetService('CollectionService')
local debris = game:GetService('Debris')
local runService = game:GetService('RunService')
local plrService = game:GetService("Players")

local scp = workspace:FindFirstChild('SCP-294', true)

assert(scp, 'Could not find SCP-294 in Workspace!')
assert(scp:FindFirstChild('Body') and scp:FindFirstChild('Cup'), 'Got a different SCP-294 model in Workspace! Try renaming the other SCP-294 model.')

local body = scp:WaitForChild('Body')
local pad = scp:WaitForChild('Pad')
local cup = scp:WaitForChild('Cup')
local usePrompt = body:WaitForChild('UseAttachment'):WaitForChild('ProximityPrompt')
local cupPrompt = body:WaitForChild('CupAttachment'):WaitForChild('ProximityPrompt')

local drinks = serverStorage:WaitForChild('Drinks')
local customEffects = serverStorage:WaitForChild('CustomEffects')
local cupTool = serverStorage.Tools:WaitForChild('Cup of ')
local nuke = serverStorage:WaitForChild('Atom')
local dispenseDrink = replicatedStorage:WaitForChild('DispenseDrink')
local resetter = scp:WaitForChild('Resetter')

local maxUses = scp:GetAttribute('MaxUses')
local allowedEffects = {
	['PointLight'] = true,
	['SpotLight'] = true,
	['SurfaceLight'] = true,
	['Fire'] = true,
	['Smoke'] = true,
	['Sparkles'] = true,
	['Beam'] = true,
	['Trail'] = true,
	['ParticleEmitter'] = true,
}

local tool
local timesUsed = scp:WaitForChild('TimesUsed')
local user = scp:WaitForChild('User')
local dispensing = scp:WaitForChild('Dispensing')

--Capitalize all drink module names so SCP-294 can dispense the drink
for _, drink in pairs(drinks:GetChildren()) do
	if drink:IsA('ModuleScript') then drink.Name = string.upper(drink.Name) end
end

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

function hasProperty(instance, property)
	local temp = instance:Clone()
	temp:ClearAllChildren()
	return (pcall(function()
		return temp[property]
	end))
end

cupPrompt.Triggered:Connect(function(player)
	if tool and tool:IsA('Tool') then
		local humanoid = player.Character:FindFirstChildOfClass('Humanoid')
		if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
			timesUsed.Value = timesUsed.Value + math.clamp(1, 0, maxUses)
			user.Value = ''
			tool.Parent = player.Backpack
			tool = nil
			cup.Handle.Transparency = 1
			cup.Liquid.Transparency = 1
			cup.Liquid:ClearAllChildren()
			cupPrompt.Enabled = false
			resetter:Fire()
		end
	end
end)

dispenseDrink.OnServerInvoke = function(player, drink: string)
	local function setDrinkAppearance(part, module)
		part.BrickColor = module.Color
		part.Material = module.Material
		part.Transparency = module.Transparency
		part.Reflectance = module.Reflectance
		for _, effect in pairs(module.Effects) do
			if allowedEffects[effect.Type] then
				local e = Instance.new(effect.Type)
				for property, value in pairs(effect.Properties) do
					if hasProperty(e, property) then
						e[property] = value
					else
						warn(property..' is not a property of '..e:GetFullName())
					end
				end
				e.Parent = part
				e.Enabled = true
			else
				warn('Attempted to create invalid effect ('..effect.Type..')')
			end
		end
	end

	local function playSound(sound: string)
		if not body:FindFirstChild(sound) then
			warn('Could not find dispense sound '..sound..' in SCP-294.Body!')
			sound = 'Dispense1'
		end
		body[sound]:Play()
		wait(body[sound].TimeLength)
	end

	local result
	local gui = player.PlayerGui:FindFirstChild('SCP294Gui')
	if gui and not dispensing.Value then
		local currentDrink
		local CupOfName = nil
		if string.find(drink, "CUP OF ") then
			local name = drink:split("CUP OF ")
			for _,v in pairs(plrService:GetPlayers()) do
				local plrName = string.upper(v.Name)
				if name[2] == plrName then
					CupOfName = v.Name
				end
			end
		end
		if CupOfName == nil then
			currentDrink = drinks:FindFirstChild(drink)
		elseif CupOfName ~= nil then
			currentDrink = drinks:FindFirstChild("%CUPOFPLAYER")
		end
		if currentDrink and currentDrink:IsA('ModuleScript') then
			dispensing.Value = true
			result = 'Dispensing'
			local drinkSettings
			if not currentDrink:FindFirstChild('Randomizer') then
				drinkSettings = require(currentDrink)
			else
				if currentDrink.Randomizer:IsA('ModuleScript') then
					local randomizer = require(currentDrink.Randomizer)
					local drinkName = string.upper(randomizer.DrinkList[math.random(#randomizer.DrinkList)])
					local selectedDrink = drinks:FindFirstChild(drinkName)
					if selectedDrink and selectedDrink:IsA('ModuleScript') then
						drinkSettings = require(selectedDrink)
					else
						warn('Could not find '..drinkName..' in Drinks!')
						drinkSettings = require(currentDrink)
					end
				else
					warn(currentDrink.Randomizer:GetFullName()..' is not a ModuleScript.')
					drinkSettings = require(currentDrink)
				end
			end
			local dispenseMessage = typeof(drinkSettings.DispenseMessage) == 'string' and string.upper(drinkSettings.DispenseMessage) or 'DISPENSING...'
			if gui then gui.Panel.Pad.Text = dispenseMessage end
			pad.SurfaceGui.Input.Text = dispenseMessage
			usePrompt.Enabled = false
			if CupOfName ~= nil and plrService[CupOfName] then
				local char = plrService[CupOfName].Character
				if char then
					local blur = customEffects.CupOfPlayer.Blur:Clone()
					local hurt = customEffects.CupOfPlayer.Hurt:Clone()
					blur.Parent = char
					blur.Disabled = false
					hurt.Parent = char
					hurt.Disabled = false
				end
			end
			playSound(drinkSettings.DispenseSound)
			user.Value = ''
			dispensing.Value = false
			pad.SurfaceGui.Input.Text = ''

			--Set the player's WalkSpeed and JumpPower back to their original values
			if player and player.Character then
				local humanoid = player.Character:FindFirstChildOfClass('Humanoid')
				if humanoid then
					humanoid.WalkSpeed = gui:FindFirstChild('WalkSpeedCache') and gui.WalkSpeedCache.Value or 16
					humanoid.JumpPower = gui:FindFirstChild('JumpPowerCache') and gui.JumpPowerCache.Value or 50
				end
			end

			--Set up the drink
			if not drinkSettings.Explosion then
				--Set up the tool
				local name = drinkSettings.Name ~= 'Empty Cup' and cupTool.Name..drinkSettings.Name or 'Empty Cup'
				tool = cupTool:Clone()
				if CupOfName ~= nil then
					tool.Name = "Cup of " .. CupOfName
				elseif CupOfName == nil then
					tool.Name = name
				end
				tool.Parent = serverStorage
				cup.Handle.Transparency = 0
				cupPrompt.Enabled = true
				local setting = require(tool.Settings)

				--Set the drink's appearance
				if name ~= 'Empty Cup' then
					setDrinkAppearance(tool.Liquid, drinkSettings)
					setDrinkAppearance(cup.Liquid, drinkSettings)
				else
					tool.Liquid:Destroy()
					cup.Liquid.Transparency = 1
					cup.Liquid:ClearAllChildren()
				end

				--Set the drink messages
				setting.Message = drinkSettings.Message
				setting.RefuseMessage = drinkSettings.RefuseMessage

				--Create the drink sound
				local id = drinkSettings.DrinkSound
				if typeof(drinkSettings.DrinkSound) ~= 'number' or not drinkSettings.DrinkSound then id = 2752128299 end
				local sound = Instance.new('Sound')
				sound.SoundId = 'rbxassetid://'..id
				sound.RollOffMaxDistance = 100
				sound.Parent = tool.MainScript

				--Set the drink's effects
				setting.Heal = drinkSettings.Heal
				setting.Bleedout = drinkSettings.Bleedout
				setting.Lethal = drinkSettings.Lethal
				setting.Blur = drinkSettings.Blur
				if typeof(drinkSettings.CustomEffect.Script) == 'string' and drinkSettings.CustomEffect.Script ~= '' then
					local customEffect = customEffects:FindFirstChild(drinkSettings.CustomEffect.Script)
					if customEffect then
						if customEffect:IsA('Script') then
							local effect = customEffect:Clone()
							if drinkSettings.CustomEffect.EnableOnDrink then
								effect.Parent = tool.MainScript
								effect.Disabled = true
							else
								effect.Parent = tool
								effect.Disabled = false
							end
							tool.CustomEffect.Value = effect
						else
							warn(drinkSettings.CustomEffect.Script..' is not a Script!')
						end
					else
						warn(drinkSettings.CustomEffect.Script..' is not in CustomEffects!')
					end
				end
			else
				timesUsed.Value = timesUsed.Value + math.clamp(1, 0, maxUses)
				local atom = nuke:Clone()
				atom.Pos.Value = cup.Handle.Position
				atom.Parent = workspace
				atom.Disabled = false
			end

			--Destroy the GUI
			if gui then debris:AddItem(gui, 0.05) end
		else
			result = 'OutOfRange'
			if gui then gui.Panel.Pad.Text = 'OUT OF RANGE' end
			pad.SurfaceGui.Input.Text = 'OUT OF RANGE'
			body.OutOfRange:Play()
			body.OutOfRange.Ended:wait()
			resetter:Fire()
			if gui then gui.Panel.Pad.Text = '' end
			pad.SurfaceGui.Input.Text = ''
		end
	end
	return result
end