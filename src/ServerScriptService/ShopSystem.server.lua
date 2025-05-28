-- // Steven_Scripts, 2022

local sst = game:GetService("ServerStorage")
local rst = game:GetService("ReplicatedStorage")

local toolsFolder
local remotesFolder

local modulesFolder
local shopInfoModule
local toolInfoModule
local teamAlignments

local toolDisplaysFolder = rst.ToolDisplays

local function getPrice(toolName, shopName, buyer)
	local toolInfo = toolInfoModule[toolName]
	local shopInfo = shopInfoModule[shopName]

	if toolInfo then
		local price = toolInfo.Price
		
		local priceMarkups = shopInfo.PriceMarkups
		if priceMarkups then
			local markup = priceMarkups[toolName]
			if markup then
				price = math.round(price*markup)
			end
		end
		
		if shopInfo.Alignment ~= nil and (teamAlignments[buyer.Team.Name] ~= shopInfo.Alignment) then
			-- Not welcome
			price = price*3
		end
		
		return price
	else
		return nil
	end
end

function amountOfToolInInventory(player: Player, name: string)
	local inventory = player.Backpack:GetChildren()
	local char = player.Character
	if char then
		local equippedTool = char:FindFirstChildOfClass("Tool")
		if equippedTool then
			table.insert(inventory, equippedTool)
		end
	end

	local count = 0
	for i,tool in pairs(inventory) do
		if tool.Name == name then
			count = count+1
		end
	end

	return count
end

local function onPurchaseToolRequest(plr, toolName, shop)
	if typeof(shop) == "Instance" and shop:IsA("Model") and typeof(toolName) == "string" then
		local shopInfo = shopInfoModule[shop.Name]
		if shopInfo then
			local toolInfo = toolInfoModule[toolName]
			if toolInfo then
				if table.find(shopInfo.Tools, toolName) ~= nil then
					local char = plr.Character
					if char then
						local root = char:FindFirstChild("HumanoidRootPart")
						if root then
							local hum = char:FindFirstChildOfClass("Humanoid")
							if hum and hum.Health > 0 then
								local primaryPart = shop.PrimaryPart
								local distance = (primaryPart.Position - root.Position).Magnitude
								if distance < 15 then
									local stackLimit = toolInfo.Stacklimit

									if amountOfToolInInventory(plr, toolName) >= stackLimit then
										return false, "You already have this item"
									end
									local price = getPrice(toolName, shop.Name, plr)
									local cash = plr.leaderstats.Cash
									if cash.Value >= price then
										cash.Value = cash.Value - price

										local tool = toolsFolder[toolName]:Clone()

										local refundableTag = Instance.new("BoolValue")
										refundableTag.Name = "RefundableTag"
										refundableTag.Parent = tool

										tool.Parent = plr.Backpack

										return true
									else
										return false, "Can't afford"
									end
								else
									return false, "Too far from shop"
								end
							else
								return false, "Humanoid missing"
							end
						else
							return false, "Root part missing"
						end
					else
						return false, "Character missing"
					end
				else
					return false, "Item does not exist in shop"
				end
			else
				return false, "Tool does not exist"
			end
		else
			return false, "Shop does not exist"
		end
	else
		return false, "Invalid arguments"
	end
end

local function cleanPart(part)
	for i,v in pairs(part:GetChildren()) do
		-- Make sure we don't leave any unwanted stuff behind.
		if not v:IsA("SpecialMesh") then
			v:Destroy()
		end
	end
end

local function weldParts(part0, part1)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = part0
	weld.Part1 = part1
	weld.Parent = part0
end

local function addToToolDisplay(part, model)
	part = part:Clone()
	cleanPart(part)

	local handle = model.Handle

	part.Parent = model
	weldParts(handle, part)

	part.Anchored = true
	part.CanQuery = true
end

local function createToolDisplay(tool)
	local handle = tool:FindFirstChild("Handle")
	if handle then
		local model = Instance.new("Model")
		model.Name = tool.Name

		handle = handle:Clone()
		handle.Parent = model

		model.PrimaryPart = handle

		--local averagePosition = handle.Position
		--local positionsFound = 1
		for i,v in pairs(tool:GetDescendants()) do
			if v:IsA("BasePart") and v.Name ~= "Handle" then
				addToToolDisplay(v, model)
				--positionsFound = positionsFound+1
				--averagePosition = averagePosition+v.Position
			end
		end
		--averagePosition = averagePosition/positionsFound

		--local centerOffset = (handle.Position - averagePosition)

		cleanPart(handle)

		local faceUpOrientation = tool:GetAttribute("FaceUpOrientation")
		if faceUpOrientation == nil then
			-- We'll just assume it's the way it was placed in storage.
			faceUpOrientation = handle.Orientation
		end

		model:SetAttribute("FaceUpOrientation", faceUpOrientation)

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
		raycastParams.FilterDescendantsInstances = {model}

		local upDirection = Vector3.new(0, 50, 0)

		model.Parent = workspace

		local bottomResult = workspace:Raycast(handle.Position-upDirection, upDirection, raycastParams)
		local bottomPosition = bottomResult and bottomResult.Position or handle.Position-Vector3.new(0, 1.5, 0)
		local yHeight = (bottomPosition - handle.Position).Magnitude

		local offset = Vector3.new(0, yHeight, 0)

		model:SetAttribute("Offset", offset)

		model.Parent = toolDisplaysFolder
	end
end

toolsFolder = sst:WaitForChild("Tools")
modulesFolder = rst:WaitForChild("Modules")
remotesFolder = rst:WaitForChild("Remotes")
toolInfoModule = require(modulesFolder:WaitForChild("ToolInfo"))
shopInfoModule = require(modulesFolder:WaitForChild("ShopInfo"))
teamAlignments = require(modulesFolder:WaitForChild("TeamAlignments"))

for i,tool in pairs(toolsFolder:GetChildren()) do
	if tool:IsA("Tool") then
		createToolDisplay(tool)
	end
end

toolsFolder.ChildAdded:Connect(function(tool)
	if tool:IsA("Tool") then
		createToolDisplay(tool)
	end
end)

remotesFolder.Shop.Purchase.OnServerInvoke = onPurchaseToolRequest