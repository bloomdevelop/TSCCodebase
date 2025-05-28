--[[
	
	shut up shut up shut up shut up shut up shut up shut up shut up shut up shut up shut up shut up shut up shut up 
	
	i know its bad
	
	shut up shut up shut up shut up shut up shut up shut up shut up shut up shut up shut up shut up shut up shut up 
	
--]]

-- player
local player = game:GetService('Players').LocalPlayer
local character = player.Character or player.CharacterAdded:wait()
local mouse = player:GetMouse()

-- remotes
local cuffsEvent = game:GetService('ReplicatedStorage'):WaitForChild('CuffsEvent')

-- variables
local lastCuff = nil
local animation = nil
local animId = (game.PlaceId == 4525999910) and 4823735476 or 4823775841
local characters = {}
local connections = {}

script:WaitForChild('Animation').AnimationId = ('rbxassetid://' .. animId)

local function SetupCuffs(character)
	character.ChildAdded:connect(function(object)
		if (object.Name == 'Cuffs') then
			connections[#connections + 1] = game:GetService('UserInputService').InputBegan:connect(function(input)
				local focused = game:GetService('UserInputService'):GetFocusedTextBox()
				
				if (input.KeyCode == Enum.KeyCode.F) and not focused and lastCuff then
					cuffsEvent:FireServer('ToggleCuffAnimation', lastCuff)
				end
			end)
			
			connections[#connections + 1] = object.Activated:connect(function()
				local target = mouse.Target
				local isPlayer = false
				local isNPC = false
				
				if target and not lastCuff then
					for _, p in next, game:GetService('Players'):GetPlayers() do
						if p.Character and target:IsDescendantOf(p.Character) and not game:GetService("CollectionService"):HasTag(p.Character,"CustomCharacter") then
							lastCuff = p.Character
						end
					end
					
					if lastCuff then
						isPlayer = true
						
						cuffsEvent:FireServer('Cuff', lastCuff)
					end
				end
				
				if not isPlayer and not isNPC then
					lastCuff = nil

					cuffsEvent:FireServer('Uncuff')	
				end
			end)
				
			object.AncestryChanged:connect(function(_, parent)
				if (parent ~= character) then
					for _, connection in next, connections do
						connection:Disconnect()
					end
				end
			end)
		end
	end)
end

cuffsEvent.OnClientEvent:connect(function(arg, ...)
	local args = {...}
	local control = require(player.PlayerScripts.PlayerModule.ControlModule)
	local character = player.Character
	local humanoid = character:WaitForChild('Humanoid')
		
	if (arg:lower() == 'togglecuffanimation') then
		local bool = args[1]

		if bool and not animation then
			humanoid:UnequipTools()
			
			game:GetService('StarterGui'):SetCore('ResetButtonCallback', false)
			
			player.PlayerGui.Backpack.Enabled = false
			
			animation = humanoid:LoadAnimation(script:WaitForChild('Animation'))
			animation:Play()
		elseif not bool and animation then
			game:GetService('StarterGui'):SetCore('ResetButtonCallback', true)
			player.PlayerGui.Backpack.Enabled = false
			
			if animation then
				animation:Stop()
				animation = nil
			end
		end
	end
	
	if (arg:lower() == 'cuffed') then
		local oldUI = player.PlayerGui:FindFirstChild('CuffedUI')
		
		if oldUI then
			oldUI:Destroy()
		end
		
		local newUI = script:WaitForChild('CuffedUI'):Clone()
		newUI.Header.Text = 'You are being detained by ' .. args[1]
		newUI.Parent = player.PlayerGui
		
		control:Disable()
	elseif (arg:lower() == 'uncuffed') then
		local oldUI = player.PlayerGui:FindFirstChild('CuffedUI')

		if oldUI then
			oldUI:Destroy()
		end
		
		control:Enable()
	end
	
	if (arg:lower() == 'cuffing') then
		local target = args[1]
		local text = args[2]
		local size = args[3]
		local oldUI = player.PlayerGui:FindFirstChild('CuffedUI')
		
		if oldUI then
			oldUI:Destroy()
		end
		
		local newUI = script:WaitForChild('CuffedUI'):Clone()
		newUI.Header.Size = UDim2.new(1, 0, size, 0)
		newUI.Header.Text = text
		newUI.Parent = player.PlayerGui
	elseif (arg:lower() == 'uncuffing') then
		local oldUI = player.PlayerGui:FindFirstChild('CuffedUI')
		
		if oldUI then
			oldUI:Destroy()
		end
	end
end)

SetupCuffs(player.Character)
player.CharacterAdded:connect(SetupCuffs)