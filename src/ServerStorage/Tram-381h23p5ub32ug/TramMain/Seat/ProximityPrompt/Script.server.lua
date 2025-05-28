local PP = script.Parent
local seat = script.Parent.Parent

PP.Triggered:Connect(function(player)
	seat:Sit(player.Character.Humanoid)
end)