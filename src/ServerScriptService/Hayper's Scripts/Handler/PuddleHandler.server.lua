local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local InfectedCheckModule = require(ReplicatedStorage:WaitForChild("InfectedCheckModule"))

local ConnectionMap: {[BasePart]: RBXScriptConnection} = {}

function hookPart(part: BasePart)
	if not part:IsA("BasePart") then return end

	ConnectionMap[part] = part.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)

		if not player then return end

		local characterType = character:FindFirstChild("Type") :: StringValue
		local infectMeter = character:FindFirstChild("Infectionmet") :: IntValue
		local color = character:FindFirstChild("Color") :: Color3Value

		if not infectMeter or InfectedCheckModule(player) or character:FindFirstChild('FullImmunity') then return end

		local dmg = part:GetAttribute("dmg") or 10

		if character:FindFirstChild('SemiImmunity') ~= nil then
			dmg *= 0.5
		elseif character:FindFirstChild('Immunity') ~= nil then
			dmg *= 0.2
		end

		if 0 >= dmg then return end

		infectMeter.Value += dmg

		if color then color.Value = part.Color end

		local partType = part:FindFirstChild("Type") :: StringValue
		if partType and characterType then characterType.Value = partType.Value end
	end)
end

for _,part in CollectionService:GetTagged("Puddle") do
	hookPart(part)
end

CollectionService:GetInstanceAddedSignal("Puddle"):Connect(hookPart)

CollectionService:GetInstanceRemovedSignal("Puddle"):Connect(function(part: BasePart)
	if not ConnectionMap[part] then return end
	ConnectionMap[part]:Disconnect()
	ConnectionMap[part] = nil
end)