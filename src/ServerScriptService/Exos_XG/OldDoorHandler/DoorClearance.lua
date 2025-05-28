local ClearanceData = {}
--// UserIds here. Will override all security checks for doors. Does not require any card or team in order to activate a door.
--// Useful for debugging without needing to switch teams.
ClearanceData.UserOverride = {
	10679367, -- Exos_XG
	1502762651, -- Software
	367025, -- MetaProx
	421561, -- FragmentFour
	
}

--// Tool names and their correspnding level clearance to interact with the 'clr' value inside any doors. 
--// 'clr' can be added to any door and will be accomodated by the handler.
--// "All" grants omni-access. It is equivalent to being in the UserOverride but is bound to a tool. Players with this tool can access anything.
--// Feel free to remove/replace these placeholders with corresponding cards & add more clearances.
ClearanceData.ToolClearance = {
	["Card-L0"] = 1,
	["Card-L1"] = 1,
	["Card-L2"] = 2,
	["Card-L3"] = 3,
	["Card-L4"] = 4,
	["Card-L5"] = 5,
	["SECURITY ARMORY"] = 7,
	["MTF Armory"] = 7,
	
	["O5 Card"] = "All",
	["SPEC-ACCESS"] = "All",
	["[DATA EXPUNGED]"] = "All",
}

return ClearanceData

