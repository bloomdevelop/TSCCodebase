local TweenService = game:GetService("TweenService")
local WS = game:GetService("Workspace")

function elevatorHandler(elevator)
	local speed = elevator:GetAttribute("ElevatorSpeed")
	local DoorOpenTime = elevator:GetAttribute("DoorOpenTime")

	local nodes = elevator.Nodes
	local elevatorMain = elevator.ElevatorMain
	local F1 = elevator.Floor1
	local F2 = elevator.Floor2
	local F1B = elevatorMain.Buttons.Floor1Button.ClickDetector
	local F2B = elevatorMain.Buttons.Floor2Button.ClickDetector
	local F1CB = elevator.Floor1.CallButton.ClickDetector
	local F2CB = elevator.Floor2.CallButton.ClickDetector
	local special = elevatorMain.Special
	local sfx = elevatorMain.SFX

	local weldFolder = Instance.new("Folder")
	weldFolder.Name = "PlrWelds"
	weldFolder.Parent = elevator

	local numOfNodes = 0
	for _,v in pairs(nodes:GetChildren()) do
		numOfNodes += 1
	end

	local db = false
	local db1 = false
	local db2 = false
	local db3 = false
	local db4 = false
	local db5 = false

	local function weldPlayers()
		local region = Region3.new(Vector3.new(special.Position.X-7.5,special.Position.Y-6,special.Position.Z-7.5),Vector3.new(special.Position.X+7.5,special.Position.Y+6,special.Position.Z+7.5))
		local partsInRegion = game.Workspace:FindPartsInRegion3WithIgnoreList(region,{elevatorMain},1000)
		for _,v in pairs(partsInRegion) do
			if v.Parent:FindFirstChild("Humanoid") and v.Name == "HumanoidRootPart" then
				local w = Instance.new("Weld")
				w.C0 = v.CFrame:Inverse()*elevatorMain.CFrame
				w.Part0 = v
				w.Part1 = elevatorMain
				w.Parent = weldFolder
			end
		end
	end

	local function unweldPlayers()
		for _,v in pairs(weldFolder:GetChildren()) do
			v:Destroy()
		end
	end

	local function EDoors(open)
		local tween1
		local tween2
		local info = TweenInfo.new(
			2,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.InOut,
			0,
			false,
			0
		)
		if open == true then
			db3 = open
			tween1 = TweenService:Create(elevatorMain.Doors.Left.Door,info,{CFrame = elevatorMain.Doors.Left.Open.CFrame})
			tween2 = TweenService:Create(elevatorMain.Doors.Right.Door,info,{CFrame = elevatorMain.Doors.Right.Open.CFrame})
			elevatorMain.Doors.Left.Door.Anchored = true
			elevatorMain.Doors.Right.Door.Anchored = true
		elseif open == false then
			tween1 = TweenService:Create(elevatorMain.Doors.Left.Door,info,{CFrame = elevatorMain.Doors.Left.Closed.CFrame})
			tween2 = TweenService:Create(elevatorMain.Doors.Right.Door,info,{CFrame = elevatorMain.Doors.Right.Closed.CFrame})
		end
		tween1:Play()
		tween2:Play()
		tween2.Completed:wait()
		if open == false then
			db3 = open
			elevatorMain.Doors.Left.Door.Anchored = false
			elevatorMain.Doors.Right.Door.Anchored = false
		end
	end

	local function F1Doors(open)
		local tween1
		local tween2
		local info = TweenInfo.new(
			2,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.InOut,
			0,
			false,
			0
		)
		if open == true then
			db4 = open
			tween1 = TweenService:Create(F1.Left.Door,info,{CFrame = F1.Left.Open.CFrame})
			tween2 = TweenService:Create(F1.Right.Door,info,{CFrame = F1.Right.Open.CFrame})
		elseif open == false then
			db4 = open
			tween1 = TweenService:Create(F1.Left.Door,info,{CFrame = F1.Left.Closed.CFrame})
			tween2 = TweenService:Create(F1.Right.Door,info,{CFrame = F1.Right.Closed.CFrame})
		end
		tween1:Play()
		tween2:Play()
	end

	local function F2Doors(open)
		local tween1
		local tween2
		local info = TweenInfo.new(
			2,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.InOut,
			0,
			false,
			0
		)
		if open == true then
			db5 = open
			tween1 = TweenService:Create(F2.Left.Door,info,{CFrame = F2.Left.Open.CFrame})
			tween2 = TweenService:Create(F2.Right.Door,info,{CFrame = F2.Right.Open.CFrame})
		elseif open == false then
			db5 = open
			tween1 = TweenService:Create(F2.Left.Door,info,{CFrame = F2.Left.Closed.CFrame})
			tween2 = TweenService:Create(F2.Right.Door,info,{CFrame = F2.Right.Closed.CFrame})
		end
		tween1:Play()
		tween2:Play()
	end
	
	local function OnClick()
		if (elevatorMain.Position - nodes["1"].Position).Magnitude < 0.1 then
			weldPlayers()
			elevatorMain.Floor.Start:Play()
			elevatorMain.Floor.Run:Play()
			for count = 2,numOfNodes,1 do
				local ditance = (elevatorMain.Position - nodes[count].Position).Magnitude
				local info
				if count == 2 then
					info = TweenInfo.new(
						ditance/speed+1,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.In,
						0,
						false,
						0
					)
				elseif count == numOfNodes then
					info = TweenInfo.new(
						ditance/speed+1,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.Out,
						0,
						false,
						0
					)
				else
					info = TweenInfo.new(
						ditance/speed,
						Enum.EasingStyle.Linear,
						Enum.EasingDirection.InOut,
						0,
						false,
						0
					)
				end
				local tween = TweenService:Create(elevatorMain,info,{CFrame = nodes[count].CFrame})
				tween:Play()
				tween.Completed:wait()
			end
			unweldPlayers()
			F2Doors(true)
			elevatorMain.Floor.Run:Stop()
			elevatorMain.Floor.Stop:Play()
			sfx.Chime:Play()
			F2.CallButton.Material = Enum.Material.SmoothPlastic
			elevatorMain.Buttons.Floor2Button.Material = Enum.Material.Metal
			EDoors(true)
			wait(DoorOpenTime)
			F2Doors(false)
			EDoors(false)
		elseif (elevatorMain.Position - nodes[numOfNodes].Position).Magnitude < 0.1 then
			weldPlayers()
			elevatorMain.Floor.Start:Play()
			elevatorMain.Floor.Run:Play()
			for count = numOfNodes-1,1,-1 do
				local ditance = (elevatorMain.Position - nodes[count].Position).Magnitude
				local info
				if count == numOfNodes-1 then
					info = TweenInfo.new(
						ditance/speed+1,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.In,
						0,
						false,
						0
					)
				elseif count == 1 then
					info = TweenInfo.new(
						ditance/speed+1,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.Out,
						0,
						false,
						0
					)
				else
					info = TweenInfo.new(
						ditance/speed,
						Enum.EasingStyle.Linear,
						Enum.EasingDirection.InOut,
						0,
						false,
						0
					)
				end
				local tween = TweenService:Create(elevatorMain,info,{CFrame = nodes[count].CFrame})
				tween:Play()
				tween.Completed:wait()
			end
			unweldPlayers()
			F1Doors(true)
			elevatorMain.Floor.Run:Stop()
			elevatorMain.Floor.Stop:Play()
			sfx.Chime:Play()
			F1.CallButton.Material = Enum.Material.SmoothPlastic
			elevatorMain.Buttons.Floor1Button.Material = Enum.Material.Metal
			EDoors(true)
			wait(DoorOpenTime)
			F1Doors(false)
			EDoors(false)
		end
	end
	
	local function F1Go()
		if (elevatorMain.Position - nodes[numOfNodes].Position).Magnitude < 0.1 then
			if db == false and db5 == false and db3 == false then
				db = true
				OnClick()
				db = false
			end
		end
	end

	local function F2Go()
		if (elevatorMain.Position - nodes["1"].Position).Magnitude < 0.1 then
			if db == false and db4 == false and db3 == false then
				db = true
				OnClick()
				db = false
			end
		end
	end

	local function F1Call()
		if db1 == false then
			db1 = true
			if (elevatorMain.Position - nodes["1"].Position).Magnitude > 0.1 then
				elevatorMain.Buttons.Floor1Button.Ding:Play()
				F1.CallButton.Material = Enum.Material.Neon
				elevatorMain.Buttons.Floor1Button.Material = Enum.Material.Neon
				repeat
					wait(0.5)
				until db == false
				F1Go()
			elseif (elevatorMain.Position - nodes["1"].Position).Magnitude < 0.1 then
				F1.CallButton.Ding:Play()
				F1Doors(true)
				EDoors(true)
				wait(DoorOpenTime)
				F1Doors(false)
				EDoors(false)
			end
			db1 = false
		end
	end

	local function F2Call()
		if db2 == false then
			db2 = true
			if (elevatorMain.Position - nodes[numOfNodes].Position).Magnitude > 0.1 then
				elevatorMain.Buttons.Floor2Button.Ding:Play()
				F2.CallButton.Material = Enum.Material.Neon
				elevatorMain.Buttons.Floor2Button.Material = Enum.Material.Neon
				repeat
					wait(0.5)
				until db == false and db3 == false
				F2Go()
			elseif (elevatorMain.Position - nodes[numOfNodes].Position).Magnitude < 0.1 then
				F2.CallButton.Ding:Play()
				F2Doors(true)
				EDoors(true)
				wait(DoorOpenTime)
				F2Doors(false)
				EDoors(false)
			end
			db2 = false
		end
	end

	F1B.MouseClick:Connect(F1Call)
	F2B.MouseClick:Connect(F2Call)
	F1CB.MouseClick:Connect(F1Call)
	F2CB.MouseClick:Connect(F2Call)
end

for _,v in pairs(WS["Elevators-PzqFze2XHqKfZgYu"]:GetChildren()) do
	if v.Name == "Elevator" then
		elevatorHandler(v)
	end
end