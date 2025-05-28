
return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service

	server.Commands.LoreActor = {
		Prefix = server.Settings.PlayerPrefix;
		Commands = {"loreactor"};
		Args = {};
		Description = "Toggle lore actor name tag";
		Filter = true;
		AdminLevel = "Players";
		Function = function(plr: Player, args: {string})
			plr:SetAttribute("ToggledLoreActor", not plr:GetAttribute("ToggledLoreActor"))
		end,
	}
end