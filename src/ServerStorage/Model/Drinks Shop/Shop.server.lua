local db = false

local clickDetector = script.Parent.ClickDetector

function onClick(plr)
	if plr then
		if plr:DistanceFromCharacter(clickDetector.Parent.Position) <= clickDetector.MaxActivationDistance+1.1 then
			if not plr.PlayerGui:FindFirstChild("Buy_Cars") then
				local Gui = script.Parent.Buy_Cars:clone()
				Gui.Parent = plr.PlayerGui
			end
		end
	end
end

clickDetector.MouseClick:Connect(onClick)