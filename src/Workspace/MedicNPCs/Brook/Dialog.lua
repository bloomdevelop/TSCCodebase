local dialog = {
	Healthy = {
		"You look fine to me.",
		"You're not physically hurt. And no, I don't heal emotional trauma.",
		"Just stopping by to say hi? You're not injured at all.",
	},
	
	Injured = {
		"You're hurt. I can heal that for $PRICE.",
		"Where the hell are all the medical staff? Whatever. I can patch you up for $PRICE.",
		"You look rather worse for wear. $PRICE credits, and I'll take care of it."
	},
	
	Unavailable = {
		"Give me a break, you've got enough medical staff on-site already.",
		"Maybe you should talk to one of the medics who isn't retired.",
		"Go find someone else, you have more than enough medical staff on-site."
	},
	
	Healed = {
		"There. Now try not to get hurt again.",
		"Feeling better? Good.",
		"It was a pleasure doing business."
	},
	
	Broke = {
		"...Where's the money?",
		"This isn't enough to cover the costs.",
		"This won't be enough money."
	},
	
	Unwelcome = {
		"Nope.",
		"I don't do business with fugitives.",
		"I'm not healing you. Leave before I call security."
	},
	
	Infected = {
		"I can't really help you there, bud.",
		"You're... out of my pay grade.",
		"Do I look like a veterinarian?"
	}
}

return dialog