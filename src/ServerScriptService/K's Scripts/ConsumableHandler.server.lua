local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

Instance.new("Folder",ServerStorage).Name = "RespawningItems" -- Make sure they have a place to go.

local Connections = {}

local function CustomWait(val)
	if val ~= nil and (tonumber(val) or typeof(val) == "NumberRange") then
		if typeof(val) == "NumberRange" then val = math.random(val.Min,val.Max) end
		task.wait(tonumber(val))
	else task.wait(20) end
end

local function GiveItem(plr,item)
	if (not typeof(item) == "Instance") then warn("Specify an instance!") return end
	local Character = plr.Character
	local NewItem = item:Clone()
	
	if NewItem:IsA("Tool") then
		NewItem.Parent = plr.Backpack
	elseif not Character:FindFirstChild(NewItem.Name) then
		NewItem.Parent = Character
	else NewItem:Destroy() return end
end

local function equipSound(part, audioID)
	if not part then return end
	coroutine.resume(coroutine.create(function()
		local EquipSound = script.BuiltIn.EquipSound:Clone()
		EquipSound.Parent = part
		if audioID and audioID ~= "" then EquipSound.SoundId = audioID end
		if not EquipSound.IsLoaded then EquipSound.Loaded:Wait() end
		EquipSound:Play()
		EquipSound.Ended:Wait()
		if EquipSound then EquipSound:Destroy() end
	end))
end

local function AddItem(instance)
	if typeof(instance) == "Model" and not instance.PrimaryPart then instance.PrimaryPart = instance:FindFirstChildWhichIsA("Basepart",true) end
	local MainPart = typeof(instance) == "Model" and instance.PrimaryPart or instance
	
	-- Initialize Prompt.
	local ProximityPrompt = Instance.new("ProximityPrompt",MainPart)
	ProximityPrompt.ObjectText = instance.Name
	ProximityPrompt.ActionText = "Take"
	ProximityPrompt.MaxActivationDistance = 5
	ProximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	
	local CD = false
	
	-- Add the connection to a table.
	Connections[instance] = ProximityPrompt.Triggered:Connect(function(plr)
		if CD then return end
		CD = true
		-- Character Check.
		local Character = plr.Character 
		if not Character then return end
		
		-- Equip the Item (and play the custom attribute if it exists.)
		equipSound(Character.HumanoidRootPart,instance:GetAttribute("CustomEquipSound")) 
		for _, v in pairs(instance:GetDescendants()) do if v:IsA("ObjectValue") and v.Value then GiveItem(plr,v.Value) end end
		
		-- Stock Logic Handling.
		local Stock = instance:GetAttribute("StockAmount") 
		if tonumber(Stock) then 
			Stock -= 1 
			if Stock <= 0 then instance:Destroy() return end
			instance:SetAttribute("StockAmount",Stock)
		end
		
		-- Respawn Time Logic Handling.
		local RespawnTime = instance:GetAttribute("RespawnTime")
		if RespawnTime ~= nil and ((typeof(RespawnTime) == "NumberRange") and (RespawnTime.Max > 0)) or (tonumber(RespawnTime) and RespawnTime > 0) then
			local ogParent = instance.Parent

			instance.Parent = ServerStorage.RespawningItems or ServerStorage

			CustomWait(RespawnTime)
			
			instance.Parent = ogParent
		end
		CD = false
	end)
end

local function RemoveItem(instance)
	if not Connections[instance] then return end
	Connections[instance]:Disconnect()
	
	print(instance.Name .. " has been disconnected.")
end

for _,item in pairs(CollectionService:GetTagged("RespawningItem")) do AddItem(item) end
CollectionService:GetInstanceAddedSignal("RespawningItem"):Connect(AddItem)
CollectionService:GetInstanceRemovedSignal("RespawningItem"):Connect(RemoveItem)