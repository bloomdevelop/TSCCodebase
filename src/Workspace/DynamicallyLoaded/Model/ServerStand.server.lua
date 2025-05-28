if not game:GetService('RunService'):IsStudio() then	
	task.wait(0.1)
	script.Parent:Destroy()
	task.wait(0.1)
end

local Parent = script.Parent
local Click = Parent.Stand.Button.ClickDetector
local on = false
local debounce = true

Click.MouseClick:Connect(function(player: Player)
	debounce = true
	Click.MaxActivationDistance = 0
	if on then
		for _, p: Instance in next, Parent.Surfaces:GetDescendants() do
			if p:IsA('BasePart') and p.Name ~= "Under" then
				game:GetService('TweenService'):Create(p, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Position = p.Position + Vector3.new(0, -4, 0),
					Transparency = p:GetAttribute('DefaultTransparency') or 0
				}):Play()
			end
		end
	else
		for _, p in next, Parent.Surfaces:GetDescendants() do
			if p:IsA('BasePart') and p.Name ~= "Under" then
				game:GetService('TweenService'):Create(p, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Position = p.Position + Vector3.new(0, 4, 0),
					Transparency = 0.8
				}):Play()
			end
		end
	end
	on = not on
	task.wait(1)
	Click.MaxActivationDistance = 32
	debounce = false
	
end)