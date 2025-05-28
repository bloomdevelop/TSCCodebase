
local Players = game:GetService('Players')

function characterAdded(character)
	local Head: BasePart? = character:FindFirstChild('Head')
	if Head ~= nil then
		Head.CanCollide = false
	end
end

function playerAdded(player: Player)
	player.CharacterAdded:Connect(characterAdded)
	if player.Character then
		characterAdded(player.Character)
	end
end

Players.PlayerAdded:Connect(playerAdded)

for _, player: Player in next, Players:GetPlayers() do
	playerAdded(player)
end