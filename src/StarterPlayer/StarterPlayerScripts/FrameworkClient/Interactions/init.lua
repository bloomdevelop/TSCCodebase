--[[
	
	TODO:
	 - redo doors to use this system
	 - redo levers to use this system
	 - redo buttons to use this system
	 - integrate this system with radios, bean bags, ect
	 - integrate with tools
	 
 ----------------------------------------------------
 
 	Alright, lets get this straight:
 		Nodes are given three types of attributes; CheckType, MaxDistance, and Clearances.
 		
 		CheckType allows for us to use multiple types of logical gates instead of one, because that'd be boring.
 		Types:
 		
 			0 - Character HumanoidRootPart distance based (door-based interaction like)
 			1 - Mouse position distance based (click detector like)
 		
 		MaxDistance is the type of distance we want to be below, in order to interact with the interactable.
 		This MUST be a number, or integer-parsable string
 		
 		Clearances is either string or number based, but it parses to a string where it can be split by ",", and then checked over.
 		It shoves into clearances module and either gets a true or false, which tells whether it'll be sent to the server.
 		If the attribute doesn't exist, it will continue on as true.
 		
 	Hopefully this explains, don't use too many nodes, and make sure to set them appropriately.
	
]]

function Lerp(a, b, t)
	return a + (b - a) * t
end


local Typing = require(game:GetService('ReplicatedStorage').Typing)

return function(Framework: Typing.FrameworkType)
	local Interactions = {
		Cache = {}
	}
	Interactions.__index = Interactions
	
	local CurrentNode: BasePart? = nil
	
	-- INTERACTABLE REGISTRATION
	
	Framework.Services.Workspace.Map.Interactables.DescendantAdded:Connect(function(child: Instance)
		-- either in the interact model or the nodes folder of interact model, and is named "Node"
		if child.Name == "Node" and (child.Parent:GetAttribute('InteractType') or child.Parent.Parent:GetAttribute('InteractType')) then
			table.insert(Interactions.Cache, child)
			child.AncestryChanged:Connect(function(_, parent)
				if parent == nil then
					table.remove(Interactions.Cache, table.find(Interactions.Cache, child))
				end
			end)
		end
	end)
	
	-- INTERACTION CONNECTIONS
	
	local MinDist: number = 100 -- max distance
	local SelectingNode: boolean = false
	
	local safetyConn: RBXScriptConnection?; safetyConn = Framework.Services.RunService.RenderStepped:Connect(function(dt)
		-- PRESETS
		MinDist = 100 -- change this if you want longer distance, idk LOL
		-- VISUALS
		if CurrentNode then
			Framework.Interface.Interaction:UpdatePos(CurrentNode.Position, 0.25)
			if SelectingNode then
				for _, i: ImageLabel in next, Framework.Interface.Interaction.UI.Select:GetChildren() do
					i.Position = i.Position:Lerp(i:GetAttribute('OnState'), 0.25)
					i.ImageTransparency = Lerp(i.ImageTransparency, 0.2, 0.25)
				end
			else
				Framework.Interface.Interaction.UI.Select.Rotation = (Framework.Interface.Interaction.UI.Select.Rotation + 0.2)
				for _, i: ImageLabel in next, Framework.Interface.Interaction.UI.Select:GetChildren() do
					i.Position = i.Position:Lerp(i:GetAttribute('HoverState'), 0.25)
					i.ImageTransparency = Lerp(i.ImageTransparency, 0.5, 0.25)
				end
			end
		else
			Framework.Interface.Interaction.UI.Select.Rotation = (Framework.Interface.Interaction.UI.Select.Rotation + .1)
			Framework.Interface.Interaction:UpdatePos(nil, 0.25)
			for _, i: ImageLabel in next, Framework.Interface.Interaction.UI.Select:GetChildren() do
				i.Position = i.Position:Lerp(i:GetAttribute('OffState'), 0.25)
				i.ImageTransparency = Lerp(i.ImageTransparency, 1, 0.25)
			end
		end
		-- POS VARS
		local MousePos: Vector3 = (Framework.Playerstates.Mouse.Hit.Position :: Vector3);
		local HumanoidPos: Vector3 = Framework.Playerstates.Values.RootPos;
		-- CURRENT NODE LOGIC
		if CurrentNode then
			-- MOUSE DISTANCE LOGIC
			if CurrentNode:GetAttribute('CheckType') == 1 then
				if (HumanoidPos - MousePos).Magnitude > 5 then
					CurrentNode = nil
				end
			end
			-- NODE DISTANCE CHECK
			local lol = ((CurrentNode:GetAttribute('CheckType') == 0) and (CurrentNode.Position - HumanoidPos).Magnitude) or -- ROOT DISTANCE
				((CurrentNode:GetAttribute('CheckType') == 1) and (CurrentNode.Position - MousePos).Magnitude) or -- MOUSE DISTANCE
				100
			if lol > CurrentNode:GetAttribute('MaxDistance') then
				CurrentNode = nil
			end
		end
		-- UPDATE CURRENT NODE VARIABLE
		for _, node: BasePart in next, Interactions.Cache do
			local lol = ((node:GetAttribute('CheckType') == 0) and (node.Position - HumanoidPos).Magnitude) or -- ROOT DISTANCE
				((node:GetAttribute('CheckType') == 1) and (node.Position - MousePos).Magnitude) or -- MOUSE DISTANCE
				100
			-- MOUSE DISTANCE LOGIC PART 2
			if CurrentNode then
				if CurrentNode:GetAttribute('CheckType') == 1 then
					if (HumanoidPos - MousePos).Magnitude > 5 then
						return
					end
				end
			end
			-- DISTANCE LOGIC
			if lol < MinDist and lol < node:GetAttribute('MaxDistance') then
				MinDist = lol -- new node
				CurrentNode = node
			end
		end
		-- UPDATE CURRENT NODE VISUALS
		if CurrentNode then
			local f = Framework("I_" .. (CurrentNode.Parent:GetAttribute('InteractType') or CurrentNode.Parent.Parent:GetAttribute('InteractType')), true)
			if f then
				Framework.Interface.Interaction:ShowInteraction(f.InteractTitle)
			else
				-- well you screwed up lol...
				warn('INVALID STRUCTURE WITH NODE:', CurrentNode)
				warn('STOPPING INTERACTION RENDER CONNECTION...')
				safetyConn:Disconnect()
			end
		else
			Framework.Interface.Interaction:HideInteraction()
		end
	end)

	local smootht = TweenInfo.new(.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	local fastt = TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	local blinkr = { ImageColor3 = Color3.fromRGB(255, 30, 30) }
	local blinkg = { ImageColor3 = Color3.fromRGB(39, 255, 46) }
	local blinkw = { ImageColor3 = Color3.fromRGB(255, 255, 255) }
	local widel = { Size = UDim2.new(0, 48, 0, 48) }
	local widem = { Size = UDim2.new(0, 32, 0, 32) }
	local wides = { Size = UDim2.new(0, 16, 0, 16) }
	
	Framework.Keybinds:AddInput("interact", Enum.KeyCode.T, function()
		if CurrentNode then
			task.spawn(function()
				SelectingNode = true
				Framework.Services.TweenService:Create(Framework.Interface.Interaction.UI.Select, smootht, {
					Rotation = Framework.Interface.Interaction.UI.Select.Rotation + 360
				}):Play()
				task.wait(0.2)
				SelectingNode = false
			end)
			local worked, alert = Framework.Network:Fetch('interact', CurrentNode)
			if worked then
				for _, i: ImageLabel in next, Framework.Interface.Interaction.UI.Select:GetChildren() do
					task.spawn(function()
						Framework.Services.TweenService:Create(i, fastt, blinkg):Play()
						task.wait(0.1)
						Framework.Services.TweenService:Create(i, smootht, blinkw):Play()
					end)
				end
			else
				task.spawn(function()
					Framework.Services.TweenService:Create(Framework.Interface.Interaction.UI.Select, fastt, widel):Play()
					task.wait(0.1)
					Framework.Services.TweenService:Create(Framework.Interface.Interaction.UI.Select, smootht, widem):Play()
				end)
				for _, i: ImageLabel in next, Framework.Interface.Interaction.UI.Select:GetChildren() do
					task.spawn(function()
						Framework.Services.TweenService:Create(i, fastt, blinkr):Play()
						task.wait(0.1)
						Framework.Services.TweenService:Create(i, smootht, blinkw):Play()
					end)
				end
			end
			if alert then
				Framework.Interface.Interaction:ShowAlert(alert)
			end
		end
	end, nil, true)
	
	return Interactions
end