-- Services

local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- Modules

local Regional = require(ReplicatedStorage.Modules.RegionalDetect)

-- Objects

local Gates = {}

-- Functions

local insrt = table.insert

function getChildrenSize(t)
	if type(t) == 'table' then
		local i = 0
		for _, v in next, t do
			i += 1
		end
		return i
	else
		return nil
	end
end

function switchGate(gate, b)
	for _, v in next, gate.MotionSensor.Lasers:GetChildren() do
		v.emmiter.MotionBeam.Enabled = b
	end
	gate.MotionSensor.SensorModel.L1.bruh.DumbLightScriptIgnore.BrickColor = b and BrickColor.new ("Persimmon") or BrickColor.new ("Pastel yellow")
	gate.MotionSensor.SensorModel.L1.bruh.DumbLightScriptIgnore.DumbLightScriptIgnore.BrickColor = b and BrickColor.new ("Persimmon") or BrickColor.new ("Pastel yellow")
	gate.MotionSensor.SensorModel.L2.bruh.DumbLightScriptIgnore.BrickColor = b and BrickColor.new ("Persimmon") or BrickColor.new ("Pastel yellow")
	gate.MotionSensor.SensorModel.L2.bruh.DumbLightScriptIgnore.DumbLightScriptIgnore.BrickColor = b and BrickColor.new ("Persimmon") or BrickColor.new ("Pastel yellow")
	gate.MotionSensor.LaserHitbox.CanTouch = b
	gate.MotionSensor.SensorModel.Union.DumbLightScriptIgnore.Enabled = b
	if b then
		gate.MotionSensor.LaserHitbox.Sound:Play()
	else
		gate.MotionSensor.LaserHitbox.Sound:Stop()
	end
end

function enabled(gate)
	local enable = gate:GetAttribute('Enabled') or gate:GetAttribute('ForceEnable')
	local TeamHitbox = gate.MotionSensor.TeamDetect
	if enable then
		TeamHitbox.Alarm:Play()
	end
	switchGate(gate, enable)
end

function death(part)
	if part.Parent:IsA('Model') and part.Parent:FindFirstChild('Humanoid') then
		local model: Model = part.Parent
		if math.huge > model.Humanoid.Health then
			model.Humanoid.Health = 0
			local s = script.Death:Clone()
			s.Parent = part
			s:Play()
			for _, i: Instance in next, model:GetDescendants() do
				if i:IsA('BasePart') or i:IsA('Decal') or i:IsA('Texture') or i:IsA('ImageLabel') then
					game.TweenService:Create(i, TweenInfo.new(.4), {
						Transparency = 1
					}):Play()
				end
			end
		end
	end
end

function registerGates()
	for _, f: Instance | Folder in next, script.Parent:GetChildren() do
		if f:IsA('Folder') then
			for _, gate in next, f:GetChildren() do
				local mod = gate:FindFirstChild('Permissions')
				if mod ~= nil and gate.Name == "LaserGate" then
					gate:SetAttribute('Enabled', false)
					gate:SetAttribute('ForceEnable', false)
					gate:SetAttribute('Registered', false)
					gate:GetAttributeChangedSignal("Enabled"):Connect(function() enabled(gate) end)
					gate:GetAttributeChangedSignal("ForceEnable"):Connect(function() enabled(gate) end)
					local DeathHitbox = gate.MotionSensor.LaserHitbox
					DeathHitbox.Touched:Connect(death)
					local go = {}
					go.Object = gate
					go.Permissions = require(mod)
					insrt(Gates, go)
				end
			end
		end
	end
end

local whitelisted = {
	["Site Engineer"] = true,
	["Off Duty"] = true,
	["Facility Personnel"] = true
}

function start()
	for _, go in next, Gates do
		local Region = Regional:new(go.Object.MotionSensor.TeamDetect)
		Region.Event:Connect(function(touching)
			local size = getChildrenSize(touching)
			if size > 0 then
				local enable = false
				for _, v in next, touching do
					if v.Player ~= nil then
						if whitelisted[v.Player.Team.Name] then
							enable = false
						elseif go.Permissions.Teams[v.Player.Team.Name] == nil then
							enable = true
						elseif go.Permissions.Teams[v.Player.Team.Name] == false then
							enable = true
						end
					elseif v.Character ~= nil then
						if go.Permissions.HumanoidNames[v.Character.Name] == nil then
							enable = true
						elseif go.Permissions.HumanoidNames[v.Character.Name] == false then
							enable = true
						end
					end
				end
				if enable then
					go.Object:SetAttribute('Enabled', true)
					go.Object.MotionSensor.TeamDetect.Alarm:Play()
				end
			else
				go.Object:SetAttribute('Enabled', false)
			end
		end)
		Region:Initialize()
		go.Object:SetAttribute('Registered', true)
	end
end

function stop()
	warn('Not implemented yet - LaserGateHandler')
end

registerGates()
start()
