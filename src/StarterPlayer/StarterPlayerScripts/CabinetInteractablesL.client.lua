-- // Steven_Scripts, 2022

local rst = game:GetService("ReplicatedStorage")
local tws = game:GetService("TweenService")

local remotesFolder = rst.Remotes

local function onCabinetStateChanged(cabinet : Model)
	if cabinet.PrimaryPart == nil then
		-- Door isn't loaded in, don't worry about it
		return
	end

	local closed = cabinet.Closed.Value
	if closed then
		local door1 = cabinet.Door1

		local tween = tws:Create(door1.DoorPos.Primary,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{CFrame = door1.DoorPos.ClosedPos.CFrame})
		tween:Play()
		game.Debris:AddItem(tween, tween.TweenInfo.Time+1)

		local door2 = cabinet:FindFirstChild("Door2")
		if door2 ~= nil then
			local tween = tws:Create(door2.DoorPos.Primary,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{CFrame = door2.DoorPos.ClosedPos.CFrame})
			tween:Play()
			game.Debris:AddItem(tween, tween.TweenInfo.Time+1)
		end
	else
		local door1 = cabinet.Door1

		local tween = tws:Create(door1.DoorPos.Primary,TweenInfo.new(0.4,Enum.EasingStyle.Back),{CFrame = door1.DoorPos.OpenPos.CFrame})
		tween:Play()
		game.Debris:AddItem(tween, tween.TweenInfo.Time+1)

		local door2 = cabinet:FindFirstChild("Door2")
		if door2 ~= nil then
			local tween = tws:Create(door2.DoorPos.Primary,TweenInfo.new(0.4,Enum.EasingStyle.Back),{CFrame = door2.DoorPos.OpenPos.CFrame})
			tween:Play()
			game.Debris:AddItem(tween, tween.TweenInfo.Time+1)
		end
	end
end

remotesFolder.Cabinets.CabinetStateChanged.OnClientEvent:Connect(onCabinetStateChanged)