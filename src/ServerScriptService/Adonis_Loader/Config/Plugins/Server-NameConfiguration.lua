
return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service

	server.Commands.HideName = {
		Prefix = server.Settings.Prefix;
		Commands = {"hidename"};
		Args = {"Player"};
		Description = "Hides your username when hovered over.";
		Hidden = false; -- Is it hidden from the command list?
		Fun = false;	-- Is it fun?
		AdminLevel = "Moderators";
		Function = function(plr: Player, args: {string})
			if args[1] then
				for _, player in pairs(service.GetPlayers(plr, args[1])) do
					if player then
						player:SetAttribute("NameHidden", true)
					end
				end
			else
				if plr then
					plr:SetAttribute("NameHidden", true)
				end
			end
		end,
	}

	server.Commands.UnhideName = {
		Prefix = server.Settings.Prefix;
		Commands = {"unhidename"};
		Args = {"Player"};
		Description = "Shows your username when hovered over.";
		Hidden = false; -- Is it hidden from the command list?
		Fun = false;	-- Is it fun?
		AdminLevel = "Moderators";
		Function = function(plr: Player, args: {string})
			if args[1] then
				for _, player in pairs(service.GetPlayers(plr, args[1])) do
					if player then
						player:SetAttribute("NameHidden", false)
					end
				end
			else
				if plr then
					plr:SetAttribute("NameHidden", false)
				end
			end
		end,
	}

	server.Commands.SetName = {
		Prefix = server.Settings.Prefix;
		Commands = {"setname"};
		Args = {"Player","Name"};
		Description = "Sets you a custom username. Type nothing to reset";
		Hidden = false; -- Is it hidden from the command list?
		Fun = false;	-- Is it fun?
		AdminLevel = "Moderators";
		Function = function(plr: Player, args: {string})
			if args[1] then
				for _, player in pairs(service.GetPlayers(plr, args[1])) do
					if player then
						if args[2] then
							player:SetAttribute("CustomName", tostring(args[2]))
						else
							player:SetAttribute("CustomName", "")
						end
					end
				end
			else
				if plr then
					if args[2] then
						plr:SetAttribute("CustomName", tostring(args[2]))
					else
						plr:SetAttribute("CustomName", "")
					end
				end
			end
		end,
	}
	
	server.Commands.HideRank = {
		Prefix = server.Settings.Prefix;
		Commands = {"hiderank"};
		Args = {"Player"};
		Description = "Hides your Rank when hovered over.";
		Hidden = false; -- Is it hidden from the command list?
		Fun = false;	-- Is it fun?
		AdminLevel = "Moderators";
		Function = function(plr: Player, args: {string})
			if args[1] then
				for _, player in pairs(service.GetPlayers(plr, args[1])) do
					if player then
						player:SetAttribute("RankHidden", true)
					end
				end
			else
				if plr then
					plr:SetAttribute("RankHidden", true)
				end
			end
		end,
	}

	server.Commands.UnhideRank = {
		Prefix = server.Settings.Prefix;
		Commands = {"unhiderank"};
		Args = {"Player"};
		Description = "Shows your Rank when hovered over.";
		Hidden = false; -- Is it hidden from the command list?
		Fun = false;	-- Is it fun?
		AdminLevel = "Moderators";
		Function = function(plr: Player, args: {string})
			if args[1] then
				for _, player in pairs(service.GetPlayers(plr, args[1])) do
					if player then
						player:SetAttribute("RankHidden", false)
					end
				end
			else
				if plr then
					plr:SetAttribute("RankHidden", false)
				end
			end
		end,
	}
end