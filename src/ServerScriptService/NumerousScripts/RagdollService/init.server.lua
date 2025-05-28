-- SERVICES
local PlayerService = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- MODULES
local Ragdoll = require(script.Ragdoll)

-- TYPES
export type Character = Model & { Head: Part, HumanoidRootPart: Part, Humanoid: Humanoid }

-- VARIABLES
--local PlayerCache: {[Player]: HumanoidDescription } = {}
--local Cache: {[number]: Character } = {}

-- FUNCTIONS

function characterAdded(Character: Character)
	task.wait(1)
	if Character == nil then
		return
	end
	Ragdoll.RegisterCharacter(Character)
	local Humanoid = Character:FindFirstChildOfClass('Humanoid') :: Humanoid
	if Humanoid == nil then
		return
	end
	Character.ChildAdded:Connect(function()
		if Character:GetAttribute('Ragdoll') then
			task.wait()
			if Humanoid.Health > 0 then
				Humanoid:UnequipTools()
			end
		end
	end)
	Humanoid.Died:Connect(function()
		Character:SetAttribute('Ragdoll', true)
		--local l = PlayerService:CreateHumanoidModelFromDescription(PlayerCache[Player], Enum.HumanoidRigType.R6)
		--l.Name = Player.Name
		--local body: Model, collisions = Ragdoll.FakeRagdoll(l)
		---- reposition key body parts
		--for _, i: Instance in next, Character:GetChildren() do
		--	if i:IsA('BasePart') and body:FindFirstChild(i.Name) then
		--		body[i.Name].CFrame = i.CFrame
		--	end
		--end
		---- Remove all but the humanoid
		--for _, i in next, Character:GetChildren() do
		--	if not i:IsA('Humanoid') then
		--		i:Destroy()
		--	end
		--end
		--body.Parent = workspace
		---- redo ownership
		--Ragdoll.SetOwnership(Player, body)
		---- tell client to redo camera
		--ReplicatedStorage.Remotes.RagdollNetwork:FireClient(Player, body)
		--task.wait(15)
		--body:Destroy()
	end)
	print('Finished registering "' .. Character.Name .. '" character to Ragdoll Server')
end

function playerAdded(Player: Player)
	--Ragdoll.ApplyClient(Player)
	--print('Registered player ragdoll client')
	characterAdded(Player.Character)
	Player.CharacterAdded:Connect(characterAdded)
	--local humanoidDescription: HumanoidDescription = PlayerService:GetHumanoidDescriptionFromUserId(Player.UserId)
	--if humanoidDescription then
	--	PlayerCache[Player] = humanoidDescription
	--end
end

-- CORE
PlayerService.PlayerAdded:Connect(playerAdded)
for _, player: Player in next, PlayerService:GetPlayers() do
	playerAdded(player)
end

ReplicatedStorage.Remotes.RagdollNetwork.OnServerEvent:Connect(function(p)
	p:Kick("\n\nUnexpected Client Behaviour [1006]\n\nInvalid request")
end)