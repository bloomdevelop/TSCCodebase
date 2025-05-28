
return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service
	server.Commands.Ragdoll = {
		Prefix = server.Settings.Prefix;	-- Prefix to use for command
		Commands = {"ragdoll"};	-- Commands
		Args = {"player1"};	-- Command arguments
		Description = "Make you ragdoll.";	-- Command Description
		Hidden = false; -- Is it hidden from the command list?
		Fun = false;	-- Is it fun?
		AdminLevel = "Moderators";	    -- Admin level; If using settings.CustomRanks set this to the custom rank name (eg. "Baristas")
		Function = function(plr, args)    -- Function to run for command
			plr.Character:SetAttribute("Ragdoll", not plr.Character:GetAttribute("Ragdoll"))
		end
	}
end
