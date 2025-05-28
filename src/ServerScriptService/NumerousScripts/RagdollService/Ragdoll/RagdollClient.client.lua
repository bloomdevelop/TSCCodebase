-- SERVICES
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local PlayerService = game:GetService('Players')

-- VARIABLES
local Player = PlayerService.LocalPlayer

-- MODULES
local Create = require(ReplicatedStorage.Modules.Create)
local RagdollData = require(ReplicatedStorage.Modules.RagdollData)

-- TYPES
export type CharacterType = Model & { Humanoid: Humanoid, HumanoidRootPart: Part }
export type MotorCache<Motor6D> = {[number]: Motor6D}
export type WeldCache<Weld> = {[number]: Weld}
export type CollisionCache<Part> = {[number]: Part}
export type BallsCache<BallSocketConstraint> = {[number]: BallSocketConstraint}
export type BallConstraintData = {
	LimitsEnabled: boolean,
	TwistLimitsEnabled: boolean,
	UpperAngle: number,
	TwistLowerAngle: number,
	TwistUpperAngle: number
}
export type AttachmentDataType = {
	Part: string,
	Initials: string,
	PartAttachmentPosition: Vector3,
	PartAttachmentOrientation: Vector3,
	LimbAttachmentPosition: Vector3,
	LimbAttachmentOrientation: Vector3,
	BallConstraintData: BallConstraintData
}

-- FUNCTIONS
function newCharacter(Character: CharacterType)
	if Character == nil then
		return
	end
	task.wait(0.1) -- wait because we may have unloaded stuff
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
				Enabled = false
			})
			for key, value in next, data.BallConstraintData do
				ballSocket[key] = value
			end
			table.insert(Balls, ballSocket)
			table.insert(Motors, motor)
		end
	end
	for _, i: Instance in next, Character:GetDescendants() do
		if i.Name == "Collision" then
			local weld: Weld = i:FindFirstChildOfClass('Weld')
			if weld then
				table.insert(Welds, weld)
			end
			table.insert(Collisions, i)
		end
	end
	Character:GetAttributeChangedSignal("Ragdoll"):Connect(function()
		local enabled = Character:GetAttribute('Ragdoll') or false;
		(Character.Humanoid :: Humanoid).PlatformStand = enabled;
		(Character.Humanoid :: Humanoid).AutoRotate = not enabled;
		(Character.Humanoid :: Humanoid):ChangeState(enabled and Enum.HumanoidStateType.Physics or Enum.HumanoidStateType.GettingUp);
		(Character.HumanoidRootPart :: Part):ApplyAngularImpulse(((Character.HumanoidRootPart :: Part).CFrame.LookVector * Vector3.new(1,0,1)) * Vector3.new(-90, 0, -90));
		for _, Motor: Motor6D in next, Motors do
			Motor.Enabled = not enabled
		end
		for _, Ball: BallSocketConstraint in next, Balls do
			Ball.Enabled = enabled
		end
		for _, Part: Part in next, Collisions do
			Part.CanCollide = enabled
		end
	end)
	for _, Weld: Weld in next, Welds do
		Weld.Enabled = false
	end
	task.wait(0.1)
	for _, Weld: Weld in next, Welds do
		Weld.Enabled = true
	end
	print('Finished registering character to Ragdoll Client')
end

-- CORE
game:GetService('RunService').Heartbeat:Wait()
script.Parent = Player.PlayerScripts

newCharacter(Player.Character)
Player.CharacterAdded:Connect(newCharacter)
ReplicatedStorage.Remotes.RagdollNetwork.OnClientEvent:Connect(function(newCharacter)
	workspace.Camera.CameraSubject = newCharacter
end)