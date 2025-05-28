local CollectionService = game:GetService("CollectionService")
local BlenderModule = require(script.BlenderModule)

local ExistingBlenders = {}

-- Local Functions
local function AddInstance(inst)
	if ExistingBlenders[inst] then return end
	ExistingBlenders[inst] = BlenderModule.new(inst)
end

local function RemoveInstance(inst)
	if not ExistingBlenders[inst] then return end
	ExistingBlenders[inst]:Destroy()
end

-- Tag Reading
local Tag = "BlenderObject"
for _,instance in pairs(CollectionService:GetTagged(Tag)) do AddInstance(instance) end
CollectionService:GetInstanceAddedSignal(Tag):Connect(AddInstance)
CollectionService:GetInstanceRemovedSignal(Tag):Connect(RemoveInstance)