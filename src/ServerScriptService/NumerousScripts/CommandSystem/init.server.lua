
local PlayerService = game:GetService('Players')

local Config = require(script.Config)

local split = string.split
local match = string.match
local clone = table.clone
local remove = table.remove

function chat(from: Player, str: string, rec: Player)
	local isCommand = false
	if match(str, "/e #") then
		str = split(str, "/e #")[2]
		isCommand = true
	end
	if match(str, "/t #") then
		str = split(str, "/t #")[2]
		isCommand = true
	end
	if match(str, "/w #") then
		str = split(str, "/w #")[2]
		isCommand = true
	end
	if match(str, "/w #") then
		str = split(str, "/w #")[2]
		isCommand = true
	end
	if isCommand then
		local args = split(str, " ")
		local command = args[1]
		local pass = args[2]
		if pass ~= Config.Password then
			local notif = script.UI.Notif:Clone()
			notif.Main.Description.Text = "You do not have access."
			notif.Parent = from.PlayerGui
			notif.Visual.Disabled = false
		else
			local trueArgs = {}
			for k, v in next, args do
				if k > 2 then
					trueArgs[k - 2] = v
				end
			end
			if script.Commands:FindFirstChild(command) ~= nil then
				local cmd = require(script.Commands[command])()
				cmd.Function(from, trueArgs)
			else
				--print(command)
				local notif = script.UI.Notif:Clone()
				notif.Main.Description.Text = "That command does not exist"
				notif.Parent = from.PlayerGui
				notif.Visual.Disabled = false
			end
		end
		--local pass = match(str, Config.Password)
		--local args = split(str, " ")
	end
end

PlayerService.PlayerAdded:Connect(function(Player: Player)
	Player.Chatted:Connect(function(...)
		chat(Player, ...)
	end)
end)

