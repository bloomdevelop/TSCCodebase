local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")
local Chat = game:GetService("Chat")

local InfectCheck = require(ReplicatedStorage:WaitForChild("InfectedCheckModule"))

local SadCIS = workspace:WaitForChild("DynamicallyLoaded"):WaitForChild("sadCIS")
local SadCISHumanoid = SadCIS:WaitForChild("Humanoid")
local SadCISHumanoidRootPart = SadCIS:WaitForChild("HumanoidRootPart")
local SadCISTorso = SadCIS:WaitForChild("Torso")
local SadCISHead = SadCIS:WaitForChild("Head")

local hitDialogCooldown
local hugDialogCooldown
local dead

local hurtVoiceline = {"Stop! Please!", "It hurts!", "Owie!", "Ouch!", "Stop!", "I don't want to die!", "Agh!"}
local infectedVoiceline = {"Why are you here...?", "You shouldn't be here...", "They are coming...", "I can hear the footsteps...", "Thank you...", "Please take care of yourself..."}
local normalVoiceline = {"Why are you helping me...?", "Thank you... You are unlike the others...", "You are not one of them... Are you...?"}

local EffectOne = script:WaitForChild("Effects"):WaitForChild("bom"):Clone()
local EffectTwo = script:WaitForChild("Effects"):WaitForChild("bom2"):Clone()

EffectOne.Parent = SadCISTorso
EffectTwo.Parent = SadCISTorso

local RNG = Random.new()

local function randomHurtVoice()
	return hurtVoiceline[RNG:NextInteger(1, #hurtVoiceline)]
end

local function randomInfectedVoice()
	return infectedVoiceline[RNG:NextInteger(1, #infectedVoiceline)]
end

local function randomNormalVoice()
	return normalVoiceline[RNG:NextInteger(1, #normalVoiceline)]
end

local hitDialogCooldown
script:WaitForChild("OnGunHit").Event:Connect(function(playerWhoShot: Player, damage: number, gunData: {[any]: any})
	if dead then return end

	if not hitDialogCooldown or DateTime.now().UnixTimestampMillis - hitDialogCooldown >= 750 then
		Chat:Chat(SadCISHead, randomHurtVoice())
		hitDialogCooldown = DateTime.now().UnixTimestampMillis
	end

	SadCISHumanoid:TakeDamage(damage)
end)

script:WaitForChild("OnHug").Event:Connect(function(playerWhoHug: Player)
	if dead then return end

	if not hugDialogCooldown or DateTime.now().UnixTimestampMillis - hugDialogCooldown >= 750 then
		Chat:Chat(SadCISHead, InfectCheck(playerWhoHug) and randomInfectedVoice() or randomNormalVoice())
		hugDialogCooldown = DateTime.now().UnixTimestampMillis
	end
	
	SadCISHumanoid.Health += RNG:NextInteger(10, 25)
end)

SadCISHumanoid.Died:Connect(function()
	if dead then return end
	dead = true
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {SadCIS}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	SadCISHumanoid.Health = 0
	
	EffectOne.Color = ColorSequence.new(Color3.fromRGB(63, 63, 63))
	EffectTwo.Color = ColorSequence.new(Color3.fromRGB(63, 63, 63))
	EffectOne:Emit(20)
	EffectTwo:Emit(30)

	for i = 1, RNG:NextInteger(1,10) do
		local g = ServerStorage.debre:Clone()
		g.Parent = SadCIS
		g.CFrame = SadCISHumanoidRootPart.CFrame * CFrame.new(0,3,0)
		g.Color = Color3.fromRGB(63, 63, 63)
		g.Trail.Color = ColorSequence.new(Color3.fromRGB(63, 63, 63))
		g.Velocity = Vector3.new(RNG:NextInteger(-30,30), RNG:NextInteger(50,60), RNG:NextInteger(-30,30)) 
		Debris:AddItem(g, 1)
	end

	task.delay(3, function()
		SadCIS:Destroy()
	end)
end)