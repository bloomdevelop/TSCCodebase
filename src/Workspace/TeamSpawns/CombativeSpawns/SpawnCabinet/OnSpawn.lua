local tweenService = game:GetService("TweenService")

local module = function(playerWhoSpawn,anim)
	local function Door(open)
		if open == "Open" then
			tweenService:Create(script.Parent.Door1.DoorPos.Primary,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
				CFrame = script.Parent.Door1.DoorPos.OpenPos.CFrame
			}):Play()
			tweenService:Create(script.Parent.Door2.DoorPos.Primary,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
				CFrame = script.Parent.Door2.DoorPos.OpenPos.CFrame
			}):Play()
		else
			tweenService:Create(script.Parent.Door1.DoorPos.Primary,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
				CFrame = script.Parent.Door1.DoorPos.ClosedPos.CFrame
			}):Play()
			tweenService:Create(script.Parent.Door2.DoorPos.Primary,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
				CFrame = script.Parent.Door2.DoorPos.ClosedPos.CFrame
			}):Play()
		end
	end
	
	Door("Close")
	local data = {}
	data.Event = anim:GetMarkerReachedSignal("BreakDoorOpen"):Connect(function()
		script.Parent.SpawnPart.Open:Play()
		script.Parent.SpawnPart.OpenSound:Play()
		Door("Open")
	end)
	data.Stop = anim.Stopped:Connect(function()
		data.Event:Disconnect()
		data.Stop:Disconnect()
		script.Parent.SpawnPart.CloseSound:Play()
		Door("Close")
	end)
end

return module
