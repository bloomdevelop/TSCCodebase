local npc = script.Parent

local infectedLines = {
	"Personal space, please.",
	"Hello to you too.",
	"Don't be weird.",
	"I appreciate the gesture, but I'd prefer if you were less touchy.",
	"At this rate maybe I should start charging people for hugs.",
	"I know I don't have organs, but could you not hug me so tightly?"
}

local humanLines = {
	"I don't know if it's safe for you to touch me.",
	"Are you sure it's safe to be doing that without a hazmat suit?",
	"Hey, what are you-... Oh. Uh. Thanks?",
	"Usually it's the infected that do that.",
	"You got latex on your shirt.",
	"Sure, hug the sentient biohazard if that's what you want to do."
}

local rng = Random.new()

local infectedCheck = require(game.ReplicatedStorage.InfectedCheckModule)

return function(playerWhoHugged: Player)
	local infected = infectedCheck(playerWhoHugged)
	
	if infected then
		game.Chat:Chat(npc.Head, infectedLines[rng:NextInteger(1, #infectedLines)], Enum.ChatColor.White)
	else
		game.Chat:Chat(npc.Head, humanLines[rng:NextInteger(1, #humanLines)], Enum.ChatColor.White)
	end
end