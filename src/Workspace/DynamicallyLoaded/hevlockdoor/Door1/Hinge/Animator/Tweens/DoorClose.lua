local hinge = script.Parent.Parent.Parent

return {
	["Hinge"] = {
		CFrame = {
			InitialValue = hinge.CFrame * CFrame.Angles(0,math.pi/2,0),
			Keyframes = {
				{
					Value = hinge.CFrame,
					EasingStyle = Enum.EasingStyle.Exponential,
					Time = 1,
					EasingDirection = Enum.EasingDirection.Out,
				},
			},
		},
	},
}
