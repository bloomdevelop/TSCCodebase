local player = script.Parent.Parent.Parent.Parent.Parent


function close()
	script.Parent.Selected = true
	wait (0.1)
	script.Parent.Selected = false
	local cash = player.leaderstats.Cash
	if cash.Value >= 10 then
		cash.Value = cash.Value - 10
		local model = game.ServerStorage.Tools.Fanta:Clone()
		model.Parent = player.Backpack
		model.Deposit:Play()
		script.Parent.Parent.Parent:Destroy()
	else
		script.Parent.Text = "Not Enough Money!"
		wait(0.5)
		script.Parent.Text = "Buy"
	end
end




script.Parent.MouseButton1Click:connect(close)

