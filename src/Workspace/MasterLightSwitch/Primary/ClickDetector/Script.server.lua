function Cooldown()
	script.Parent.MaxActivationDistance = 0
	wait(3)
	script.Parent.MaxActivationDistance = 5
end
script.Parent.MouseClick:Connect(Cooldown)