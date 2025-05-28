-- // Steven_Scripts, 2022

local rst = game:GetService("ReplicatedStorage")

local clientModulesFolder = rst.Modules

local teamAlignments = require(clientModulesFolder.TeamAlignments)

local npc = script.Parent

local dialog = {
	Intro = {
		"My name's Kyran. I can train you in unarmed combat for $PRICE credits. What do you say?",
		"It's important to know how to defend yourself, even without a weapon. I'll take $PRICE credits for training. The choice is yours.",
		"Your body can be a powerful weapon if you know how to use it. For $PRICE credits, I can teach you. It's up to you."
	},
	
	Unwelcome = {
		"I think you should leave.",
		"I can't talk to you down here.",
		"We can't talk to each other."
	},

	Broke = {
		"Unfortunately, that won't be enough.",
		"I'm sorry, but you'll need more than that for payment.",
		"The price is non-negotiable. You'll have to find more money."
	},

	Trained = {
		"Use your skills for good.",
		"Don't use it unless you have to.",
		"Be safe out there."
	},
	
	AlreadyTrained = {
		"There's nothing more I can teach you.",
		"You clearly don't need my help.",
		"There's nothing I can teach you that you don't already know."
	},
	
	NoFists = {
		"Um... Those aren't fists.",
		"Those are not fists...",
		"I don't know how to train you with that..."
	}
}

local recentlyTalked = {}

local price = 1000

local root = npc.PrimaryPart
local head = npc.Head

local rng = Random.new()

local prompt = Instance.new("ProximityPrompt")
prompt.ObjectText = npc.Name
prompt.ActionText = "Interact"
prompt.HoldDuration = 1
prompt.MaxActivationDistance = 5
prompt.RequiresLineOfSight = false

prompt.Parent = root

prompt.Triggered:Connect(function(plr)
	local char = plr.Character
	if not char then return end

	local team = plr.Team
	local plrAlignment = teamAlignments[team.Name]

	if plrAlignment == "testSubjects" then
		local userId = plr.UserId
		
		if plr:GetAttribute("FistsTrained") == true then
			-- They are already trained.
			game.Chat:Chat(head, dialog.AlreadyTrained[rng:NextInteger(1, #dialog.AlreadyTrained)])
			return
		end
		
		if plr.Character:FindFirstChild("Fists") == nil and plr.Backpack:FindFirstChild("Fists") == nil then
			-- They don't have fists...?
			game.Chat:Chat(head, dialog.NoFists[rng:NextInteger(1, #dialog.NoFists)])
			return
		end
		
		if recentlyTalked[userId] == true then
			-- Player is confirming transaction
			local cash = plr.leaderstats.Cash

			if cash.Value >= price then
				-- Player has enough cash
				cash.Value = cash.Value - price

				game.Chat:Chat(head, dialog.Trained[rng:NextInteger(1, #dialog.Trained)])
				
				plr:SetAttribute("FistsTrained", true)
				
				if char:FindFirstChild("Fists") then
					char.Humanoid:UnequipTools()
				end
				plr.Backpack.Fists:Destroy()
				
				local trainedFists = game.ServerStorage.Tools["Trained Fists"]:Clone()
				trainedFists.Parent = plr.Backpack
			else
				-- Player doesn't have enough cash
				game.Chat:Chat(head, dialog.Broke[rng:NextInteger(1, #dialog.Broke)])
			end
		else
			-- Player is starting prompt
			local dialogLine = dialog.Intro[rng:NextInteger(1, #dialog.Intro)]
			dialogLine = string.gsub(dialogLine, "$PRICE", tostring(price))

			game.Chat:Chat(head, dialogLine)

			recentlyTalked[userId] = true

			task.wait(10)

			recentlyTalked[userId] = nil
		end
	else
		-- Team alignment doesn't match
		game.Chat:Chat(head, dialog.Unwelcome[rng:NextInteger(1, #dialog.Unwelcome)])
	end
end)

npc.Humanoid.Animator:LoadAnimation(npc.Animations.Idle):Play()