local chatService = game:GetService("Chat")
local showPlayerName = true
local range = 2

local playersOnCooldown = {}
local cooldown = 5
local maxChat = 3
local module = function(player,msg)
	if playersOnCooldown[player] == nil  then
		playersOnCooldown[player] = maxChat 
	end
	local radio
	for _,v in pairs(workspace.Radios:GetChildren())do
		if  v:IsA("Model") and (v.PrimaryPart.Position-player.Character.PrimaryPart.Position).Magnitude <= range and v:FindFirstChild("ReceivingOnly") == nil then --if in range
			radio = v
			break    
		end
	end
	if radio then
		if playersOnCooldown[player] == 0  then --cooldown triggered
			radio.PrimaryPart.AccessDeniedTwo:Play()
			--print(radio.PrimaryPart.AccessDeniedTwo.IsPlaying)
			for i,v in pairs(radio:GetDescendants())do
				if v:IsA("BasePart") and v.Material == Enum.Material.Neon then
					v.BrickColor = BrickColor.new("Persimmon")
				end
			end
			wait(0.5)
			for i,v in pairs(radio:GetDescendants())do
				if v:IsA("BasePart") and v.Material == Enum.Material.Neon then
					v.BrickColor = BrickColor.new("Ghost grey")
				end
			end
		else
			for _,v in pairs(workspace.Radios:GetChildren())do
				v.PrimaryPart.Beep:Play()
				v.PrimaryPart.Name = "RadioPart"
				if v:IsA("Model") and v ~= radio then
					local filteredMsg = chatService:FilterStringForBroadcast(msg, player)
					chatService:Chat(v.PrimaryPart,(showPlayerName and player.DisplayName .. ": " or "") .. filteredMsg)
				end
			end	
			if  playersOnCooldown[player] == maxChat  then
				playersOnCooldown[player] -= 1 
				wait(cooldown)
				playersOnCooldown[player] = maxChat
			else
				playersOnCooldown[player] -= 1 
			end
		end
	end
end
return module