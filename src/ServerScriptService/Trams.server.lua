-- // Steven_Scripts, 2022

local TweenService = game:GetService("TweenService")

local maxTramSpeed = 70

local tram = {}
tram.__index = tram

function tram.new(folder)
	local self = setmetatable({}, tram)
	
	local nodes = folder.Nodes
	self.Nodes = nodes
	
	local tram = folder.TramMain
	self.Tram = tram
	
	local sfx = tram.TramSFX
	self.SFX = sfx

	local S1B = tram.Station1Button.ClickDetector
	self.S1B = S1B

	local S1CB = folder.Station1CallButton.ClickDetector
	local S2CB = folder.Station2CallButton.ClickDetector
	self.S1CB = S1CB
	self.S2CB = S2CB
	
	local defaultOrientation = tram:FindFirstChild("DefaultOrientation")
	if defaultOrientation then
		defaultOrientation = defaultOrientation.Value
	else
		defaultOrientation = Vector3.new(0, 270, 0)
	end

	self.DefaultOrientation = defaultOrientation

	local numOfNodes = 0
	for i,node in pairs(nodes:GetChildren()) do
		numOfNodes += 1

		if i==1 then
			local attachment = Instance.new("Attachment")
			
			attachment.Name = "DefaultAttachment1"
			attachment.CFrame = attachment.CFrame*CFrame.Angles(math.rad(defaultOrientation.X), math.rad(defaultOrientation.Y+90), math.rad(defaultOrientation.Z))
			
			attachment.Parent = node
		end
	end
	
	self.NumberOfNodes = numOfNodes

	local prismaticConstraint = Instance.new("PrismaticConstraint")

	prismaticConstraint.ActuatorType = Enum.ActuatorType.Servo

	prismaticConstraint.ServoMaxForce = 100000000
	prismaticConstraint.Speed = maxTramSpeed

	prismaticConstraint.Attachment0 = tram.Attachment0
	prismaticConstraint.Attachment1 = nodes["1"].DefaultAttachment1
	prismaticConstraint.Parent = tram
	
	self.PrismaticConstraint = prismaticConstraint

	self.Moving = false
	self.CurrentStation = 1
	
	local callButtons = {
		tram.Station1Button,
		folder.Station1CallButton,
		folder.Station2CallButton
	}

	for i,button in pairs(callButtons) do
		button.ClickDetector.MouseClick:Connect(function(plr)
			self:CallTram(plr, button)
		end)
	end
	
	local frontBumper = tram.FrontBumper
	local backBumper = tram.BackBumper
	
	frontBumper.Touched:Connect(function(hit)
		if self.Moving == true and prismaticConstraint.Speed > 50 and self.CurrentStation == 1 then
			local char = hit.Parent
			local hum = char:FindFirstChildOfClass("Humanoid")
			
			if hum and hum.Health > 0 then
				hum:TakeDamage(200)
				frontBumper.Impact:Play()
			end
		end
	end)
	
	backBumper.Touched:Connect(function(hit)
		if self.Moving == true and prismaticConstraint.Speed > 50 and self.CurrentStation == 2 then
			local char = hit.Parent
			local hum = char:FindFirstChildOfClass("Humanoid")

			if hum and hum.Health > 0 then
				hum:TakeDamage(200)
				backBumper.Impact:Play()
			end
		end
	end)
end

function tram:MoveTram()
	local nodes = self.Nodes

	local tram = self.Tram

	local sfx = self.SFX

	local S1B = self.S1B

	local S1CB = self.S1CB
	local S2CB = self.S2CB
	
	local numOfNodes = self.NumberOfNodes
	local prismaticConstraint = self.PrismaticConstraint
	
	self.Moving = true
	
	sfx.Horn:Play()
	
	local reverse = self.CurrentStation == 2
	
	local defaultOrientation = self.DefaultOrientation
	
	local lastNode
	local tramAngle
	if reverse == true then
		lastNode = nodes[numOfNodes]
		tramAngle = CFrame.Angles(math.rad(defaultOrientation.X), math.rad(defaultOrientation.Y+180), math.rad(defaultOrientation.Z))
	else
		lastNode = nodes["1"]
		tramAngle = CFrame.Angles(math.rad(defaultOrientation.X), math.rad(defaultOrientation.Y), math.rad(defaultOrientation.Z))
	end
	
	task.wait(2)
	
	sfx.Start:Play()
	sfx.Run:Play()
	
	for i=2, numOfNodes do
		local nextNode
		if reverse == true then
			nextNode = nodes[(numOfNodes+1) - i]
		else
			nextNode = nodes[i]
		end
		
		prismaticConstraint.Attachment1:Destroy()
		
		local lookAtCF = CFrame.lookAt(nextNode.Position, lastNode.Position)
		lookAtCF = lookAtCF*tramAngle
		
		if tram.CFrame.LookVector:Dot(lookAtCF.LookVector) < 0.995 then
			-- Halt prismatic movement for rotation transition
			
			-- Hold position
			local bp = Instance.new("BodyPosition")
			bp.Position = tram.Position
			bp.MaxForce = Vector3.new(100000000000, 100000000000, 100000000000)
			bp.D = 4000
			bp.P = 1000000
			
			-- Rotate
			local bg = Instance.new("BodyGyro")
			bg.CFrame = lookAtCF
			bg.MaxTorque = Vector3.new(1000000, 1000000, 1000000)
			bg.P = 3000
			
			bp.Parent = tram
			bg.Parent = tram
			
			sfx.Servo.TimePosition = 0.5
			sfx.Servo:Play()
			
			repeat
				task.wait(0.0333)
			until tram.CFrame.LookVector:Dot(lookAtCF.LookVector) > 0.95
			
			task.wait(0.6)
			
			-- Resume regular movement
			bg:Destroy()
			bp:Destroy()
		end
		
		local attachment1 = Instance.new("Attachment")
		attachment1.Parent = nextNode
		attachment1.WorldCFrame = lookAtCF
		attachment1.Name = "TransitionalAttachment1"
		
		prismaticConstraint.Attachment1 = attachment1
		
		local nodeTimeout = 60
		
		local distanceFromGoal
		local totalDistanceToClear = (lastNode.Position - nextNode.Position).Magnitude
		
		repeat
			distanceFromGoal = (tram.Position - nextNode.Position).Magnitude
			
			local timeWaited = task.wait(0.0333)
			nodeTimeout = nodeTimeout - timeWaited
			
			local distanceFromStart = (tram.Position - lastNode.Position).Magnitude
			
			local goalBrake = distanceFromGoal/10
			local startBrake = distanceFromStart/10
			
			local speedScale = math.clamp(math.min(goalBrake, startBrake), 0, 1)
			
			local newSpeed = maxTramSpeed * (0.2 + (speedScale*0.8))
			
			prismaticConstraint.Speed = newSpeed
		until nodeTimeout <= 0 or distanceFromGoal < 0.5
		
		if i < numOfNodes and nodeTimeout > 0 then
			task.wait(.1)
		end
		
		tram.CFrame = attachment1.WorldCFrame
		lastNode = nextNode
	end
	
	if reverse then
		self.CurrentStation = 1
	else
		self.CurrentStation = 2
	end
	
	sfx.Run:Stop()
	sfx.Stop:Play() -- y'know, this would be pretty confusing without context
	
	self.Moving = false
end

function tram:CallTram(plr, button)
	if self.Moving == true then return end
	if button:FindFirstChild("Station") and button.Station.Value == self.CurrentStation then return end
	
	local char = plr.Character
	if char and char:FindFirstChild("HumanoidRootPart") and (char.HumanoidRootPart.Position - button.Position).Magnitude < 20 then
		self:MoveTram()
	end
end

for i,folder in pairs(workspace.Trams:GetChildren()) do
	tram.new(folder)
end