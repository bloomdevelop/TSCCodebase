
local ChatService = game:GetService('Chat')

local showPlayerName = true

local Cooldowns = {}
local Radios = game:GetService('Workspace').Radios:GetChildren()

local RANGE = 2
local MAX_CHATS = 3
local COOLDOWN = 5

return {
	Chatted = function(player: Player, msg: string)
		if Cooldowns[player] == nil then
			Cooldowns[player] = MAX_CHATS
		end
		local selected_radio
		for i = #Radios, 1, -1 do
			if Radios[i]:IsA('Model') and Radios[i].PrimaryPart ~= nil and (Radios[i].PrimaryPart.Position - player.Character.PrimaryPart.Position).Magnitude <= RANGE and Radios[i]:FindFirstChild('ReceivingOnly') == nil then
				selected_radio = Radios[i]
				break
			end
		end
		if selected_radio then
			if Cooldowns[player] == 0 then
				local s = script.Denied:Clone()
				s.Parent = selected_radio.PrimaryPart
				s:Play()
				task.delay(s.TimeLength, function()
					s:Destroy()
				end)
				local pain = selected_radio:GetDescendants()
				for p = #pain, 1, -1 do
					if pain[p]:IsA('BasePart') and pain[p].Material == Enum.Material.Neon then
						pain[p].BrickColor = BrickColor.new("Persimmon")
					end
				end
				task.wait(0.5)
				for p = #pain, 1, -1 do
					if pain[p]:IsA('BasePart') and pain[p].Material == Enum.Material.Neon then
						pain[p].BrickColor = BrickColor.new("Ghost grey")
					end
				end
			else
				for p = #Radios, 1, -1 do
					local s = script.Beep:Clone()
					s.Parent = Radios[p].PrimaryPart
					s:Play()
					task.delay(s.TimeLength, function()
						s:Destroy()
					end)
					Radios[p].PrimaryPart.Name = "RadioPart"
					if Radios[p]:IsA('Model') and Radios[p].PrimaryPart ~= selected_radio then
						local filteredMsg = ChatService:FilterStringForBroadcast(msg, player)
						ChatService:Chat(Radios[p].PrimaryPart, (showPlayerName and player.DisplayName .. ": " or "") .. filteredMsg)
					end
				end
				if Cooldowns[player] == MAX_CHATS then
					Cooldowns[player] -= 1
					task.wait(COOLDOWN)
					Cooldowns[player] = MAX_CHATS
				else
					Cooldowns[player] -= 1
				end
			end
		end
	end
}