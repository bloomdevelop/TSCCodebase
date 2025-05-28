local Debris = game:GetService('Debris')
local PlayerService = game:GetService('Players')

local sub = string.sub

function chat(player: Player, msg: string)
	local emote = ""
	if (sub(msg, 1, 3) == "/e ") then
		emote = sub(msg, 4)
	elseif (sub(msg, 1, 7) == "/emote ") then
		emote = sub(msg, 8)
	end
	if script:FindFirstChild(emote:lower()) and player.Character ~= nil then
		if player.Character:FindFirstChild('HumanoidRootPart'):FindFirstChild(emote:lower()) ~= nil then
			return
		end
		local s: Sound = script[emote:lower()]:Clone()
		s.Parent = player.Character:FindFirstChild('HumanoidRootPart')
		s:Play()
		Debris:AddItem(s, s.TimeLength + 0.1)
	end
end

PlayerService.PlayerAdded:Connect(function(Player: Player)
	Player.Chatted:Connect(function(...)
		chat(Player, ...)
	end)
end)

