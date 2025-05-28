local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Remote = ReplicatedStorage.Remotes.RadioEffect

Remote.OnClientEvent:Connect(function(t, n)
	local selected = ReplicatedStorage.SFX.Radio[t][t..tostring(n)]
	--print('Playing radio audio "'..selected.Name..'"')
	for _, p: Player in next, Players:GetPlayers() do
		if p.Character ~= nil and p.Character:FindFirstChild('Chatter') ~= nil and p.Character.Chatter:FindFirstChild('Handle') then
			local s: Sound = selected:Clone()
			s.Parent = p.Character.Chatter.Handle
			s:Play()
			s.Ended:Connect(function()
				s:Destroy()
			end)
		end
	end
end)