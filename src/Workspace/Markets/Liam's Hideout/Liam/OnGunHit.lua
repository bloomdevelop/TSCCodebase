local npc = script.Parent

local lines = {
	"Watch where you're aiming!",
	"Hey, relax!",
	"Ow! What the hell is your problem?",
	"Would you cut that out?",
	"You do know my blood is a biohazard, right?"
}

local rng = Random.new()

return function(playerWhoShot: Player)
	game.Chat:Chat(npc.Head, lines[rng:NextInteger(1, #lines)], Enum.ChatColor.White)
end