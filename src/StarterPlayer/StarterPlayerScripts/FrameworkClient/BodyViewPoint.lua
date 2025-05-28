--[[
	
]]
local CF = CFrame.new()

local Typing = require(script.Parent.Typing)

return function(Framework: Typing.FrameworkType)
	local Replication = {
		Camera = workspace.CurrentCamera,
		Connections = {},
		Functions = {},
		BindedSteps = {},
		HeadMovementType = 1,
		Defaults = {
			Inverse = CFrame.Angles(math.rad(90), math.rad(180), 0):Inverse(),
			Neck = {
				C0 = CFrame.Angles(math.rad(90), math.rad(180), 0):Inverse() * CFrame.new(0, 0, 1)
			},
			RootJoint = {
				C0 = CFrame.Angles(math.rad(90), math.rad(180), 0):Inverse()
			}
		},
		Factors = {
			Abscissa = 0.75,
			Ordinate = 0.65,
			Applicate = 0.1
		}
	}
	Replication.__index = Replication

	-- VARIABLES

	local PlayersService: Players = Framework.Services.Players
	local RunService: RunService = Framework.Services.RunService

	local LocalName: string = Framework.Playerstates.Player.Name 

	local playerRegistry = {}

	local acceptedAccessories = {
		"RightGripAttachment",
		"RightShoulderAttachment",
		"LeftGripAttachment",
		"LeftShoulderAttachment"
	}

	local allowedStates = {
		[Enum.HumanoidStateType.Running] = true
	}

	local tilt = Vector2.new()
	local mouseAngle = 0
	local headSpring = Vector3.new()
	local mouseSpring = Vector3.new()
	local nCF: CFrame? = CFrame.new()

	local prevTilt = Vector2.new()
	local prevMouseAngle = 0
	local prevHeadPos = Vector3.new()

	-- REPLICATION FUNCTION REGISTRY

	function Replication.updateMotorC0(Motor: Motor6D, goal: CFrame, speed: number)
		Motor.C0 = Motor.C0:Lerp(goal, speed)
	end

	function Replication.updateMotorC1(Motor: Motor6D, goal: CFrame, speed: number)
		Motor.C1 = Motor.C1:Lerp(goal, speed)
	end

	local function realNumber(n: number | Vector2 | Vector3 | CFrame): boolean
		if typeof(n) == "CFrame" then
			return (n.Position.Magnitude == n.Position.Magnitude) and (math.abs(n.Position.Magnitude) ~= math.huge)
		elseif type(n) == "vector" then
			return (n.Magnitude == n.Magnitude) and (math.abs(n.Magnitude) ~= math.huge)
		elseif type(n) == "number" then
			return (n == n) and (math.abs(n) ~= math.huge)
		end
		return false
	end

	local function updateArmShadows(b: boolean)
		Framework.Playerstates.Character['Right Arm'].CastShadow = b
		Framework.Playerstates.Character['Left Arm'].CastShadow = b
	end

	local function switchHeadMovement()
		if Replication.HeadMovementType == 2 then
			Replication.HeadMovementType = 0
			return
		end
		Replication.HeadMovementType += 1
	end

	local function updateBody(player: Player, data: bodyDataType)
		if player == nil then
			return
		end
		if player.Character == nil then
			return
		end
		pcall(function() -- SICK OF IT!!
			-- arm movement
			if player.Character:FindFirstChildOfClass("Tool") and player.Character:FindFirstChildOfClass('Tool'):FindFirstChild('GunData') then
				if player.Character.Torso:FindFirstChild("Right Shoulder") then
					Replication.updateMotorC0(player.Character.Torso["Right Shoulder"], (CF + (Vector3.new(1, 0.5, 0) * player.Character.HumanoidRootPart.Size.Z)) * CFrame.Angles(data.ArmAngle * 0.8, 1.55, 0), 0.2)
				end
				if player.Character.Torso:FindFirstChild("Right Shoulder") then
					Replication.updateMotorC0(player.Character.Torso["Left Shoulder"], (CF + (Vector3.new(-1, 0.5, 0) * player.Character.HumanoidRootPart.Size.Z)) * CFrame.Angles(data.ArmAngle * 0.8, -1.55, 0), 0.2)
				end
			else
				if player.Character.Torso:FindFirstChild("Right Shoulder") then
					Replication.updateMotorC0(player.Character.Torso["Right Shoulder"], (CF + (Vector3.new(1, 0.5, 0) * player.Character.HumanoidRootPart.Size.Z)) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0)), 0.2)
				end
				if player.Character.Torso:FindFirstChild("Right Shoulder") then
					Replication.updateMotorC0(player.Character.Torso["Left Shoulder"], (CF + (Vector3.new(-1, 0.5, 0) * player.Character.HumanoidRootPart.Size.Z)) * CFrame.Angles(math.rad(0), math.rad(-90), math.rad(0)), 0.2)
				end
			end
			-- head movement
			if player.Character ~= nil and player.Character:FindFirstChild('Torso') ~= nil then
				Replication.updateMotorC0((((player.Character :: Model):FindFirstChild('Torso') :: Part):FindFirstChild('Neck') :: Motor6D), (Replication.Defaults.Inverse + (Vector3.new(0, 1, 0) * ((player.Character :: Model):FindFirstChild('Torso') :: Part).Size.Z)) * data.HeadCFrame, 0.2)
			end
			-- body movement
			if player.Character ~= nil and player.Character:FindFirstChild('HumanoidRootPart') ~= nil and player.Character.HumanoidRootPart:FindFirstChild("RootJoint") then
				Replication.updateMotorC0(player.Character.HumanoidRootPart.RootJoint, Replication.Defaults.Inverse * CFrame.Angles(
					math.rad(data.TorsoTilt.Y * 3),
					math.rad(-data.TorsoTilt.X * 4),
					math.rad(-data.TorsoTilt.X * 6)
					), 0.2)
			end
		end)
	end

	-- RUN SERVICE REGISTRY

	local viewmodelSwitches = {
		on = function()
			updateArmShadows(false)
			local CamY, CamX, CamZ = Replication.Camera.CFrame:ToEulerAnglesYXZ()
			--print(math.deg(CamX).." "..math.deg(CamY).." ".. math.deg(CamZ))
			local firstframe = CFrame.new( Vector3.new(Replication.Camera.CFrame.Position.X,Replication.Camera.CFrame.Position.Y,Replication.Camera.CFrame.Position.Z) ) * CFrame.fromEulerAnglesXYZ(CamY,0,0)
			local TorsX,TorsY,TorsZ = Framework.Playerstates.Character.Torso.CFrame.Rotation:ToEulerAnglesXYZ()
			local torsoframe = CFrame.new(Framework.Playerstates.Character.Torso.Position.X,Framework.Playerstates.Character.Torso.Position.Y,Framework.Playerstates.Character.Torso.Position.Z) * CFrame.fromEulerAnglesXYZ(TorsX,TorsY,TorsZ)
			Replication.updateMotorC0((Framework.Playerstates.Character.Torso["Right Shoulder"] :: Motor6D), (CFrame.new(firstframe.Position) * torsoframe.Rotation * firstframe.Rotation * CFrame.new(1, -1, -0.5)):ToObjectSpace(Framework.Playerstates.Character.Torso.CFrame):Inverse() * CFrame.Angles(0, math.pi / 2, 0), 0.2)
			Replication.updateMotorC0((Framework.Playerstates.Character.Torso["Left Shoulder"] :: Motor6D), (CFrame.new(firstframe.Position) * torsoframe.Rotation * firstframe.Rotation  * CFrame.new(-1, -1, -0.5)):ToObjectSpace(Framework.Playerstates.Character.Torso.CFrame):Inverse() * CFrame.Angles(0, -math.pi / 2, 0), 0.2)
		end,
		off = function()
			updateArmShadows(true)
			if Framework.Playerstates.ToolEquiped then
				Replication.updateMotorC0((Framework.Playerstates.Character.Torso["Right Shoulder"] :: Motor6D), (CF + (Vector3.new(1, 0.5, 0) * Framework.Playerstates.Character.Torso.Size.Z)) * CFrame.Angles(mouseAngle * 0.8, 1.55, 0), 0.2)
				Replication.updateMotorC0((Framework.Playerstates.Character.Torso["Left Shoulder"] :: Motor6D), (CF + (Vector3.new(-1, 0.5, 0) * Framework.Playerstates.Character.Torso.Size.Z)) * CFrame.Angles(mouseAngle * 0.8, -1.55, 0), 0.2)
			else
				Replication.updateMotorC0((Framework.Playerstates.Character.Torso["Right Shoulder"] :: Motor6D), (CF + (Vector3.new(1, 0.5, 0) * Framework.Playerstates.Character.Torso.Size.Z)) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0)), 0.2)
				Replication.updateMotorC0((Framework.Playerstates.Character.Torso["Left Shoulder"] :: Motor6D), (CF + (Vector3.new(-1, 0.5, 0) * Framework.Playerstates.Character.Torso.Size.Z)) * CFrame.Angles(math.rad(0), math.rad(-90), math.rad(0)), 0.2)
			end
		end,
	}
	
	RunService:BindToRenderStep("localBodyUpdate", Enum.RenderPriority.Character.Value, function()
		-- if character, root, humanoid, and torso exists
		if Framework.Playerstates.Character ~= nil and Framework.Playerstates.Character:FindFirstChild("HumanoidRootPart") and Framework.Playerstates.Character:FindFirstChild('Humanoid') and Framework.Playerstates.Character:FindFirstChild('Torso') then
			if Framework.Playerstates.Character.Humanoid.MoveDirection.Magnitude > 0.1 and allowedStates[Framework.Playerstates.Character.Humanoid:GetState()] then
				local direction = Vector2.new(
					math.rad(Framework.Playerstates.Character.HumanoidRootPart.CFrame.RightVector:Dot((Framework.Playerstates.Character.HumanoidRootPart.Velocity * Vector3.new(1,0,1)).Unit) * 200),
					math.rad(Framework.Playerstates.Character.HumanoidRootPart.CFrame.LookVector:Dot((Framework.Playerstates.Character.HumanoidRootPart.Velocity * Vector3.new(1,0,1)).Unit) * 200)
				)
				tilt = direction.Unit * math.clamp((Framework.Playerstates.Character.HumanoidRootPart.Velocity.Magnitude / 14), 0, 2)
			else
				tilt = Vector2.new()
			end
			if Framework.Playerstates.Mouse then
				mouseAngle = -math.asin((Framework.Playerstates.Mouse.Origin.Position - Framework.Playerstates.Mouse.Hit.Position).Unit.Y)
			end
			if Replication.Camera then
				headSpring = Framework.Playerstates.Character.HumanoidRootPart.CFrame:ToObjectSpace(Replication.Camera.CFrame).LookVector
				if Framework.Playerstates.Mouse then
					mouseSpring = Framework.Playerstates.Character.HumanoidRootPart.CFrame:ToObjectSpace(CFrame.new(Replication.Camera.CFrame.Position, Framework.Playerstates.Mouse.Hit.Position)).LookVector
				end
			end
			-- head movement
			if Framework.Playerstates.Character:FindFirstChild("Head") and Framework.Playerstates.Character.Torso:FindFirstChild("Neck") and realNumber(mouseSpring) and realNumber(headSpring) then
				--[[
					0 = disabled
					1 = camera
					2 = mouse
				]]
				if Replication.HeadMovementType ~= 0 then
					if ((Replication.Camera.CFrame.Position - Framework.Playerstates.Character.Head.Position).Magnitude > 1) then
						if Replication.HeadMovementType == 2 then
							nCF =
								CFrame.Angles(0, 0, -math.asin(mouseSpring.X) * Replication.Factors.Abscissa) * 
								CFrame.Angles(-math.asin(mouseSpring.Y) * Replication.Factors.Ordinate, 0, 0) *
								CFrame.Angles(0, -math.asin(mouseSpring.X) * Replication.Factors.Applicate, 0)
						else
							nCF = CFrame.Angles(0, 0, -math.asin(headSpring.X) * Replication.Factors.Abscissa) * 
								CFrame.Angles(-math.asin(headSpring.Y) * Replication.Factors.Ordinate, 0, 0) *
								CFrame.Angles(0, -math.asin(headSpring.X) * Replication.Factors.Applicate, 0)
						end
					else
						nCF = CFrame.Angles(-math.asin(headSpring.Y) * Replication.Factors.Ordinate, 0, 0)
					end
				else
					nCF = CF
				end
				Replication.updateMotorC0((Framework.Playerstates.Character.Torso:FindFirstChild("Neck") :: Motor6D), (Replication.Defaults.Inverse + (Vector3.new(0, 1, 0) * Framework.Playerstates.Character.Torso.Size.Z)) * nCF, 0.2)
			end
			-- arm movement
			if realNumber(mouseAngle) and Framework.Playerstates.Character:FindFirstChild("Torso") and Framework.Playerstates.Character:FindFirstChild("Head") and Framework.Playerstates.Character:FindFirstChild("Left Arm") and Framework.Playerstates.Character:FindFirstChild("Right Arm") then
				if Framework.Playerstates.Character.Torso:FindFirstChild("Right Shoulder") and Framework.Playerstates.Character.Torso:FindFirstChild("Left Shoulder") then
					if (Replication.Camera.CFrame.Position - Framework.Playerstates.Character.Head.Position).Magnitude < 1.3 then
						viewmodelSwitches.on()
					else
						viewmodelSwitches.off()
					end
				end
			end
			-- body movement
			if realNumber(tilt.Magnitude) and Framework.Playerstates.Character.HumanoidRootPart:FindFirstChild("RootJoint") then
				Replication.updateMotorC0((Framework.Playerstates.Character.HumanoidRootPart.RootJoint :: Motor6D), Replication.Defaults.Inverse * CFrame.Angles(
					math.rad(tilt.Y * 3),
					math.rad(-tilt.X * 4),
					math.rad(-tilt.X * 6)
					), 0.2)
			end
		end
	end)
	
	RunService:BindToRenderStep("firstpersonArms", Enum.RenderPriority.Character.Value, function()
		if Framework.Playerstates.Character ~= nil then
			for _, i: Instance in next, Framework.Playerstates.Character:GetChildren() do
				if i:IsA("BasePart") and (i.Name == "Left Arm" or i.Name == "Right Arm") then
					i.LocalTransparencyModifier = 0
				elseif i:IsA("Accessory") then
					local attach = i:FindFirstChildOfClass('Attachment')
					if attach and table.find(acceptedAccessories, attach.Name) then
						for _, p: Instance in next, i.Handle:GetDescendants() do
							if p:IsA('BasePart') then
								p.LocalTransparencyModifier = 0
							end
						end
					end
				elseif i.Name == "Arms" then
					for _, limb: Instance in next, i.Handle:GetChildren() do
						if limb:IsA('BasePart') then
							limb.LocalTransparencyModifier = 0
						end
					end
				end
			end
		end
	end)
	table.insert(Replication.BindedSteps, "localBodyUpdate")
	table.insert(Replication.BindedSteps, "firstpersonArms")
	
	Framework.UserInput:AddInput("changeMouseType", { Enum.KeyCode.P }, function()
		switchHeadMovement()
	end, { checkText = true })
	
	return Replication
end