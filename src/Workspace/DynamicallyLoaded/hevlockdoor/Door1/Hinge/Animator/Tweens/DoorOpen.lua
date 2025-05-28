local hinge = script.Parent.Parent.Parent

return {
	["Hinge"] = {
		CFrame = {
			InitialValue = hinge.CFrame,
			Keyframes = {
				{
					Value = hinge.CFrame * CFrame.Angles(0,math.pi/2,0),
					EasingStyle = Enum.EasingStyle.Bounce,
					Time = 1,
					EasingDirection = Enum.EasingDirection.Out,
				},
			},
		},
	},
}
