local Closed = script.Parent.Parent.Closed

Closed.Changed:Connect(function(value) --fires everytime the value is changed, and gives us what the current value is
	if value then --if it’s true
		script.Parent.OpenSound:Play()
		script.Parent.KeyCard:Play()
	else --if it’s false
		script.Parent.OpenSound:Play()
		script.Parent.KeyCard:Play()
	end
end)