script.Parent.Main.Position = UDim2.new(1, 500, 1, -20)
script.Parent.Enabled = true
script.Parent.Main:TweenPosition(UDim2.new(1, -20, 1, -20), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 1, true)
script.Parent.Notification:Play()
task.wait(5)
script.Parent.Main:TweenPosition(UDim2.new(1, 500, 1, -20), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 1, true)
task.wait(1)
script.Parent:Destroy()
