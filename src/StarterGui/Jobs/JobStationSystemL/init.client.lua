local cs = game:GetService("CollectionService")

local modules = {}
for i,module in pairs(script:GetChildren()) do
	modules[module.Name] = require(module)
end

local function setUpStation(model)
	modules[model.JobType.Value]:SetUp(model)
end

local models = cs:GetTagged("JobStation")
for i,model in pairs(models) do
	setUpStation(model)
end

cs:GetInstanceAddedSignal("JobStation"):Connect(function(model)
	setUpStation(model)
end)

while true do
	task.wait(10)
	local models = cs:GetTagged("JobStation")
	for i,model in pairs(models) do
		if model.PrimaryPart ~= nil and model.PrimaryPart:FindFirstChildOfClass("ProximityPrompt") == nil then
			setUpStation(model)
		end
	end
end