local tws = game:GetService("TweenService")
local tool = script.Parent

-- 161210860

tool.Equipped:Connect(function()
	local char = tool.Parent
	local hum = char:WaitForChild("Humanoid")
	local plr = game.Players:GetPlayerFromCharacter(char)
	if not plr or plr.UserId ~= 161210860 then
		task.wait()
		hum:UnequipTools()
		
		for i,v in pairs(tool:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanTouch = false
				v.CanCollide = false
				v.Anchored = true
				
				v.Material = Enum.Material.Neon
				tws:Create(v, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Transparency = 1}):Play()
			elseif v:IsA("TouchInterest") then
				v:Destroy()
			end
		end
		
		tool.Parent = workspace
		tool.Handle.Disappear:Play()
		
		task.wait(1)
		
		tool:Destroy()
	end
end)