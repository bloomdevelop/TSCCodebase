-- // Steven_Scripts, 2022

local sst = game:GetService("ServerStorage")
local rst = game:GetService("ReplicatedStorage")
local tws = game:GetService("TweenService")
local uis = game:GetService("UserInputService")

local assetsFolder
local remotesFolder

local leaderstats
local modulesFolder
local shopInfoModule
local toolInfoModule
local teamAlignments

local toolDisplaysFolder

local cash

local plr = game.Players.LocalPlayer

local ui = script.Parent
local main = ui.Main

local info = main.Info
local header = main.Header
local list = main.List

local currentShop = nil
local selectedItemEntryIndex = nil

local armRig = nil

local transitionCooldown = false

local itemEntries = {}

local function easeViewportToolDisplay(viewport, startOffset, goalOffset, easingStyle, easingDirection, toolDisplay)
	easingStyle = easingStyle or Enum.EasingStyle.Sine

	if toolDisplay == nil then
		toolDisplay = viewport:FindFirstChild("ToolDisplay")
	end

	if toolDisplay then
		local centerCF = toolDisplay.CenterCF.Value

		if toolDisplay:FindFirstChild("CancelTween") then
			toolDisplay.CancelTween:Fire()
		end

		local startCF = centerCF+startOffset
		local goalCF = centerCF+goalOffset

		toolDisplay:SetPrimaryPartCFrame(startCF)

		local cancelTweenEvent = Instance.new("BindableEvent")
		cancelTweenEvent.Name = "CancelTween"
		cancelTweenEvent.Parent = viewport

		local cancelled = false
		local connection
		connection = cancelTweenEvent.Event:Connect(function()
			cancelled = true
			cancelTweenEvent:Destroy()
			connection:Disconnect()
		end)

		for i=0,1,.1 do
			task.wait(.0166)
			if cancelled or toolDisplay.PrimaryPart == nil then break end
			toolDisplay:SetPrimaryPartCFrame(startCF:Lerp(goalCF, tws:GetValue(i, Enum.EasingStyle.Quad, easingDirection)))
		end
		if cancelled == false then
			cancelTweenEvent:Destroy()
		end
	end
end

local function clearViewport(viewport, transition)
	local existingToolDisplay = viewport:FindFirstChild("ToolDisplay")
	if existingToolDisplay then
		if transition then
			existingToolDisplay.Name = "OldToolDisplay"
			easeViewportToolDisplay(viewport, Vector3.new(0, 0, 0), Vector3.new(20, 0, 0), Enum.EasingStyle.Sine, Enum.EasingDirection.In, existingToolDisplay)
		end
		existingToolDisplay:Destroy()
	end
end

local function prepareViewport(viewport, fovOverride)
	local fov = fovOverride or 40

	local tabletop = Instance.new("Part")
	tabletop.Name = "Tabletop"
	tabletop.Size = Vector3.new(50, 2, 50)
	tabletop.Anchored = true

	local tabletopDecal = Instance.new("Decal")
	tabletopDecal.Texture = "http://www.roblox.com/asset/?id=9671267073"
	tabletopDecal.Transparency = 0.5
	tabletopDecal.Face = "Top"
	tabletopDecal.Parent = tabletop

	tabletop.Material = Enum.Material.WoodPlanks
	tabletop.Color = Color3.new(0.337255, 0.258824, 0.211765)

	tabletop.Parent = viewport

	local viewportCam = Instance.new("Camera")
	viewportCam.FieldOfView = fov
	viewportCam.CFrame = CFrame.lookAt(Vector3.new(0, 6, 4), tabletop.Position+Vector3.new(0, 1.2, 0))
	viewportCam.Parent = viewport
	viewport.CurrentCamera = viewportCam
end

local function setViewport(viewport, toolName, transition)
	clearViewport(viewport, transition)

	local toolDisplay = toolDisplaysFolder:FindFirstChild(toolName)
	if toolDisplay then
		local tabletop = viewport:FindFirstChild("Tabletop")
		if not tabletop then
			prepareViewport(viewport)
			tabletop = viewport.Tabletop
		end
		local viewportCam = viewport.CurrentCamera

		toolDisplay = toolDisplay:Clone()
		toolDisplay.Name = "ToolDisplay"
		local mainPart = toolDisplay.PrimaryPart
		local faceUpOrientation = toolDisplay:GetAttribute("FaceUpOrientation")
		local offset = toolDisplay:GetAttribute("Offset")

		local centerCF = CFrame.new(offset.X, offset.Y + tabletop.Size.Y/2, offset.Z) * CFrame.Angles(math.rad(faceUpOrientation.X), math.rad(faceUpOrientation.Y), math.rad(faceUpOrientation.Z))
		local centerCFValue = Instance.new("CFrameValue")
		centerCFValue.Value = centerCF
		centerCFValue.Name = "CenterCF"
		centerCFValue.Parent = toolDisplay

		toolDisplay.Parent = viewport

		if transition then
			easeViewportToolDisplay(viewport, Vector3.new(-20, 0, 0), Vector3.new(0, 0, 0), Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		else
			toolDisplay:SetPrimaryPartCFrame(centerCF)
		end
	end
end

local function clearItems()
	for i,info in pairs(itemEntries) do
		info.UI:Destroy()
	end
	itemEntries = {}
end

local function getPrice(toolName)
	local toolInfo = toolInfoModule[toolName]
	local shopInfo = shopInfoModule[currentShop.Name]

	local price = toolInfo.Price
	local priceMarkups = shopInfo.PriceMarkups
	if priceMarkups then
		local markup = priceMarkups[toolName]
		if markup then
			price = math.round(price*markup)
		end
	end
	
	if shopInfo.Alignment ~= nil and (teamAlignments[plr.Team.Name] ~= shopInfo.Alignment) then
		-- Not welcome
		price = price*3
	end

	return price
end

local function isAffordable(itemEntryIndex)
	local entry = itemEntries[itemEntryIndex]

	local cost = getPrice(entry.Name)

	if cash.Value >= cost then
		return true
	else
		return false
	end
end

function amountOfToolInInventory(name: string)
	local inventory = plr.Backpack:GetChildren()
	local char = plr.Character
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

local function updateItemEntry(index)
	local entry = itemEntries[index]

	if isAffordable(index) == true then
		entry.UI.Price.TextColor3 = Color3.new(1, 1, 1)
	else
		entry.UI.Price.TextColor3 = Color3.new(1, 0, 0)
	end
end

local numbersToWords = {
	"one",
	"two",
	"three",
	"four",
	"five",
	"six",
	"seven",
	"eight",
	"nine",
	"ten"
}

local function updateInfo()
	if selectedItemEntryIndex == nil then
		if info.ViewportFrame:FindFirstChild("ToolDisplay") ~= nil then
			clearViewport(info.ViewportFrame)
		end
		info.Purchase.Visible = false
		info.Price.Text = ""
		info.ToolName.Text = ""
		info.Desc.Text = "Click on an item to view more information."
	else
		local itemEntry = itemEntries[selectedItemEntryIndex]
		local toolInfo = toolInfoModule[itemEntry.Name]

		local affordable = isAffordable(selectedItemEntryIndex)
		local canFit

		local stackLimit = toolInfo.Stacklimit

		local count = amountOfToolInInventory(itemEntry.Name)
		if count < stackLimit then
			canFit = true
		else
			canFit = false
		end

		info.Price.Text = "PRICE: "..getPrice(itemEntry.Name).." CREDITS"
		if affordable then
			info.Price.TextColor3 = Color3.fromRGB(255, 226, 0)
			if canFit then
				info.Purchase.Visible = true
				info.CantBuy.Text = ""
			else
				info.Purchase.Visible = false
				info.CantBuy.Text = "<b>You can only hold "..numbersToWords[stackLimit].." of this item at a time.</b>"
			end
		else
			info.Purchase.Visible = false
			info.Price.TextColor3 = Color3.new(1, 0, 0)
			info.CantBuy.Text = "<b>You can't afford this.</b>"
		end

		info.Desc.Text = toolInfo.Description
		info.ToolName.Text = itemEntry.Name

		setViewport(info.ViewportFrame, itemEntry.Name)
	end
end

local function selectItem(indexOrToolName)
	if indexOrToolName == nil then
		selectedItemEntryIndex = nil
		updateInfo()
	else
		local newItemEntry, index
		if typeof(indexOrToolName) == "string" then
			for i,entry in pairs(itemEntries) do
				if entry.Name == indexOrToolName then
					newItemEntry = entry
					index = i
					break
				end
			end

			if newItemEntry == nil then
				warn("Couldn't find item '"..indexOrToolName.."' in shop!")
				return
			end
		else
			index = indexOrToolName
			newItemEntry = itemEntries[index]
		end

		local oldItemEntry
		if selectedItemEntryIndex then
			oldItemEntry = itemEntries[selectedItemEntryIndex]
		end

		if oldItemEntry then
			coroutine.wrap(function()
				easeViewportToolDisplay(oldItemEntry.UI.ViewportFrame, Vector3.new(-20, 0, 0), Vector3.new(0, 0, 0), Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end)()
			coroutine.wrap(function()
				clearViewport(info.ViewportFrame, true)
			end)()
		end

		coroutine.wrap(function()
			easeViewportToolDisplay(newItemEntry.UI.ViewportFrame, Vector3.new(0, 0, 0), Vector3.new(20, 0, 0), Enum.EasingStyle.Sine, Enum.EasingDirection.In)
		end)()

		selectedItemEntryIndex = index
		updateInfo()

		easeViewportToolDisplay(info.ViewportFrame, Vector3.new(-20, 0, 0), Vector3.new(0, 0, 0), Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	end
end

local function createNewItemEntry(toolName)
	local frame = assetsFolder.UI.ShopListEntry:Clone()
	local toolInfo = toolInfoModule[toolName]

	frame.ToolName.Text = toolName

	local price = getPrice(toolName)
	frame.Price.Text = "$"..price

	local index = #itemEntries+1
	itemEntries[index] = {
		["UI"] = frame,
		["Name"] = toolName
	}

	frame.Button.Activated:Connect(function()
		if transitionCooldown == true or selectedItemEntryIndex == index then return end
		transitionCooldown = true
		ui.Slide:Play()
		selectItem(index)
		transitionCooldown = false
	end)

	frame.Parent = list

	setViewport(frame.ViewportFrame, toolName, false)

	updateItemEntry(index)
end

local function closeShop()
	main.Visible = false
	selectItem(nil)
	clearItems()
	currentShop = nil
end

local function loadShop(shopName)
	local currentShopAtLoading = currentShop

	local shopInfo = shopInfoModule[shopName]
	header.ShopName.Text = shopName
	
	if shopInfo.Alignment ~= nil and (teamAlignments[plr.Team.Name] ~= shopInfo.Alignment) then
		header.Quote.Text = shopInfo.UnwelcomeQuote or ""
		main.Unwelcome.Visible = true
	else
		header.Quote.Text = shopInfo.Quote or ""
		main.Unwelcome.Visible = false
	end

	for i,toolName in pairs(shopInfo.Tools) do
		createNewItemEntry(toolName)
	end

	main.Visible = true

	local interrupted = false
	while true do
		task.wait(.2)

		if currentShop ~= currentShopAtLoading then break end

		local char = plr.Character
		if not char then interrupted = true break end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then interrupted = true break end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum then interrupted = true break end
		if hum.Health <= 0 then interrupted = true break end
		local distance = (root.Position - currentShop.PrimaryPart.Position).Magnitude
		if distance > 10 then interrupted = true break end
	end

	if interrupted == true then
		closeShop()
	end
end

local function refreshArmRig()
	local char = plr.Character
	if not char then
		char = plr.CharacterAdded:Wait()
	end

	local arm = char:WaitForChild("Right Arm")

	if armRig then armRig:Destroy() end

	local tabletop = info.ViewportFrame:WaitForChild("Tabletop")

	local newArmRig = Instance.new("Model")
	newArmRig.Name = "ArmRig"

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(1, 1, 1)
	root.Transparency = 1
	root.Anchored = true

	local hum = Instance.new("Humanoid")
	hum.Parent = newArmRig

	local armCopy = Instance.new("Part")
	armCopy.Name = "Right Arm"
	armCopy.Size = Vector3.new(1, 2, 1)
	armCopy.Material = arm.Material
	armCopy.Color = arm.Color
	armCopy.Anchored = true

	local shirt = char:FindFirstChildOfClass("Shirt")
	if shirt then
		shirt:Clone().Parent = newArmRig
	end

	root.CFrame = CFrame.new(tabletop.Position+Vector3.new(0, 2.5, 6)) * CFrame.Angles(0, math.rad(90), 0)
	armCopy.CFrame = root.CFrame*CFrame.new(0, 0, 1.5)*CFrame.Angles(math.rad(-90), 0, 0)

	local originalCFValue = Instance.new("CFrameValue")
	originalCFValue.Value = root.CFrame
	originalCFValue.Name = "OriginalCF"

	root.Parent = newArmRig
	armCopy.Parent = newArmRig
	hum.Parent = newArmRig
	originalCFValue.Parent = newArmRig

	newArmRig.PrimaryPart = root

	newArmRig.Parent = info.ViewportFrame

	armRig = newArmRig
end

local armAnimSequence = 1
local function playArmRigAnim()
	if armRig:FindFirstChild("CancelTween") then
		armRig.CancelTween:Fire()
	end

	local cancelTweenEvent = Instance.new("BindableEvent")
	cancelTweenEvent.Name = "CancelTween"
	cancelTweenEvent.Parent = armRig

	local cancelled = false
	local connection
	connection = cancelTweenEvent.Event:Connect(function()
		cancelled = true
		cancelTweenEvent:Destroy()
		connection:Disconnect()
	end)

	ui.Equip:Play()

	if armAnimSequence == 1 then
		-- Swipe right to left

		coroutine.wrap(function()
			task.wait(.175)
			easeViewportToolDisplay(info.ViewportFrame, Vector3.new(0, 0, 0), Vector3.new(-4, 0, 8), Enum.EasingStyle.Sine, Enum.EasingDirection.In)
		end)()
		for i=0,1,.05 do
			task.wait(.0166)
			if cancelled then break end

			local reachVal = tws:GetValue(1 - math.abs(i-0.5)*2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			armRig:SetPrimaryPartCFrame( armRig.OriginalCF.Value * CFrame.Angles(0, math.rad(i*180), 0) + Vector3.new(0, 0, -2*reachVal) )
		end
	elseif armAnimSequence == 2 then
		-- Swipe left to right

		coroutine.wrap(function()
			task.wait(.175)
			easeViewportToolDisplay(info.ViewportFrame, Vector3.new(0, 0, 0), Vector3.new(4, 0, 8), Enum.EasingStyle.Sine, Enum.EasingDirection.In)
		end)()
		for i=0,1,.05 do
			task.wait(.0166)
			if cancelled then break end

			local reachVal = tws:GetValue(1 - math.abs(i-0.5)*2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			armRig:SetPrimaryPartCFrame( armRig.OriginalCF.Value * CFrame.Angles(0, math.rad((1-i)*180), 0) + Vector3.new(0, 0, -2*reachVal) )
		end
	elseif armAnimSequence == 3 then
		-- Grab from above and yank

		coroutine.wrap(function()
			task.wait(.175)
			easeViewportToolDisplay(info.ViewportFrame, Vector3.new(0, 0, 0), Vector3.new(0, 0, 8), Enum.EasingStyle.Sine, Enum.EasingDirection.In)
		end)()
		for i=0,1,.05 do
			task.wait(.0166)
			if cancelled then break end

			local reachVal = tws:GetValue(1 - math.abs(i-0.5)*2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			armRig:SetPrimaryPartCFrame( armRig.OriginalCF.Value * CFrame.Angles(0, math.rad(90), 0) + Vector3.new(0, 1 - math.clamp(i*2, 0, 1), -2.5*reachVal) )
		end
	end

	armAnimSequence = armAnimSequence+1
	if armAnimSequence > 3 then
		armAnimSequence = 1
	end

	if cancelled == false then
		cancelTweenEvent:Destroy()
	end
end

local function purchaseItem(itemEntryIndex)
	if transitionCooldown == true then return end
	transitionCooldown = true

	info.Message.Text = "PROCESSING..."
	info.Message.Visible = true

	local entry = itemEntries[itemEntryIndex]
	local success, denialReason = remotesFolder.Shop.Purchase:InvokeServer(entry.Name, currentShop)

	if success then
		info.Message.Visible = false

		ui.PurchaseSound:Play()

		playArmRigAnim()

		easeViewportToolDisplay(info.ViewportFrame, Vector3.new(-20, 0, 0), Vector3.new(0, 0, 0), Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	else
		ui.Error:Play()

		info.Message.Text = "COULD NOT VERIFY PURCHASE: "..string.upper(denialReason)
		task.wait(3)
		info.Message.Visible = false
	end

	transitionCooldown = false
end

local function onShopChanged(newShop)
	if currentShop == newShop then return end
	currentShop = newShop

	if currentShop ~= nil then
		loadShop(currentShop.Name)
	else
		closeShop()
	end
end

info.ViewportFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		local cam = info.ViewportFrame:FindFirstChildOfClass("Camera")
		if cam then
			local newFov = math.clamp(cam.FieldOfView - input.Position.Z*8, 5, 40)
			local tween = tws:Create(cam, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {FieldOfView = newFov})
			tween:Play()

			game.Debris:AddItem(tween, 1)
		end
	end
end)

info.Purchase.Activated:Connect(function()
	purchaseItem(selectedItemEntryIndex)
end)

plr.CharacterAdded:Connect(function(char)
	char:WaitForChild("Right Arm"):GetPropertyChangedSignal("Color"):Connect(refreshArmRig)
end)

plr.CharacterAppearanceLoaded:Connect(function(char)
	refreshArmRig()
	local shirt = char:FindFirstChildOfClass("Shirt")
	if shirt then
		shirt:GetPropertyChangedSignal("ShirtTemplate"):Connect(refreshArmRig)
	end
end)

header.Exit.Activated:Connect(closeShop)

plr.ChildAdded:Connect(function(backpack)
	if backpack:IsA("Backpack") then
		backpack.ChildAdded:Connect(function(tool)
			if tool:IsA("Tool") then
				updateInfo()
			end
		end)
	end
end)

remotesFolder = rst:WaitForChild("Remotes")
toolDisplaysFolder = rst:WaitForChild("ToolDisplays")
modulesFolder = rst:WaitForChild("Modules")
assetsFolder = rst:WaitForChild("Assets")
leaderstats = plr:WaitForChild("leaderstats")
toolInfoModule = require(modulesFolder:WaitForChild("ToolInfo"))
shopInfoModule = require(modulesFolder:WaitForChild("ShopInfo"))
teamAlignments = require(modulesFolder:WaitForChild("TeamAlignments"))
cash = plr:WaitForChild("leaderstats"):WaitForChild("Cash")

cash:GetPropertyChangedSignal("Value"):Connect(function()
	if selectedItemEntryIndex ~= nil then
		updateInfo()
	end

	for i,entry in pairs(itemEntries) do
		updateItemEntry(i)
	end
end)

remotesFolder.Shop.ShopChanged.OnClientEvent:Connect(onShopChanged)

prepareViewport(info.ViewportFrame)
selectItem(nil)
refreshArmRig()