local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local Tools = ServerStorage:WaitForChild("Tools")

local ConnectionMap: {[Model]: {RBXScriptConnection}} = {}

function hookPart(model: Model)
	if not model:IsA("Model") then return end

	local running = false
	local full = false	

	local button = model:WaitForChild("Interactive")
	local stream = model:WaitForChild("Stream")
	local fakeCoffee = model:WaitForChild("FakeCoffee")
	local Coffee = model:WaitForChild("Coffee")
	local pot = model:WaitForChild("CoffeePot")
	local brewSound = pot:WaitForChild("Brew")
	
	ConnectionMap[model] = {}

	table.insert(ConnectionMap[model], button:WaitForChild("ClickDetector").MouseClick:Connect(function()
		if running or full then return end
		running = true
		brewSound:Play()
		fakeCoffee.Transparency = 0
		for i = 1, 10 do
			stream.Mesh.Scale = stream.Mesh.Scale + Vector3.new(0.04, 0, 0.04)
			fakeCoffee.Mesh.Scale = fakeCoffee.Mesh.Scale + Vector3.new(0, 0.03, 0)
			fakeCoffee.Mesh.Offset = fakeCoffee.Mesh.Offset + Vector3.new(0, 0.003, 0)
			task.wait(.05)
		end
		for i = 1, 72 do
			fakeCoffee.Mesh.Scale = fakeCoffee.Mesh.Scale + Vector3.new(0, 0.03, 0)
			fakeCoffee.Mesh.Offset = fakeCoffee.Mesh.Offset + Vector3.new(0, 0.003, 0)
			task.wait(.05)
		end
		for i = 1, 10 do
			stream.Mesh.Scale = stream.Mesh.Scale + Vector3.new(-0.04, 0, -0.04)
			fakeCoffee.Mesh.Scale = fakeCoffee.Mesh.Scale + Vector3.new(0, 0.03, 0)
			fakeCoffee.Mesh.Offset = fakeCoffee.Mesh.Offset + Vector3.new(0, 0.003, 0)
			task.wait(.05)
		end
		Coffee.Transparency = 0
		task.wait()
		fakeCoffee.Transparency = 1
		fakeCoffee.Mesh.Scale = Vector3.new(1,0,1)
		fakeCoffee.Mesh.Offset = Vector3.new(0, 0, 0)
		pot.ClickDetector.MaxActivationDistance = 12
		full = true
		running = false
	end))

	table.insert(ConnectionMap[model], pot:WaitForChild("ClickDetector").MouseClick:Connect(function(player)
		if running or not full then return end
		full = false
		Coffee.Transparency = 1
		pot.ClickDetector.MaxActivationDistance = 0
		
		local CoffeeTool = Tools["Coffee"]:Clone()
		CoffeeTool.CanBeDropped = false
		CoffeeTool.Parent = player.Backpack
	end))
end

for _,part in CollectionService:GetTagged("CoffeeMaker") do
	hookPart(part)
end

CollectionService:GetInstanceAddedSignal("CoffeeMaker"):Connect(hookPart)
CollectionService:GetInstanceRemovedSignal("CoffeeMaker"):Connect(function(model)
	if not ConnectionMap[model] then return end
	
	for _, connection in ipairs(ConnectionMap[model]) do
		connection:Disconnect()
	end
	
	ConnectionMap[model] = nil
end)