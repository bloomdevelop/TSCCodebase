--// Template used for future door ref. If in doubt contact Exos_XG
--// Left inside folder for convenience. Feel free to delete it.
return function(p,btn)
	local Door = btn.Parent.Trigger.o
	Door.Sound:Play()
	local carriage = btn.Parent
	--
	local animator = require(carriage.Animator)
	local elevatorIsUp   = false
	local elevatorIsDown = true
	local db             = false
	local db1            = false
	local debounce       = false
	local doorOpen       = false
	local elevatorMoving = false
	local DownPosition = carriage:findFirstChild('DownPosition')
	if DownPosition == nil then
		DownPosition = Instance.new("Vector3Value",carriage)
		DownPosition.Name = 'DownPosition'
		DownPosition.Value = carriage.Union11.Position
	end
	local UpPosition = carriage:findFirstChild('UpPosition')
	if UpPosition == nil then
		UpPosition = Instance.new("Vector3Value",carriage)
		UpPosition.Name = 'UpPosition'
		UpPosition.Value = carriage.Union11.Position+Vector3.new(0,40.7999992,0)
	end
	local Down = carriage:findFirstChild('Down')
	if Down == nil then
		Down = Instance.new("BoolValue",carriage)
		Down.Name = 'Down'
		Down.Value = true
	end
	
	local function LOCKTOPFLOOR()	
		local f3 = carriage.Door3.PrimaryPart.OriginCF.Value
		local f4 = carriage.Door4.PrimaryPart.OriginCF.Value
		for i = 0,1,0.03 do
			local cfm = carriage.Door3.PrimaryPart.CFrame:lerp(f3,i)
			local cfm2 = carriage.Door4.PrimaryPart.CFrame:lerp(f4,i)
			carriage.Door3:SetPrimaryPartCFrame(cfm)
			carriage.Door4:SetPrimaryPartCFrame(cfm2)
			wait()
		end	
	end
	
	local function UNLOCKTOPFLOOR()
		if db == false then
			db = true
			--DOOR_OPEN:play()
			local f = carriage.Door3.PrimaryPart.OriginCF.Value*CFrame.Angles(0,math.rad(-90),0)
			local f2 = carriage.Door4.PrimaryPart.OriginCF.Value*CFrame.Angles(0,-math.rad(-90),0)
			for i = 0,1,0.03 do
				local cfm = carriage.Door3.PrimaryPart.CFrame:lerp(f,i)
				local cfm2 = carriage.Door4.PrimaryPart.CFrame:lerp(f2,i)
				carriage.Door3:SetPrimaryPartCFrame(cfm)
				carriage.Door4:SetPrimaryPartCFrame(cfm2)
				wait()
			end
		end 
		db = false 
	end
	
	local function LOCKBOTTOMFLOOR()	
		local f3 = carriage.Door1.PrimaryPart.OriginCF.Value
		local f4 = carriage.Door2.PrimaryPart.OriginCF.Value
		for i = 0,1,0.03 do
			local cfm = carriage.Door1.PrimaryPart.CFrame:lerp(f3,i)
			local cfm2 = carriage.Door2.PrimaryPart.CFrame:lerp(f4,i)
			carriage.Door1:SetPrimaryPartCFrame(cfm)
			carriage.Door2:SetPrimaryPartCFrame(cfm2)
			wait()
		end	
	end
	
	local function UNLOCKBOTTOMFLOOR()
		if db1 == false then
			db1 = true
			local f = carriage.Door1.PrimaryPart.OriginCF.Value*CFrame.Angles(0,math.rad(-90),0)
			local f2 = carriage.Door2.PrimaryPart.OriginCF.Value*CFrame.Angles(0,-math.rad(-90),0)
			for i = 0,1,0.03 do
				local cfm = carriage.Door1.PrimaryPart.CFrame:lerp(f,i)
				local cfm2 = carriage.Door2.PrimaryPart.CFrame:lerp(f2,i)
				carriage.Door1:SetPrimaryPartCFrame(cfm)
				carriage.Door2:SetPrimaryPartCFrame(cfm2)
				wait()
			end
		end 
		db1 = false
	end
	
	if not elevatorMoving then
		if Down.Value == false then
			Down.Value = true
			script.Parent.Parent.Communicator:Fire("AddDB",carriage)
			local info = TweenInfo.new(10,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
			local Tween = game:GetService("TweenService"):Create(carriage.Union11,info,{Position = DownPosition.Value})
			Tween:Play()
			carriage.Union11.elevatorsound:Play()
			elevatorMoving = true
			LOCKTOPFLOOR()
			Tween.Completed:Wait()
			UNLOCKBOTTOMFLOOR()
			elevatorMoving = false			
		end
		script.Parent.Parent.Communicator:Fire("RemoveDB",carriage,1)
	end
end