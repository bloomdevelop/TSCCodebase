local npc = script.Parent

local lines = {
	"Yo, chill!",
	"Watch where you're aiming!",
	"You got a problem?",
	"You tryin' to start something?",
	"I ain't got time to fight right now."
}

local rng = Random.new()

return function(playerWhoShot: Player)
	game.Chat:Chat(npc.Head, lines[rng:NextInteger(1, #lines)], Enum.ChatColor.White)
end