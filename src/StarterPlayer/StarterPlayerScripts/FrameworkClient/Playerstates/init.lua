Typing = require(script.Parent.Typing)

Dances = {"dance1", "dance2"}
ExtraDances = {"shuffle", "carlton", "sponge", "cory", "praise", "smooth", "gaming", "shanty", "pp", "default", "torture", "aerostep", "robics", "catdance", "caramelldansen", "garry", "comeback"}
EmoteNames = { pat = true, boop = true, uamshanty = true, wave = false, point = false, dance1 = true, dance2 = true,
	laugh = false, cheer = false, shuffle = true, carlton = true, sponge = true, cory = true, praise = true, smooth = true,
	gaming = true, shanty = true, pp = true, default = true, torture = true, aerostep = true, robics = true, chill = true,
	chillback = true, chillsit = true, lay = true, salute = true, comeback = true, catdance = true, caramelldansen = true, garry = true }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes

return function(Framework: Typing.FrameworkType)
	-- INITILAIZATION
	local Playerstates: Typing.PlayerstatesType = {
		AnimationListeners = {},
		Player = Framework.Services.Players.LocalPlayer,
		Character = Framework.Services.Players.LocalPlayer.Character,
		Mouse = nil,
		Animator = nil,
		ToolEquiped = false,
		Viewmodel = {
			SetState = function(_) end,
		},
		Values = {
			WalkSpeed = 12,
			MaxHealth = 100,
			HealthCap = 100,
			Health = 100,
			StaminaMax = 100,
			Stamina = 100
		}
	}

	Playerstates.Mouse = Playerstates.Player:GetMouse()

	-- PRIVATE VARIABLES

	local Animator = require(script.Animator)(Framework)
	local StateFunctions = require(script.StateFunctions)

	local defaultSpeed = 14
	local lastJump = tick()

	local associatedListeners = {
		["walk"] = {"footstep"},
		["run"] = {"footstep"},
		["crouch"] = {"footstep"},
		["crawl"] = {"footstep"},
		["climb"] = {"climb"},
		["jump"] = {"pause"}
	}

	-- PRIVATE FUNCTIONS

	local function chatted(msg)
		local emote = ""
		if msg == "/e dance" then
			emote = Dances[math.random(1, #Dances)]
		elseif msg == "/e dances" then
			emote = ExtraDances[math.random(1, #ExtraDances)]
		elseif (string.sub(msg, 1, 3) == "/e ") then
			emote = string.sub(msg, 4)
		elseif (string.sub(msg, 1, 7) == "/emote ") then
			emote = string.sub(msg, 8)
		end

		if Playerstates.Animator and EmoteNames[emote] then -- if animator exists and emote name does too
			Playerstates.Animator:PlayEmote(emote)
		end
	end

	local function newPlayer(player: Player)
		player.CharacterAdded:Connect(function(Character: Typing.CharacterType)
			local humanoid = Character:FindFirstChild('Humanoid') or Character:WaitForChild('Humanoid', 60)
			Playerstates:RegisterAnimationListeners(humanoid)
		end)
	end

	-- PUBLIC FUNCTIONS

	function Playerstates.RegisterAnimationListeners(self, humanoid: Humanoid & any)
		local conns = {}
		local animsProcessed = {}
		humanoid.AnimationPlayed:Connect(function(track: AnimationTrack)
			local name = Framework.Modules.Animations.Backtrack[track.Animation.AnimationId]
			if name and associatedListeners[name] and not table.find(animsProcessed, track.Animation.AnimationId) then
				for _, listener in next, associatedListeners[name] do
					if Playerstates.AnimationListeners[listener] then
						local signal = track:GetMarkerReachedSignal(listener):Connect(function(param)
							Playerstates.AnimationListeners[listener](Framework, humanoid, track, param)
						end)
						table.insert(animsProcessed, track.Animation.AnimationId)
						table.insert(conns, signal)
					end
				end
			end
		end)
		humanoid.Died:Connect(function()
			for _, conn: RBXScriptConnection in next, conns do
				conn:Disconnect()
			end
		end)
	end

	function Playerstates.NewCharacter(Character: Typing.CharacterType)
		Playerstates.Character = Character
		local humanoid = Character:FindFirstChild('Humanoid') or Character:WaitForChild('Humanoid', 60)
		Playerstates:RegisterAnimationListeners(humanoid)
		Playerstates.Animator = Animator.new(Character)
		if Playerstates.Player:GetAttribute('RevEnabled') then
			Framework.Modules.Animations.Animations.idle = Framework.Modules.Animations.Others.revIdle
			Framework.Modules.Animations.Animations.walk = Framework.Modules.Animations.Others.revWalk
			Framework.Modules.Animations.Animations.run = Framework.Modules.Animations.Others.revRun
		end
		Playerstates.Animator:Initialize(Framework.Modules.Animations, StateFunctions(Framework, Playerstates.Animator))
		Playerstates.Player.Chatted:Connect(chatted)
		Playerstates.Player:SetAttribute('State', 'None')
		Character.ChildAdded:Connect(function(i: Instance)
			if i:IsA('Tool') and i:FindFirstChild('GunData') then
				Playerstates.ToolEquiped = true
			end
		end)
		Character.ChildRemoved:Connect(function(i: Instance)
			if i:IsA('Tool') then
				Playerstates.ToolEquiped = false
			end
		end)
		Framework.Logger.debug('[ PLAYERSTATES / DEBUG ]', 'Local player character spawned and registered.')
	end

	function Playerstates.SetPositionState(pos: string)
		if pos == "sprint" then
			Playerstates.Player:SetAttribute('State', 'Running')
		elseif pos == "crouch" then
			Playerstates.Player:SetAttribute('State', 'Crouching')
		elseif pos == "crawl" then
			Playerstates.Player:SetAttribute('State', 'Crawling')
		else
			Playerstates.Player:SetAttribute('State', 'None')
		end
		
		Remotes.Movement.RegisterMovementState:FireServer(pos)
	end

	function Playerstates.GetPositionState(): string
		return Playerstates.Player:GetAttribute('State')
	end

	local function update()
		if Playerstates.Character and Playerstates.Character:FindFirstChild('Humanoid') then
			-- speed updates
			local newSpeed = defaultSpeed
			if Playerstates.Player:GetAttribute('State') == "Running" then
				newSpeed += 12
				Playerstates.Character.Humanoid.HipHeight = 0
			elseif Playerstates.Player:GetAttribute('State') == "Crouching" then
				newSpeed -= 6
				Playerstates.Character.Humanoid.HipHeight = -1.2
			elseif Playerstates.Player:GetAttribute('State') == "Crawling" then
				newSpeed -= 8
				Playerstates.Character.Humanoid.HipHeight = -1.6
			else
				Playerstates.Character.Humanoid.HipHeight = 0
			end
			
			local multiplier = Playerstates.Character:GetAttribute("SpeedMultiplier") or 1
			newSpeed *= multiplier
			local weaponChargeSlowness = Playerstates.Character:GetAttribute("WeaponChargeSlowness") or 1
			newSpeed = newSpeed/weaponChargeSlowness

			local isBlocking = Playerstates.Character:GetAttribute("BlockingTimestamp") ~= nil
			local blockingSlowness = (isBlocking and 1.5) or 1
			newSpeed = newSpeed/blockingSlowness

			for _, inst: Instance in next, Playerstates.Character.Humanoid:GetChildren() do
				if inst:IsA('NumberValue') then
					newSpeed = newSpeed + inst.Value
				end
			end
			if Playerstates.Animator.StateFunctions[(Playerstates.Character.Humanoid::Humanoid):GetState().Name] and Playerstates.Character:FindFirstChild('Torso') then
				if (Playerstates.Character.Humanoid::Humanoid):GetState() == Enum.HumanoidStateType.Climbing then
					Playerstates.Animator.StateFunctions["Climbing"]((Playerstates.Character.Torso.Velocity * Vector3.new(1,1,1)).Magnitude or 1)
				else
					Playerstates.Animator.StateFunctions[(Playerstates.Character.Humanoid::Humanoid):GetState().Name]((Playerstates.Character.Torso.Velocity * Vector3.new(1,0,1)).Magnitude or 1)
				end
			end
			newSpeed = math.clamp(newSpeed, 2, 50)
			Playerstates.Values.WalkSpeed = newSpeed
			Playerstates.Character.Humanoid.WalkSpeed = newSpeed
		end
	end

	-- FINALIZE

	for _, module: ModuleScript in next, script.AnimationListeners:GetChildren() do
		--local status, func = pcall(function()
		--	return require(module)
		--end)
		--if status then
		--Playerstates.AnimationListeners[module.Name] = func
		Playerstates.AnimationListeners[module.Name] = require(module)
		Framework.Logger.debug('[ PLAYERSTATES / DEBUG ]', string.format('Added "%s" to animation listeners.', module.Name))
		--else
		--Framework.Logger.warn('[ PLAYERSTATES / ERROR ]', string.format('Animation listener module "%s" errored out.', module.Name))
		--end
	end

	if Playerstates.Character then
		Playerstates.NewCharacter(Playerstates.Character)
	end

	Playerstates.Player.CharacterAdded:Connect(Playerstates.NewCharacter)

	for _, i in next, Framework.Services.Players:GetPlayers() do
		newPlayer(i)
	end
	Framework.Services.Players.PlayerAdded:Connect(newPlayer)

	local __wait = 0

	Framework.UserInput:AddInput("sprint", { Enum.KeyCode.LeftShift, Enum.KeyCode.Thumbstick1 }, function()
		if Framework.Interface.StatsPanel.Stamina > 0 then
			Playerstates.SetPositionState("sprint")
		else
			Playerstates.SetPositionState("none")
		end
	end, { checkText = true })

	Framework.UserInput:AddInput("sprintoff", { Enum.KeyCode.LeftShift, Enum.KeyCode.Thumbstick1 }, function()
		Playerstates.SetPositionState("none")
	end, { checkText = true, state = Enum.UserInputState.End })

	Framework.UserInput:AddInput("crouch", { Enum.KeyCode.X }, function()
		Playerstates.SetPositionState( (Playerstates.GetPositionState() ~= "Crouching") and "crouch" or "none")
	end, { checkText = true })

	Framework.UserInput:AddInput("crawl", { Enum.KeyCode.C }, function()
		if Playerstates.GetPositionState() == "Crouching" then
			Playerstates.SetPositionState( (Playerstates.GetPositionState() ~= "Crawling") and "crawl" or "crouch")
		else
			Playerstates.SetPositionState("crouch")
		end
	end, { checkText = true })

	Framework.UserInput:AddInput("xboxDown", { Enum.KeyCode.DPadDown }, function()
		if Playerstates:GetPositionState() ~= "Crawling" then
			if Playerstates:GetPositionState() ~= "Crouching" then
				Playerstates.SetPositionState("crouch")
			else
				Playerstates.SetPositionState("crawl")
			end
		end
	end, { checkText = true })

	Framework.UserInput:AddInput("xboxUp", { Enum.KeyCode.DPadUp }, function()
		if Playerstates:GetPositionState() == "Crawling" then
			Playerstates.SetPositionState("crouch")
		elseif Playerstates:GetPositionState() == "Crouching" then
			Playerstates.SetPositionState("none")
		elseif Playerstates:GetPositionState() == "None" then
			Playerstates.SetPositionState("sprint")
		end
	end, { checkText = true })

	Framework.Services.RunService.RenderStepped:Connect(update)

	Framework.Logger.debug('[ PLAYERSTATES / DEBUG ]', 'Initialized playerstates, watching over player.')

	return Playerstates
end