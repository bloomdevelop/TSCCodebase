local Speed = script.Parent.Parent.Parent.Parent.Parent.ControlPanel.Stats.Speed
local Limit = script.Parent.Parent.Parent.Parent.Parent.ControlPanel.Stats.Limit
----------------------------------------------------

local textbox = script.Parent.Text
local maxVal = script.Parent.MaxVal

Speed:GetPropertyChangedSignal("Value"):Connect(function()
	textbox.Text = Speed.Value
end)

Limit:GetPropertyChangedSignal("Value"):Connect(function()
	maxVal.Visible = Limit.Value
end)