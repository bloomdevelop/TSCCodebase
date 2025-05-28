--[[
FoxxoTrystan
07/29/2022
Adonis CIP Commands
--]]
return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service
	
	server.Commands.cip = {
		Prefix = server.Settings.Prefix;
		Commands = {"cip"};
		Args = {"Player"};
		Description = "Make the player a CIP";
		Hidden = false;
		Fun = false;
		AdminLevel = "Moderators";
		Function = function(plr)
			local LatexValues = plr.Character:FindFirstChild("LatexValues")
			if LatexValues then
				LatexValues.IsCIP.Value = true
			end
		end
	}

	server.Commands.uncip = {
		Prefix = server.Settings.Prefix;
		Commands = {"uncip"};
		Args = {"Player"};
		Description = "Remove the player as a CIP.";
		Hidden = false;
		Fun = false;
		AdminLevel = "Moderators";
		Function = function(plr)
			local LatexValues = plr.Character:FindFirstChild("LatexValues")
			if LatexValues then
				LatexValues.IsCIP.Value = false
			end
		end
	}
end
