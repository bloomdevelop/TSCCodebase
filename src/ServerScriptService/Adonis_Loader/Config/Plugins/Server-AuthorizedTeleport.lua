--!nolint UnknownGlobal

local sst = game:GetService("ServerStorage")

local bindablesFolder = sst.Bindables

return function()
	server.Commands.AuthorizedTeleport = {
		Prefix = server.Settings.Prefix;	-- Prefix to use for command
		Commands = {"authorizedteleport", "atp"};	-- Commands
		Args = {"player1", "player2"};	-- Command arguments
		Description = "Teleports one player to another without setting off the anticheat.";	-- Command Description
		Hidden = false; -- Is it hidden from the command list?
		Fun = false;	-- Is it fun?
		AdminLevel = "Moderators";	    -- Admin level; If using settings.CustomRanks set this to the custom rank name (eg. "Baristas")
		Function = function(plr,args)    -- Function to run for command
			local plr1 = game.Players:FindFirstChild(args[1])
			local plr2 = game.Players:FindFirstChild(args[2])
			
			if plr1 and plr2 then
				local char2 = plr2.Character
				if char2 then
					local root2 = char2:FindFirstChild("HumanoidRootPart")
					if root2 then
						bindablesFolder.Anticheat.AuthorizeTeleport:Fire(plr1, root2.CFrame * CFrame.new(0, 0, -3.5))
					end
				end
			end
		end
	}
end
