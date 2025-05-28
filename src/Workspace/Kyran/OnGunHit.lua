local npc = script.Parent

local root = npc.HumanoidRootPart

local defaultCF = root.CFrame

local untrainedLines = {
	"Don't waste my time.",
	"I wouldn't recommend trying that again.",
	"Keep your hands to yourself.",
}

local trainedLines = {
	"You're not that skilled yet.",
	"Nice, you almost hit me.",
	"That was a good swing. But not good enough.",
}

local rng = Random.new()

local cooldown = false

return function(playerWhoShot : Player, damage : number, gun : Tool, gunData)
	local gunData = require(gun.GunData)
	
	if gunData.Charge ~= nil and cooldown == false then
		local playerCharacter = playerWhoShot.Character
		
		local playerTorso = playerCharacter:FindFirstChild("Torso")
		if playerTorso == nil then return end
		
		local playerHumanoid = playerCharacter:FindFirstChild("Humanoid")
		if playerHumanoid == nil then return end
		
		cooldown = true
		
		local animationTrack = npc.Humanoid.Animator:LoadAnimation(npc.Animations.TigerDrop)
		animationTrack:Play()
		
		npc.Torso.TigerDropSound:Play()
		npc["Right Arm"].RightGripAttachment.Explosion:Emit(20)
		npc["Right Arm"].RightGripAttachment.Blood:Emit(20)
		
		playerHumanoid:UnequipTools()
		playerHumanoid.Health = math.clamp(playerHumanoid.Health - 200, 1, playerHumanoid.MaxHealth)
		
		playerCharacter:SetAttribute("Ragdoll", true)
		playerCharacter.Humanoid.PlatformStand = true
		
		npc:PivotTo(CFrame.lookAt(root.Position, Vector3.new(playerTorso.Position.X, root.Position.Y, playerTorso.Position.Z)))
		
		local direction = (playerTorso.Position - npc.Torso.Position).Unit
		local bf = Instance.new("BodyForce")
		bf.Force = direction*15000
		bf.Parent = playerTorso
		
		game.Debris:AddItem(bf, .1)
		
		local trained = playerWhoShot:GetAttribute("FistsTrained") == true
		
		task.wait(1)
		
		npc:PivotTo(defaultCF)
		
		playerCharacter:SetAttribute("Ragdoll", false)
		
		if trained == true then
			game.Chat:Chat(npc.Head, trainedLines[rng:NextInteger(1, #trainedLines)], Enum.ChatColor.White)
		else
			game.Chat:Chat(npc.Head, untrainedLines[rng:NextInteger(1, #untrainedLines)], Enum.ChatColor.White)
		end
		
		cooldown = false
	end
end