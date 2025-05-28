return {
	MainGroup = 11577231,
	GroupAssociates = {
		[12026513] = "Recontainment Unit",
		[12026669] = "Special Operations",
		[11608337] = "Security Department",
		[12045972] = "Internal Security Bureau",
		[11648519] = "Scientific Department",
		[12022092] = "Utility & Maintenance",
		[11649027] = "Medical Department",
		[12330631] = "UNSDF",
		[12267029] = "BWD"
	},
	TeamChangeBlacklist = {
		["Latex"] = true,
		["Menu"] = true
	},
	CardBlacklistTeams = {
		["Contained Infected Subject"] = true,
		["Test Subject"] = true,
		["Solitary Confinement"] = true,
		["CIS Solitary"] = true,
		["Latex"] = true,
		["Menu"] = true
	},
	GroupTeams = {
		{
			Ranks = {0, 1},
			Team = "Test Subject"
		},
		--[2] = "CIS Solitary",
		--[3] = "Contained Infected Subject",
		{
			Ranks = {4},
			"Solitary Confinement",
			Locked = true
		},
		{
			Ranks = {
				9, -- Level 5
				100, -- Department Intern
				150, -- Department Administrator
				180, -- Administrative Department
				255 -- Administator
			},
			"Administrative Department"
		},
		{
			Ranks = {253},
			"Site Engineer"
		}
	}
}