local ReplicatedStorage = game:GetService('ReplicatedStorage')

for _, i: Instance in next, script.Parent:GetChildren() do
	if i:IsA('BasePart') then
		if i:FindFirstChild('ClickDetector') then
			i.ClickDetector.MouseClick:Connect(function(player: Player)
				if player.Character ~= nil and player.Character:FindFirstChild('Mask') == nil then
					local m = ReplicatedStorage.NumerousReplication.Masks[tostring(i.ClickDetector.Value.Value)]:Clone()
					m.Name = "Mask"
					m.Parent = player.Character
				end
			end)
		end
	end
end