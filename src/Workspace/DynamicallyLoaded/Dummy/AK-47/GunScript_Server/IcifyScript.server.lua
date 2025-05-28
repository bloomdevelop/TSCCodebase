function WaitForChild(parent, child)
	while not parent:FindFirstChild(child) do parent.ChildAdded:wait() end
	return parent[child]
end

local character = script.Parent
local Humanoid = WaitForChild(character, "Humanoid")
local Head = WaitForChild(character, "Head")

local charParts = {}
local accessoryParts = {}

local iceParts = {}
local iceParts2 = {}

local storedValues = {}

local formSounds = {1213774145, 1213774319, 1213774433, 1213774543}
local shatterSounds = {3622822508} --220468096

local icePart = Instance.new("Part")
icePart.Name = "IcePart"
icePart.formFactor = "Custom"
icePart.Color = Color3.fromRGB(128, 187, 219)
icePart.Size = Vector3.new(0.2, 0.2, 0.2)
icePart.CanCollide = false
icePart.Anchored = false
icePart.Transparency = .5
icePart.BottomSurface = "Smooth"
icePart.TopSurface = "Smooth"
icePart.Material = Enum.Material.SmoothPlastic
--[[local iceMesh = Instance.new("SpecialMesh", icePart)
iceMesh.Name = "IceMesh"
iceMesh.MeshType = "FileMesh"
iceMesh.MeshId = "http://www.roblox.com/asset/?id=1290033"
iceMesh.Scale = Vector3.new(0.675, 0.675, 0.675)]]

function wait(TimeToWait)
	if TimeToWait ~= nil then
		local TotalTime = 0
		TotalTime = TotalTime + game:GetService("RunService").Heartbeat:wait()
		while TotalTime < TimeToWait do
			TotalTime = TotalTime + game:GetService("RunService").Heartbeat:wait()
		end
	else
		game:GetService("RunService").Heartbeat:wait()
	end
end

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
	Humanoid.PlatformStand = false
    --Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

--add all the parts in the character to charParts, and accessories to accessoryParts
local charChildren = character:GetChildren()
for i = 1, #charChildren do
	if (charChildren[i]:IsA("BasePart") or charChildren[i]:IsA("Part") or charChildren[i]:IsA("WedgePart") or charChildren[i]:IsA("CornerWedgePart") or charChildren[i]:IsA("MeshPart")) and charChildren[i].Name ~= "HumanoidRootPart" then
		table.insert(charParts, charChildren[i])
	end
	if charChildren[i]:IsA("Hat") or charChildren[i]:IsA("Accoutrement") or charChildren[i]:IsA("Accessory") then
		for ii, vv in pairs(charChildren[i]:GetChildren()) do
			if vv:IsA("BasePart") then
				table.insert(accessoryParts, vv)
			end
		end
	end
end

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

for i = 1, #charParts do
	local newIcePart = icePart:Clone()
	--newIcePart.IceMesh.Scale = newIcePart.IceMesh.Scale * charParts[i].Size	
	newIcePart.Size = Vector3.new(charParts[i].Size.x+.1, charParts[i].Size.y+.1, charParts[i].Size.z+.1)	
	newIcePart.CFrame = charParts[i].CFrame
	newIcePart.Parent = character
	
	local Weld = Instance.new("Weld")
	Weld.Part0 = charParts[i]
	Weld.Part1 = newIcePart
	Weld.C0 = charParts[i].CFrame:inverse()
	Weld.C1 = newIcePart.CFrame:inverse()
	Weld.Parent = newIcePart

	table.insert(iceParts, newIcePart)
end

for i = 1, #accessoryParts do
	local newIcePart2 = accessoryParts[i]:Clone()	
    newIcePart2.Name = "IcePart"
    newIcePart2.formFactor = "Custom"
    newIcePart2.Color = Color3.fromRGB(128, 187, 219)
    newIcePart2.CanCollide = false
    newIcePart2.Anchored = false
    newIcePart2.Transparency = .5
    newIcePart2.BottomSurface = "Smooth"
    newIcePart2.TopSurface = "Smooth"
    newIcePart2.Material = Enum.Material.SmoothPlastic
	local mesh = newIcePart2:FindFirstChildOfClass("SpecialMesh")
    mesh.TextureId = ""
    mesh.Scale = Vector3.new(mesh.Scale.x+.1, mesh.Scale.y+.1, mesh.Scale.z+.1)
    newIcePart2.CFrame = accessoryParts[i].CFrame	
	newIcePart2.Parent = character
	
	local Weld2 = Instance.new("Weld")
	Weld2.Part0 = accessoryParts[i]
	Weld2.Part1 = newIcePart2
	Weld2.C0 = accessoryParts[i].CFrame:inverse()
	Weld2.C1 = newIcePart2.CFrame:inverse()
	Weld2.Parent = newIcePart2

	table.insert(iceParts2, newIcePart2)
end

wait(script.Duration.Value)

--unfreeze the character
for i = 1, #iceParts do
	local C = iceParts[i]:GetChildren()
    for ii = 1,#C do
        if C[ii].className == "Weld" then
            C[ii]:Destroy()
        end
    end
	local dir = (iceParts[i].Position-iceParts[i].CFrame.p+Vector3.new(0, 1, 0)).unit
	iceParts[i].Velocity = (dir+Vector3.new(math.random()-.5, 1, math.random()-.5))*20
	iceParts[i].RotVelocity = (dir+Vector3.new(math.random()-.5, math.random()-.5, math.random()-.5))*10
	local force = Instance.new("BodyForce")
	force.Force = dir * 50 * iceParts[i]:GetMass()
	force.Parent = iceParts[i]
	delay(.25, function() force:Destroy() end)
end

for i = 1, #iceParts2 do
	local C = iceParts2[i]:GetChildren()
    for ii = 1,#C do
        if C[ii].className == "Weld" then
            C[ii]:Destroy()
        end
    end
	local dir = (iceParts2[i].Position-iceParts2[i].CFrame.p+Vector3.new(0, 1, 0)).unit
	iceParts2[i].Velocity = (dir+Vector3.new(math.random()-.5, 1, math.random()-.5))*20
	iceParts2[i].RotVelocity = (dir+Vector3.new(math.random()-.5, math.random()-.5, math.random()-.5))*10
	local force = Instance.new("BodyForce")
	force.Force = dir * 50 * iceParts2[i]:GetMass()
	force.Parent = iceParts2[i]
	delay(.25, function() force:Destroy() end)
end

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