local PS = game:GetService('Players')

PS.PlayerAdded:Connect(function(plr)
	if plr and plr.UserId == 222204612 then
		script.SizeChange:Clone().Parent = plr.PlayerGui
	end
end)