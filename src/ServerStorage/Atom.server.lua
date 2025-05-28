local replicatedStorage = game:GetService('ReplicatedStorage')
local runService = game:GetService('RunService')

local explode = script:WaitForChild('Explode')

local CloudID = "rbxassetid://1095708"
local ColorTexture = "rbxassetid://1361097"
local RingID = "rbxassetid://3270017"
local SphereID = "rbxassetid://1185246"

local BasePosition = script:WaitForChild('Pos').Value
local Size = 25

local function wait(waitTime: number)
	local deltaTime = 0

	if waitTime and waitTime > 0 then
		while deltaTime < waitTime do
			deltaTime = deltaTime + runService.Heartbeat:wait()
		end
	else
		deltaTime = deltaTime + runService.Heartbeat:wait()
	end
	return deltaTime
end

local Exp = Instance.new("Model")
Exp.Name = "ATOMICEXPLOSION"
Exp.Parent = workspace

local BasePart = Instance.new("Part")
BasePart.TopSurface = 0
BasePart.BottomSurface = 0
BasePart.Anchored = true
BasePart.Locked = true
BasePart.CanCollide = false

local BaseMesh = Instance.new("SpecialMesh")
BaseMesh.MeshType = "FileMesh"

local CloudMesh = BaseMesh:Clone()
CloudMesh.MeshId = CloudID
CloudMesh.TextureId = ColorTexture
CloudMesh.VertexColor = Vector3.new(0.9,0.6,0)

local RingMesh = BaseMesh:Clone()
RingMesh.MeshId = RingID

local SphereMesh = BaseMesh:Clone()
SphereMesh.MeshId = SphereID

local Clouds = {}
local ShockWave = {}

local Base = BasePart:Clone()
Base.Position = BasePosition

local Mesh = CloudMesh:Clone()
Mesh.Parent = Base 
Mesh.Scale = Vector3.new(250,100,450)

local PoleBase = BasePart:Clone()
PoleBase.Position = BasePosition+Vector3.new(0,10,0)

local PoleBaseMesh = CloudMesh:Clone()
PoleBaseMesh.Scale = Vector3.new(125,200,250)
PoleBaseMesh.Parent = PoleBase

local Cloud1 = BasePart:Clone()
Cloud1.Position = BasePosition+Vector3.new(0,75,0)

local Cloud1Mesh = CloudMesh:Clone()
Cloud1Mesh.Scale = Vector3.new(50,300,100)
Cloud1Mesh.Parent = Cloud1

local Cloud2 = BasePart:Clone()
Cloud2.Position = BasePosition+Vector3.new(0,125,0)

local Cloud2Mesh = CloudMesh:Clone()
Cloud2Mesh.Scale = Vector3.new(50,150,100)
Cloud2Mesh.Parent = Cloud2

local Cloud3 = BasePart:Clone()
Cloud3.Position = BasePosition+Vector3.new(0,170,0)

local Cloud3Mesh = CloudMesh:Clone()
Cloud3Mesh.Scale = Vector3.new(50,150,100)
Cloud3Mesh.Parent = Cloud3

local PoleRing = BasePart:Clone()
PoleRing.Position = BasePosition+Vector3.new(0,130,0)
PoleRing.Transparency = 0.2
PoleRing.BrickColor = BrickColor.new("Dark stone grey")
PoleRing.CFrame = PoleRing.CFrame*CFrame.Angles(math.rad(90),0,0)

local Mesh = RingMesh:Clone()
Mesh.Scale = Vector3.new(100,100,100)
Mesh.Parent = PoleRing

local MushCloud = BasePart:Clone()
MushCloud.Position = BasePosition+Vector3.new(0,230,0)

local MushMesh = CloudMesh:Clone() -- lol
MushMesh.Scale = Vector3.new(250,175,350)
MushMesh.Parent = MushCloud

local TopCloud = BasePart:Clone()
TopCloud.Position = BasePosition+Vector3.new(0,270,0)

local TopMesh = CloudMesh:Clone()
TopMesh.Scale = Vector3.new(75,150,150)
TopMesh.Parent = TopCloud

table.insert(Clouds,Base)
table.insert(Clouds,TopCloud)
table.insert(Clouds,MushCloud)
table.insert(Clouds,Cloud1)
table.insert(Clouds,Cloud2)
table.insert(Clouds,Cloud3)
table.insert(Clouds,PoleBase)
table.insert(Clouds,PoleRing)

local BigRing = BasePart:Clone()
BigRing.Position = BasePosition
BigRing.CFrame = BigRing.CFrame*CFrame.Angles(math.rad(90),0,0)

local BigMesh = RingMesh:Clone()
BigMesh.Scale = Vector3.new(500,500,100)
BigMesh.Parent = BigRing

local SmallRing = BasePart:Clone()
SmallRing.Position = BasePosition
SmallRing.BrickColor = BrickColor.new("Dark stone grey")
SmallRing.CFrame = SmallRing.CFrame*CFrame.Angles(math.rad(90),0,0)

local SmallMesh = RingMesh:Clone()
SmallMesh.Scale = Vector3.new(460,460,150)
SmallMesh.Parent = SmallRing

local InnerSphere = BasePart:Clone()
InnerSphere.Position = BasePosition
InnerSphere.BrickColor = BrickColor.new("Bright orange")
InnerSphere.Transparency = 0.5

local InnerSphereMesh = SphereMesh:Clone()	
InnerSphereMesh.Scale = Vector3.new(-650,-650,-650)
InnerSphereMesh.Parent = InnerSphere

local OutterSphere = BasePart:Clone()
OutterSphere.Position = BasePosition
OutterSphere.BrickColor = BrickColor.new("Bright orange")
OutterSphere.Transparency = 0.5

local OutterSphereMesh = SphereMesh:Clone()
OutterSphereMesh.Scale = Vector3.new(650,650,650)
OutterSphereMesh.Parent = OutterSphere

table.insert(ShockWave,BigRing)	
table.insert(ShockWave,SmallRing)
table.insert(ShockWave,OutterSphere)
table.insert(ShockWave,InnerSphere)
for i , v in ipairs(ShockWave) do
	v.Parent = Exp
end
for i , v in ipairs(Clouds) do
	v.Parent = Exp
end
explode:Play()
local explosion = Instance.new('Explosion')
explosion.Position = BasePosition
explosion.Parent = workspace
coroutine.wrap(function()
	for resize = 1, Size * 2.2, 0.03 do
		for i, v in pairs(workspace:GetChildren()) do
			if v:IsA('Model') then
				local humanoid = v:FindFirstChildOfClass('Humanoid')
				local root = v:FindFirstChild('HumanoidRootPart')
				if humanoid and root and humanoid:GetState() ~= Enum.HumanoidStateType.Dead and (root.Position - BasePosition).magnitude <= 270 * resize then
					humanoid:TakeDamage(100)
				end
			end
		end
		wait(0.1)
	end
end)()
coroutine.wrap(function()
	for resize = 1, Size*2.2, 0.03 do
		wait()
		BigRing.Mesh.Scale = Vector3.new(500*resize,500*resize,100*resize)
		SmallRing.Mesh.Scale = Vector3.new(460*resize,460*resize,150*resize)
		InnerSphere.Mesh.Scale = Vector3.new(-650*resize,-650*resize,-650*resize)
		OutterSphere.Mesh.Scale = Vector3.new(650*resize,650*resize,650*resize)
	end
	for fade = 1, 1.1, 0.001 do
		wait()
		BigRing.Mesh.Scale = Vector3.new(500*Size*2*fade,500*Size*2*fade,100*Size*2*fade)
		SmallRing.Mesh.Scale = Vector3.new(460*Size*2*fade,460*Size*2*fade,150*Size*2*fade)
		InnerSphere.Mesh.Scale = Vector3.new(-600*Size*2*fade,-600*Size*2*fade,-600*Size*2*fade)
		OutterSphere.Mesh.Scale = Vector3.new(600*Size*2*fade,600*Size*2*fade,600*Size*2*fade)
		for i ,v in ipairs(ShockWave) do
			v.Transparency = v.Transparency+0.01
		end
	end
	for i ,v in ipairs(ShockWave) do
		v:Destroy()
	end
end)()
coroutine.wrap(function()
	for resize = 0.5, Size*1.5, 0.02 do
		wait()
		Base.Mesh.Scale = Vector3.new(250*resize,100*resize,450*resize)
		TopCloud.Mesh.Scale = Vector3.new(75*resize,150*resize,150*resize)
		MushCloud.Mesh.Scale = Vector3.new(250*resize,175*resize,350*resize)
		Cloud1.Mesh.Scale = Vector3.new(50*resize,300*resize,100*resize)
		Cloud2.Mesh.Scale = Vector3.new(50*resize,150*resize,100*resize)
		Cloud3.Mesh.Scale = Vector3.new(50*resize,150*resize,100*resize)
		PoleBase.Mesh.Scale = Vector3.new(125*resize,200*resize,250*resize)
		PoleRing.Mesh.Scale = Vector3.new(100*resize,100*resize,100*resize)
		Base.Position = BasePosition+Vector3.new(0,5*resize,0)
		TopCloud.Position = BasePosition+Vector3.new(0,270*resize,0)
		MushCloud.Position = BasePosition+Vector3.new(0,230*resize,0)
		Cloud1.Position = BasePosition+Vector3.new(0,75*resize,0)
		Cloud2.Position = BasePosition+Vector3.new(0,125*resize,0)
		Cloud3.Position = BasePosition+Vector3.new(0,170*resize,0)
		PoleBase.Position = BasePosition+Vector3.new(0,10*resize,0)
		PoleRing.Position = BasePosition+Vector3.new(0,130*resize,0)
	end
end)()
wait(2)
for y = 0.6,0,-0.0025 do
	wait()
	for i , v in ipairs(Clouds) do
		v.Mesh.VertexColor = Vector3.new(0.9,y,0)
	end
end
for r = 0.9,0.5,-0.01 do
	wait()
	for i , v in ipairs(Clouds) do
		v.Mesh.VertexColor = Vector3.new(r,0,0)
	end
end
for by = 0,0.5,0.005 do
	wait()
	for i , v in ipairs(Clouds) do
		v.Mesh.VertexColor = Vector3.new(0.5,by,by)
		v.Transparency = by*2
	end
	Base.Mesh.Scale = Base.Mesh.Scale+Vector3.new(0.1,0.1,0.1)
	TopCloud.Mesh.Scale = TopCloud.Mesh.Scale+Vector3.new(0.1,0.1,0.1)
	MushCloud.Mesh.Scale = MushCloud.Mesh.Scale+Vector3.new(0.1,0.1,0.1)
	Cloud1.Mesh.Scale = Cloud1.Mesh.Scale+Vector3.new(0.1,0.1,0.1)
	Cloud2.Mesh.Scale = Cloud2.Mesh.Scale+Vector3.new(0.1,0.1,0.1)
	Cloud3.Mesh.Scale = Cloud3.Mesh.Scale+Vector3.new(0.1,0.1,0.1)
	PoleBase.Mesh.Scale = PoleBase.Mesh.Scale+Vector3.new(0.1,0.1,0.1)
	PoleRing.Mesh.Scale = PoleRing.Mesh.Scale+Vector3.new(0.1,0.1,0.1)
end
wait(10)
Exp:Destroy()
script:Destroy()