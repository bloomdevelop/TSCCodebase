function WaitForChild(parent, child)
	while not parent:FindFirstChild(child) do parent.ChildAdded:wait() end
	return parent[child]
end

local character = script.Parent
local Humanoid = WaitForChild(character, "Humanoid")
local Head = WaitForChild(character, "Head")

local charParts = {}
local accessoryParts = {}

local storedValues = {}

local formSounds = {3382281516}
local shatterSounds = {3649319943} --220468096

--[[local iceMesh = Instance.new("SpecialMesh", icePart)
iceMesh.Name = "IceMesh"
iceMesh.MeshType = "FileMesh"
iceMesh.MeshId = "http://www.roblox.com/asset/?id=1290033"
iceMesh.Scale = Vector3.new(0.675, 0.675, 0.675)]]

local function DisableMove()
	Humanoid.AutoRotate = false
	if(Humanoid.WalkSpeed~=0)then
		StoredValues = {Humanoid.WalkSpeed,Humanoid.JumpPower}
		Humanoid.WalkSpeed = 0
		Humanoid.JumpPower = 0
	end
	Humanoid:UnequipTools()
	PreventTools = character.ChildAdded:connect(function(Child)
		wait()
		if Child:IsA("Tool") and Child.Parent == character then
			Humanoid:UnequipTools()
		end
	end)
	DisableJump = Humanoid.Changed:connect(function(Property)
		if Property == "Jump" then
			Humanoid.Jump = false
		end
	end)
	character:SetAttribute('Ragdoll', true)
	Humanoid.PlatformStand = true
	--Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
end

local function EnableMove()
	Humanoid.AutoRotate = true
	Humanoid.WalkSpeed = StoredValues[1]
	Humanoid.JumpPower = StoredValues[2]
	for i, v in pairs({DisableJump, PreventTools}) do
		if v then
			v:disconnect()
		end
	end
	character:SetAttribute('Ragdoll', false)
	Humanoid.PlatformStand = false
	--Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

--add all the parts in the character to charParts, and accessories to accessoryParts
--freeze the character
DisableMove()

IceForm = Instance.new("Sound")
IceForm.Name = "IceForm"
IceForm.SoundId = "rbxassetid://"..formSounds[math.random(1,#formSounds)]
IceForm.Parent = Head
IceForm.PlaybackSpeed = 1
IceForm.Volume = 1.5
game.Debris:AddItem(IceForm, 10)
delay(0, function() IceForm:Play() end)



wait(script.Duration.Value)

--unfreeze the character

EnableMove()

IceShatter = Instance.new("Sound")
IceShatter.Name = "IceShatter"
IceShatter.SoundId = "rbxassetid://"..shatterSounds[math.random(1,#shatterSounds)]
IceShatter.Parent = Head
IceShatter.PlaybackSpeed = 1
IceShatter.Volume = 1.5
game.Debris:AddItem(IceShatter, 10)
delay(0, function() IceShatter:Play() end)
IceShatter.Ended:connect(function()
	if script then
		script:Destroy()
	end
end)