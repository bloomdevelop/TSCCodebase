local dialog = {
	Healthy = {
		"You're looking well, I don't think you need any treatment.",
		"You're not injured, you'll be fine.",
		"You seem healthy to me.",
	},

	Injured = {
		"You look a little worse for wear. I can fix that up for $PRICE.",
		"You're not looking so great. $PRICE credits, and I'll see what I can do.",
		"Did you get in a fight? I'll treat your injuries for $PRICE credits."
	},
	
	Healed = {
		"That should take care of it.",
		"You should feel better soon.",
		"All patched up. Come back later if you need any more help!"
	},
	
	Broke = {
		"So... Where's the payment?",
		"Wait... Sorry, but this isn't enough to cover the costs.",
		"You need more money than that."
	},
	
	Unwelcome = {
		"What do you want?",
		"What are you looking at?",
		"I'm not helping you."
	},
	
	Infected = {
		"Um, sorry, I don't think I can help with that.",
		"I can't cure that...",
		"I'm... only familiar with human patients. My apologies."
	}
}

return dialog