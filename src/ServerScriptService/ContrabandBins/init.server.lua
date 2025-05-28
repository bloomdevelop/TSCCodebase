local sst = game:GetService("ServerStorage")
local rst = game:GetService("ReplicatedStorage")
local cs = game:GetService("CollectionService")

local remotesFolder = rst.Remotes

local modulesFolder = sst.Modules

local confiscateTool = require(modulesFolder.ConfiscateTool)
local getSellPrice = require(modulesFolder.GetSellPrice)

local binStorageLimit = 20
local binStorages = {}

local cannotBeStored = {
	["Cuffs"] = true,
	["Cloaker Kick"] = true,
	["Lock Picking"] = true,
	["Remote Control"] = true,
	["TASER"] = true,
	["Stunstuck"] = true,
	["Wand"] = true,
	["Contraband Bag"] = true,
	["Package"] = true
}

local function hasTool(plr, toolName)
	if plr.Backpack:FindFirstChild(toolName) then return true end

	if plr.Character then
		local heldTool = plr.Character:FindFirstChildOfClass("Tool")
		if heldTool and heldTool.Name == toolName then
			return true
		end
	end

	return false
end

local function addToolToBin(bin, plr, tool)
	if cannotBeStored[tool.Name] then return end
	
	local primaryPart = bin.PrimaryPart
	local prompt = primaryPart.BinProximityPrompt

	local toolsInBin = #binStorages[bin]

	if toolsInBin < binStorageLimit then
		local success, refundedCash = confiscateTool(plr, tool, 0.7)

		if success then
			bin.PrimaryPart.DisposeSound:Play()
			if refundedCash > 0 then
				bin.PrimaryPart.RefundSound:Play()
				if tool:FindFirstChild("RefundableTag") then
					tool.RefundableTag:Destroy()
				end
			end
			
			tool.Parent = nil
			table.insert(binStorages[bin], tool)
			
			--[[
			if not cannotBeStored[tool.Name] then
				---- Can be stored
				tool.Parent = nil
				table.insert(binStorages[bin], tool)
			else
				---- Cannot be stored
				tool:Destroy()
			end
			]]

			local toolsInBin = #binStorages[bin]
			if toolsInBin >= binStorageLimit then
				bin.Light.Color = Color3.new(0.75, 0, 0)

				prompt.ObjectText = "Contraband Bin (Full)"
				prompt.ActionText = "Open"
			elseif toolsInBin >= binStorageLimit/2 then
				bin.Light.Color = Color3.new(0.75, 0.75, 0)
			else
				bin.Light.Color = Color3.new(0, 0.75, 0)
			end
		end
	end
end

local function emptyBin(bin, plr)
	local primaryPart = bin.PrimaryPart
	local prompt = primaryPart.BinProximityPrompt

	local binStorage = binStorages[bin]

	local bag = script["Contraband Bag"]:Clone()

	for i,tool in pairs(binStorage) do
		local pointer = Instance.new("ObjectValue")
		pointer.Value = tool
		pointer.Name = tool.Name

		pointer.Parent = bag.Stored
	end

	binStorages[bin] = {}

	prompt.ObjectText = "Contraband Bin"
	prompt.ActionText = "Dispose"

	bag.Parent = plr.Backpack

	bin.Light.Color = Color3.new(0, 0.75, 0)
end

local bins = cs:GetTagged("ContrabandBinInteractable")

for i,bin in pairs(bins) do
	local primaryPart = bin.PrimaryPart

	local prompt = Instance.new("ProximityPrompt")
	prompt.MaxActivationDistance = 10
	prompt.ObjectText = "Contraband Bin"
	prompt.ActionText = "Dispose"
	prompt.RequiresLineOfSight = false
	prompt.Name = "BinProximityPrompt"
	prompt.HoldDuration = 1
	prompt.Style = Enum.ProximityPromptStyle.Custom
	
	prompt.Parent = primaryPart

	local disposeSound = script.DisposeSound:Clone()
	local refundSound = script.RefundSound:Clone()
	local openingSound = script.OpeningSound:Clone()
	local openSound = script.OpenSound:Clone()

	local openProgressUI = script.OpenProgress:Clone()

	local plrOpening = nil

	binStorages[bin] = {}

	disposeSound.Parent = primaryPart
	refundSound.Parent = primaryPart
	openSound.Parent = primaryPart
	openingSound.Parent = primaryPart
	openProgressUI.Parent = primaryPart

	prompt.PromptButtonHoldBegan:Connect(function(plr)
		local binStorage = binStorages[bin]

		if #binStorage == binStorageLimit then
			if hasTool(plr, "Contraband Bin Key") and plrOpening ~= nil then
				local char = plr.Character
				local hum = char:FindFirstChildOfClass("Humanoid")

				if hum and hum.Health > 0 then
					local hitPlr = plrOpening
					local hitChar = plrOpening.Character

					local hitHum = hitChar:FindFirstChildOfClass("Humanoid")
					if hitHum then
						local root = char:FindFirstChild("HumanoidRootPart")
						local hitRoot = hitChar:FindFirstChild("HumanoidRootPart")

						if root and hitRoot then
							plrOpening = nil

							-- get outta the way
							local kickAnimation = script.InterruptKickAnimation:Clone()
							local hitAnimation = script.InterruptHitAnimation:Clone()

							local kickSound = script.KickSound:Clone()

							kickAnimation.Parent = char
							hitAnimation.Parent = hitChar

							kickSound.Parent = root

							local kickAnimationTrack = hum.Animator:LoadAnimation(kickAnimation)
							local hitAnimationTrack = hitHum.Animator:LoadAnimation(hitAnimation)

							root.CFrame = CFrame.lookAt(root.Position, Vector3.new(hitRoot.Position.X, root.Position.Y, hitRoot.Position.Z))
							----------

							local hitRootPos = root.Position + root.CFrame.LookVector*4
							local direction = (hitRootPos - root.Position)

							local raycastParams = RaycastParams.new()
							raycastParams.FilterDescendantsInstances = {char, hitChar}

							local raycastResult = workspace:Raycast(root.Position, direction, raycastParams)
							if raycastResult then
								hitRootPos = raycastResult.Position
							end

							hitRoot.CFrame = CFrame.lookAt(hitRootPos, root.Position)

							----------

							kickAnimationTrack:Play()
							hitAnimationTrack:Play(0)

							game.Debris:AddItem(kickAnimationTrack, 5)
							game.Debris:AddItem(hitAnimationTrack, 5)

							game.Debris:AddItem(kickAnimation, 6)
							game.Debris:AddItem(hitAnimation, 6)

							game.Debris:AddItem(kickSound, 5)

							task.wait(0.15)

							kickSound:Play()
						end
					end
				end

			end
		end
	end)

	prompt.Triggered:Connect(function(plr)
		local char = plr.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				local root = char:FindFirstChild("HumanoidRootPart")

				if root then
					local binStorage = binStorages[bin]

					if #binStorage < binStorageLimit then
						---- Add tool to bin
						local heldTool = char:FindFirstChildOfClass("Tool")
						if heldTool then
							local sellPrice = getSellPrice(heldTool)

							if sellPrice > 0 then
								addToolToBin(bin, plr, heldTool)
							else
								-- Ask the player if they're sure they want to discard an item for no credits
								remotesFolder.ToolDisposal.ConfirmDisposal:FireClient(plr, bin, heldTool)
							end
						end
					else
						---- Empty bin
						if hasTool(plr, "Contraband Bin Key") then
							openSound:Play()
							emptyBin(bin, plr)
						elseif hasTool(plr, "Crowbar") and plrOpening == nil then
							plrOpening = plr

							local anim = script.OpenAnimation:Clone()
							anim.Parent = char
							local track = hum.Animator:LoadAnimation(anim)
							track:Play()

							openingSound:Play()

							openProgressUI.Enabled = true

							local initialPosition = root.Position

							local timeLeft = 60
							while timeLeft > 0 do
								if hum.Health == 0 or (root.Position - initialPosition).Magnitude > 3 or char.Parent == nil or plrOpening == nil then
									break
								end

								openProgressUI.Bar.Fill.Size = UDim2.new(1-(timeLeft/60), 0, 1, 0)

								timeLeft = timeLeft - task.wait(.1)
							end

							---- Stop opening
							openProgressUI.Enabled = false

							track:Stop()
							track:Destroy()
							anim:Destroy()

							openingSound:Stop()

							if timeLeft <= 0 then
								openSound:Play()
								emptyBin(bin, plr)
							end

							plrOpening = nil
						end
					end
				end
			end
		end
	end)
end

remotesFolder.ToolDisposal.ConfirmDisposal.OnServerEvent:Connect(function(plr, bin, tool)
	if not tool then return end
	if not bin then return end

	local char = plr.Character
	if not char then return end

	if tool.Parent == char or tool.Parent == plr.Backpack then
		addToolToBin(bin, plr, tool)
	end
end)