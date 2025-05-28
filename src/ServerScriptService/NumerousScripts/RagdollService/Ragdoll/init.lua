-- SERVICES
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- MODULES
local Create = require(ReplicatedStorage.Modules.Create)
local RagdollData = require(ReplicatedStorage.Modules.RagdollData)
local Resize = require(script.Resize)

-- TYPES
export type CharacterType = Model & { Humanoid: Humanoid, HumanoidRootPart: Part }
export type CacheType = {
	Collisions: {[number]: Part},
	Welds: {[number]: Weld},
	Motors: {[number]: Motor6D},
	LastActive: number
}
export type RagdollType = {
	Cache: { [Model]: CacheType },
	RegisterCharacter: (self, Character: CharacterType) -> (),
	FakeRagdoll: (self, Character: CharacterType) -> (),
	SetState: (self, Character: CharacterType) -> (),
	SetOwnership: (self, Character: CharacterType) -> (),
	RemoveOwnership: (self, Character: CharacterType) -> ()
}
export type CollisionDataType = {
	Size: Vector3,
	Offset: CFrame
}

-- RAGDOLL CLASS
local Ragdoll: RagdollType = {
	Cache = {},
}
Ragdoll.__index = Ragdoll

local function assignCollisions(Character, faked, Collisions: {[number]: Part}, Welds: {[number]: Weld}, Motors: {[number]: Motor6D})
	for _, i: Instance in ipairs(Character:GetDescendants()) do
		if i:IsA('Motor6D') and i.Part1 ~= nil and i.Part0 ~= nil then
			for partial_name: string, data: CollisionDataType in next, RagdollData.BodyData do
				if i.Part1.Name:find(partial_name) then
					local collision = Create("Part", i.Part1)({
						Name = "Collision",
						Size = data.Size,
						Anchored = false, -- unachnored
						Massless = true, -- no mass
						CanTouch = false, -- no touch events
						CanCollide = faked, -- no collisions (not being used actively)
						CanQuery = false, -- no raycats
						Transparency = 1
					})
					local weld = Create("Weld", collision)({
						Name = "CollisionWeld",
						Part0 = i.Part1,
						Part1 = collision,
						C0 = data.Offset
					})
					table.insert(Collisions, collision)
					table.insert(Welds, weld)
				end
			end
			if i.Parent.Name ~= "HumanoidRootPart" then
				table.insert(Motors, i)
			end
		end
	end
end

function Ragdoll.RegisterCharacter(Character: CharacterType)
	if Character == nil then
		warn("No rigged character model was provided")
		return
	end
	local Humanoid: Humanoid = Character:FindFirstChild('Humanoid')
	if Humanoid == nil then
		warn("Humanoid was not found in model")
		return
	end
	if Humanoid.RigType ~= Enum.HumanoidRigType.R6 then
		warn("Invalid rig type.")
		return
	end
	Character:SetAttribute('Ragdoll', false)
	Humanoid.BreakJointsOnDeath = false
	Humanoid.RequiresNeck = false
	Ragdoll.Cache[Character] = {
		Collisions = {},
		Welds = {},
		Motors = {},
		LastActive = 0
	}
	for motorName: string, data: AttachmentDataType in next, RagdollData.AttachmentData do
		local motor: Motor6D = Character:FindFirstChild(motorName, true)
		if motor ~= nil and motor.Part0 and motor.Part1 then
			-- part attachment
			local attachment0 = Create("Attachment", motor.Part0)({
				Position = data.PartAttachmentPosition,
				Orientation = data.PartAttachmentOrientation,
				Name = data.Initials .. "_A0"
			})
			-- limb attachment
			local attachment1 = Create("Attachment", motor.Part1)({
				Position = data.LimbAttachmentPosition,
				Orientation = data.LimbAttachmentOrientation,
				Name = data.Initials .. "_A1"
			})
			-- ball socket
			local ballSocket = Create("BallSocketConstraint", attachment0)({
				Name = data.Initials .. "_BSC",
				Attachment0 = attachment0,
				Attachment1 = attachment1,
				Enabled = true
			})
			for key, value in next, data.BallConstraintData do
				ballSocket[key] = value
			end
			--table.insert(Balls, ballSocket)
		end
	end
	assignCollisions(Character, false, Ragdoll.Cache[Character].Collisions, Ragdoll.Cache[Character].Welds, Ragdoll.Cache[Character].Motors)
	task.wait(0.03)
	for _, Weld: Weld in next, Ragdoll.Cache[Character].Welds do
		Weld.Enabled = false
	end
	task.wait(0.03)
	for _, Weld: Weld in next, Ragdoll.Cache[Character].Welds do
		Weld.Enabled = true
	end
	Character:GetAttributeChangedSignal('Ragdoll'):Connect(function()
		Ragdoll.SetState(Character, Character:GetAttribute('Ragdoll') or false)
	end)
	print(Character.Name .. " registered to ragdoll system")
end

function Ragdoll.FakeRagdoll(ripoff: CharacterType)
	local Character: CharacterType = script.R6:Clone()
	local Humanoid: Humanoid = Character:FindFirstChild('Humanoid')
	if Humanoid then
		Humanoid.AutoRotate = false
		Humanoid.PlatformStand = true
		Humanoid.RequiresNeck = false
		Humanoid.BreakJointsOnDeath = false
		Humanoid.Health = 0
		Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		Humanoid.NameDisplayDistance = 0
		
		Humanoid:UnequipTools()
	else
		return warn("Invalid character provided")
	end
	local Motors: MotorCache = {}
	local Balls: BallsCache = {}
	local Welds: WeldCache = {}
	local Collisions: CollisionCache = {}
	for motorName: string, data: AttachmentDataType in next, RagdollData.AttachmentData do
		local motor: Motor6D = Character:FindFirstChild(motorName, true)
		if motor ~= nil and motor.Part0 and motor.Part1 then
			-- part attachment
			local attachment0 = Create("Attachment", motor.Part0)({
				Position = data.PartAttachmentPosition,
				Orientation = data.PartAttachmentOrientation,
				Name = data.Initials .. "_A0"
			})
			-- limb attachment
			local attachment1 = Create("Attachment", motor.Part1)({
				Position = data.LimbAttachmentPosition,
				Orientation = data.LimbAttachmentOrientation,
				Name = data.Initials .. "_A1"
			})
			-- ball socket
			local ballSocket = Create("BallSocketConstraint", attachment0)({
				Name = data.Initials .. "_BSC",
				Attachment0 = attachment0,
				Attachment1 = attachment1,
				Enabled = true
			})
			for key, value in next, data.BallConstraintData do
				ballSocket[key] = value
			end
			table.insert(Balls, ballSocket)
		end
	end
	assignCollisions(Character, true, Collisions, Welds, Motors)
	--resize
	if ripoff:FindFirstChild('HumanoidRootPart') and ripoff.HumanoidRootPart.Size.Z ~= 1 then
		Resize(Character, ripoff.HumanoidRootPart.Size.Z)
	end
	--ripoff clothing, accessories, body colours, and character meshes lol
	for _, i: Instance in next, ripoff:GetChildren() do
		if i:IsA('Accessory') or i:IsA('Hat') or i:IsA('ShirtGraphic') or i:IsA('Shirt') or i:IsA('Pants') or i:IsA('CharacterMesh') or i:IsA('BodyColors') then
			i:Clone().Parent = Character
		end
	end
	task.wait(0.03)
	for _, motor: Motor6D in next, Motors do
		motor.Enabled = false
	end
	Character.Name = "Ragdoll_" .. Character.Name
	return Character, Collisions
end

function Ragdoll.SetState(Character: CharacterType, Enabled: boolean)
	if Character == nil then
		warn("No rigged character model was provided")
		return
	end
	if not Character:FindFirstChild('Humanoid') then
		warn("Humanoid was not found in model")
		return
	end
	if Character.Humanoid.RigType ~= Enum.HumanoidRigType.R6 then
		warn("Invalid rig type.")
		return
	end
	for _, i: Motor6D in next, Ragdoll.Cache[Character].Motors do
		i.Enabled = not Enabled
	end
	for _, i: Part in next, Ragdoll.Cache[Character].Collisions do
		i.CanCollide = Enabled
	end
	--// TODO: Connect to a body part with a size change property being listened to, to make ragdolls work with resize
	local Root: BasePart? = Character:FindFirstChild('HumanoidRootPart')
	if Root then
		Root:GetPropertyChangedSignal('Size'):Connect(function()
			print(Root.Size)
			--// TODO: Implement this to update body parts.
		end)
	end
end

function Ragdoll.SetOwnership(Player: Player, Character: CharacterType)
	for _, i: Instance in next, Character:GetDescendants() do
		if i:IsA('BasePart') then
			i:SetNetworkOwner(Player)
		end
	end
	print('Gave ownership of ' .. Character.Name .. ' to '.. Player.Name)
end

function Ragdoll.RemoveOwnership(Character: CharacterType)
	for _, i: Instance in next, Character:GetDescendants() do
		if i:IsA('BasePart') then
			i:SetNetworkOwner(nil)
		end
	end
	print('Removed ownership of ' .. Character.Name)
end

function Ragdoll.ApplyClient(Player: Player)
	local Client = script.RagdollClient:Clone()
	Client.Parent = Player.PlayerGui
	Client.Disabled = false
end

return Ragdoll