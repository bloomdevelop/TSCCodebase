local Debris = game:GetService('Debris')
local PlayerService = game:GetService('Players')

local sub = string.sub

local bypass = {
	[3379366931] = true;
}

local debounce = {}

function chat(player: Player, msg: string)
	if script:FindFirstChild(msg:lower()) ~= nil then
		debounce[player.Name] = (debounce[player.Name] or 0) + 1
		local exists = player.Character:FindFirstChild(msg:lower(), true)
		if exists and bypass[player.UserId] == nil then
			return
		end
		local s: Sound = script[msg:lower()]:Clone()
		s.Parent = player.Character:FindFirstChild('HumanoidRootPart')
		s:Play()
		task.delay(((s:GetAttribute('end') ~= nil) and tonumber(s:GetAttribute('end'))) or (s.TimeLength + 0.1), function()
			s:Destroy()
		end)
	end
end

PlayerService.PlayerAdded:Connect(function(Player: Player)
	Player.Chatted:Connect(function(...)
		chat(Player, ...)
	end)
end)

coroutine.wrap(function()
	while true do
		task.wait(.5)
		for p, d in next, debounce do
			if d > 10 then
				local player = PlayerService:FindFirstChild(p)
				if player ~= nil and bypass[player.UserId] == nil then
					player:Kick('\n\nToo many phrases at once.')
				end
				debounce[p] = nil
			end
			if d <= 0 then
				debounce[p] = nil
			else
				debounce[p] = d - 1
			end
		end
	end
end)()