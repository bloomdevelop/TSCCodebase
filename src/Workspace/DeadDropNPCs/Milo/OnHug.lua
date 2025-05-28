local npc = script.Parent

local lines = {
	"Could you back away a bit?",
	"Don't do that.",
	"I'm fine, thanks.",
	"Little too close there.",
	"Okay then.",
}

local rng = Random.new()

return function(playerWhoHugged: Player)
	game.Chat:Chat(npc.Head, lines[rng:NextInteger(1, #lines)], Enum.ChatColor.White)
end