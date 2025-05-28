script.Parent.Parent.Stats.Speed:GetPropertyChangedSignal("Value"):Connect(function()
	script.Parent.SurfaceGui.Frame.TextLabel.Text = script.Parent.Parent.Stats.Speed.Value
end)

