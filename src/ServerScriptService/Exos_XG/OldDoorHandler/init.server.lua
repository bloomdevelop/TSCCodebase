--// © Exos_XG 2020
--// Initialisation
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild('GameRemotes')
local DoorConfigs = script.DoorConfigs
local ClearanceData = require(script.DoorClearance)
local DBList = {}
local DBRemovalQueue = {}

--// Clearance Verification - Checking Tools
function CertifyTool(tool,Clearance)
	for i,v in pairs(ClearanceData.ToolClearance) do
		if i == tool.Name then
			if (typeof(v) == "number" and v >= Clearance) or (typeof(v) == "string" and v == "All") then
				return true
			end
		end
	end
	return false
end

--// Clearance Verification
function CertifyPlayer(plr,Clearance)
	for i,v in pairs(ClearanceData.UserOverride) do
		if plr.UserId == v then
			--print('Player is in override')
			return true
		end
	end
	local Tool = plr.Character:findFirstChildWhichIsA('Tool')
	if Tool ~= nil and CertifyTool(Tool,Clearance) == true then
		--print('Player equipped valid tool')
		return true
	end
	for i,v in pairs(plr.Backpack:GetChildren()) do
		if CertifyTool(v,Clearance) == true then
			--print('Player carrying valid tool')
			return true
		end
	end
	--print('Player not authorised')
	return false
end

--// Client-Server Interaction Requests
function HandleDoor(plr,Door)
	if Door.Name == 'Trigger2' or Door.Name == 'KeycardReader2' then
		Door = Door.Parent
	end
	if plr ~= nil and plr.Character == nil then
		return false
	end
	if DBList[Door.Parent] ~= nil and Door.Name == 'ElevatorUse' then
		return false
	end
	if DBList[Door.Parent.Parent] ~= nil and Door.Name == 'o' then
		return false
	end
	if DBList[Door] ~= nil then
		return false
	end
	for i,v in pairs(DBList) do
		if i:IsAncestorOf(Door) and Door.Name == 'Trigger' or Door.Name == 'Trigger2' then
			return false
		end
	end
	local Clearance = Door:findFirstChild('clr',true) --// 'clr' can be added to any door in the game and this will check the player's clearance.
	if plr ~= nil and (Clearance ~= nil and CertifyPlayer(plr,Clearance.Value) == false) then
		DBList[Door] = true
		if DBRemovalQueue[Door] == nil or DBRemovalQueue[Door] < 1 then
			DBRemovalQueue[Door] = 1
		end
		local LockedSFX = Door:findFirstChild('LOCKED',true)
		local DeniedSFX = Door:findFirstChild('deny',true)
		local termTex = Door:findFirstChild("terminaltext",true)
		if termTex then
			termTex.Text = "ACCESS_DENIED..."
			local NoAccessSFX = Door:findFirstChild("AccessDenied",true)
			if NoAccessSFX then
				NoAccessSFX:Play()
			end
			return false
		end
		if DeniedSFX then
			DeniedSFX:Play()
		elseif LockedSFX then
			LockedSFX:Play()
		end
		return false
	end
	if (Door:findFirstChild('Open') and Door:findFirstChild('Locked') and Door.Open.Value == false and Door.Locked.Value == true) then
		DBList[Door] = true
		if DBRemovalQueue[Door] == nil or DBRemovalQueue[Door] < 1 then
			DBRemovalQueue[Door] = 1
		end
		local LockedSFX = Door:findFirstChild('LOCKED',true)
		if LockedSFX then
			LockedSFX:Play()
		end
		return false
	end
	if DoorConfigs:FindFirstChild(Door.Name) ~= nil then
		require(DoorConfigs[Door.Name])(plr,Door)
	elseif Door.Name == 'o' then
		require(DoorConfigs["RequestElevator"])(plr,Door.Parent)
	end
	return true
end

Remotes.DoorListener.OnServerEvent:Connect(function(plr,Door)
	HandleDoor(plr,Door)
end)

Remotes.ServerDoorFunc.OnInvoke = function(...)
	local Args = {...}
	if Args[1] == "UseDoor" then
		return HandleDoor(nil,Args[2])
	elseif Args[1] == "GetDoorState" then
		local Open = Args[2]:findFirstChild('Open')
		if Open == nil then
			return nil
		else
			return Open.Value
		end
	end
end

--// Module-To-Script Communication
script.Communicator.Event:Connect(function(...)
	local Args = {...}
	if Args[1] == "AddDB" and Args[2] ~= nil then
		DBList[Args[2]] = true
	elseif Args[1] == "RemoveDB" and Args[2] ~= nil and Args[3] ~= nil then
		DBRemovalQueue[Args[2]] = Args[3]
	elseif Args[1] == "ScheduleDB" and Args[2] ~= nil and Args[3] ~= nil then
		DBList[Args[2]] = true
		DBRemovalQueue[Args[2]] = Args[3]
	end
end)

--// Debounce Removal Scheduler
game:GetService("RunService").Heartbeat:Connect(function(delta)
	for i,v in pairs(DBRemovalQueue) do
		DBRemovalQueue[i] = DBRemovalQueue[i] - delta
		if DBRemovalQueue[i] <= 0 then
			if DBList[i] ~= nil then
				DBList[i] = nil
			end
			local termTex = i:findFirstChild("terminaltext",true)
			if termTex then
				termTex.Text = "INSERT_CARD..."
			end
			DBRemovalQueue[i] = nil
			i = nil
			v = nil
		end
	end
end)

--// Initialising Elevator Carriages
for i,v in pairs(workspace.Elevators:GetChildren()) do
	if v.Name == 'Carriage' then
		if v:findFirstChild('Door1') then
			local Origin = Instance.new('CFrameValue',v.Door1.PrimaryPart)
			Origin.Value = v.Door1.PrimaryPart.CFrame
			Origin.Name = 'OriginCF'
			v.Door1:SetPrimaryPartCFrame(v.Door1.PrimaryPart.CFrame*CFrame.Angles(0,math.rad(-90),0))
		end
		if v:findFirstChild('Door2') then
			local Origin = Instance.new('CFrameValue',v.Door2.PrimaryPart)
			Origin.Value = v.Door2.PrimaryPart.CFrame
			Origin.Name = 'OriginCF'
			v.Door2:SetPrimaryPartCFrame(v.Door2.PrimaryPart.CFrame*CFrame.Angles(0,math.rad(90),0))
		end
		if v:findFirstChild('Door3') then
			local Origin = Instance.new('CFrameValue',v.Door3.PrimaryPart)
			Origin.Value = v.Door3.PrimaryPart.CFrame
			Origin.Name = 'OriginCF'
		end
		if v:findFirstChild('Door4') then
			local Origin = Instance.new('CFrameValue',v.Door4.PrimaryPart)
			Origin.Value = v.Door4.PrimaryPart.CFrame
			Origin.Name = 'OriginCF'
		end
	end
	local o = v:findFirstChild('o',true)
	if o ~= nil then
		game:GetService("CollectionService"):AddTag(o,"alldoors")
	end
end

--// Trigger & Terminal Screen Initialisation
for i,v in pairs(workspace.Doors:GetChildren()) do
	local Trigger = v:findFirstChild('Trigger',true)
	if Trigger and v:findFirstChild('clr') then
		v.clr:Clone().Parent = Trigger
	end
	local termtex = v:findFirstChild("terminaltext",true)
	if termtex then
		termtex.Text = "INSERT_CARD..."
	end
	if v:findFirstChild('Open') == nil then
		local Open = Instance.new("BoolValue",v)
		Open.Name = 'Open'
	end
end
