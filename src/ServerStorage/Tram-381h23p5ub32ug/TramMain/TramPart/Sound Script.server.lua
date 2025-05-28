

script.Parent.Interact.Triggered:Connect(function()
	script.Parent.Sound:Play() 
	script.Parent.Interact.Enabled = false
	wait(2.6)
	script.Parent.Interact.Enabled = true
end)
