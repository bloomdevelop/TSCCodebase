--[[

	So, here is why we don't use roblox's animator and why we also use Humanoid over Animator instance to handle animations:
	 - Roblox's animator script regardless is underdeveloped and has general code flaws,
	 - Implementing this system into our framework with absolute control and better handling for overall will give us what we need,
	 - Humanoid will show active assets being played in rendering debugging, unlike Animator, because Roblox is forgetful about their own updates
	 - This code is more dynamically integrated.

]]
if game:GetService('RunService'):IsServer() then
	error("Cannot use Animator on server side.")
	return nil
end

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local SoundService = game:GetService('SoundService')
local RunService = game:GetService('RunService')

local Raycaster = require(ReplicatedStorage.Modules.Raycaster)()
local Animations = require(script.Animations)

local Player: Player? = Players.LocalPlayer
local Character: Model? = nil

--[[ ANIMATION TRACK EVENT HANDLING ]]

local StepVars = {
	["Plastic"] = "Plastic",
	["Wood"] = "Wood",
	["Slate"] = "Concrete",
	["Concrete"] = "Concrete",
	["CorrodedMetal"] = "Diamond",
	["DiamondPlate"] = "Diamond",
	["Foil"] = "Tile",
	["Grass"] = "Grass",
	["Ice"] = "Ice",
	["Marble"] = "Pebble",
	["Granite"] = "Pebble",
	["Brick"] = "Brick",
	["Pebble"] = "Pebble",
	["Sand"] = "Sand",
	["Fabric"] = "Fabric",
	["SmoothPlastic"] = "Plastic",
	["Metal"] = "Diamond",
	["WoodPlanks"] = "Wood",
	["Cobblestone"] = "Cobblestone",
	["Air"] = "Concrete",
	["Water"] = "Water",
	["Rock"] = "Concrete",
	["Glacier"] = "Concrete",
	["Snow"] = "Snow",
	["Sandstone"] = "Concrete",
	["Mud"] = "Dust",
	["Basalt"] = "Concrete",
	["Ground"] = "Dust",
	["CrackedLava"] = "Concrete",
	["Neon"] = "Plastic",
	["Glass"] = "Glass",
	["Asphalt"] = "Concrete",
	["LeafyGrass"] = "Grass",
	["Salt"] = "Concrete",
	["Limestone"] = "Concrete",
	["Pavement"] = "Concrete",
	["ForceField"] = "Tile",
	["Gravel"] = "Gravel",
	["Dust"] = "Dust"
}

function ProcessAudioTrack(track: AnimationTrack, Parent: BasePart?)
	local con; con = track:GetMarkerReachedSignal("audio"):Connect(function(param: string)
		if Parent == nil then -- immediately disconnect the signal connections and return void
			con:Disconnect()
			return
		end
		if param ~= nil then
			if param == "step" then
				local m: RaycastResult = Raycaster:Cast(Parent.Position, Parent.CFrame:ToWorldSpace(CFrame.new(0, -4, 0)).Position - Parent.Position)
				local l: RaycastResult = Raycaster:Cast(Parent.Position, Parent.CFrame:ToWorldSpace(CFrame.new(0.75, -4, 0)).Position - Parent.Position)
				local r: RaycastResult = Raycaster:Cast(Parent.Position, Parent.CFrame:ToWorldSpace(CFrame.new(-0.75, -4, 0)).Position - Parent.Position)
				if m ~= nil or l ~= nil or r ~= nil then
					local r = m or l or r
					local v = (StepVars[r.Instance.Name] or StepVars[r.Material.Name]) or "Concrete"
					local f = SoundService.Footsteps[v]:GetChildren()
					local s: Sound = f[math.random(1, #f)]:Clone()
					s.Parent = Parent;
					s.PlaybackSpeed += (math.random(98, 102) / 100) - 1
					s.Volume = s.Volume
					s:Play()
					task.delay(s.TimeLength, function()
						s:Destroy()
					end)
				end
			elseif param == "step2" then
				local m: RaycastResult = Raycaster:Cast(Parent.Position, Parent.CFrame:ToWorldSpace(CFrame.new(0, -4, 0)).Position - Parent.Position)
				local l: RaycastResult = Raycaster:Cast(Parent.Position, Parent.CFrame:ToWorldSpace(CFrame.new(0.75, -4, 0)).Position - Parent.Position)
				local r: RaycastResult = Raycaster:Cast(Parent.Position, Parent.CFrame:ToWorldSpace(CFrame.new(-0.75, -4, 0)).Position - Parent.Position)
				if m ~= nil or l ~= nil or r ~= nil then
					local r = m or l or r
					local v = (StepVars[r.Instance.Name] or StepVars[r.Material.Name]) or "Concrete"
					local f = SoundService.Footsteps[v]:GetChildren()
					local s: Sound = f[math.random(1, #f)]:Clone()
					s.Parent = Parent;
					s.PlaybackSpeed += (math.random(98, 102) / 100) - 1
					s.Volume = s.Volume * .3
					s:Play()
					task.delay(s.TimeLength, function()
						s:Destroy()
					end)
				end
			elseif param == "step3" then
				local m: RaycastResult = Raycaster:Cast(Parent.Position, Parent.CFrame:ToWorldSpace(CFrame.new(0, -4, 0)).Position - Parent.Position)
				local l: RaycastResult = Raycaster:Cast(Parent.Position, Parent.CFrame:ToWorldSpace(CFrame.new(0.75, -4, 0)).Position - Parent.Position)
				local r: RaycastResult = Raycaster:Cast(Parent.Position, Parent.CFrame:ToWorldSpace(CFrame.new(-0.75, -4, 0)).Position - Parent.Position)
				if m ~= nil or l ~= nil or r ~= nil then
					local r = m or l or r
					local v = (StepVars[r.Instance.Name] or StepVars[r.Material.Name]) or "Concrete"
					local f = SoundService.Footsteps[v]:GetChildren()
					local s: Sound = f[math.random(1, #f)]:Clone()
					s.Parent = Parent;
					s.PlaybackSpeed += (math.random(98, 102) / 100) - 1
					s.Volume = s.Volume * .1
					s:Play()
					task.delay(s.TimeLength, function()
						s:Destroy()
					end)
				end
			end
		end
	end)
	return con
end

function GetState(): Enum.HumanoidStateType
	if Character ~= nil and Character:FindFirstChild('Humanoid') ~= nil then
		return Character.Humanoid:GetState()
	else
		return Enum.HumanoidStateType.None
	end
end

local Animator = {}

Animator.__index = Animator

function Animator.new()
	local AnimatorInstance = {}

	local Humanoid: Humanoid = Character:WaitForChild("Humanoid")
	local Root: BasePart = Character:WaitForChild("HumanoidRootPart")

	AnimatorInstance.__index = AnimatorInstance

	AnimatorInstance.Connections = {}
	AnimatorInstance.AnimationTable = {}
	AnimatorInstance.Speed = 0
	AnimatorInstance.State = 'None'
	AnimatorInstance.CoreAnimationInstance = nil
	AnimatorInstance.CoreAnimationTrack = nil
	AnimatorInstance.CoreName = ""
	local CoreAnimKeyframeHandler: RBXScriptConnection? = nil
	local AnimationInstances = {}
	local AnimationTracks = {}

	--[[ Clean-up process ]]

	function AnimatorInstance:Cleanup()
		-- Disconnnect all existing connections
		for _, conn in next, AnimatorInstance.Connections do
			if conn ~= nil then
				conn:Disconnect()
				task.wait()
				conn = nil
			end
		end
		pcall(function()
			-- Delete all animation tracks, instances, and animation table
			for _, n in next, AnimatorInstance.AnimationTable do
				if n.animTrack ~= nil then
					n.animTrack:Destroy()
				end
				if n.anim ~= nil then
					n.anim:Destroy()
				end
			end
		end)
		for _, animaton in next, AnimationInstances do
			if animaton ~= nil then
				animaton:Destroy()
			end
		end
		for _, animationTrack in next, AnimationInstances do
			if animationTrack ~= nil then
				animationTrack:Stop()
				animationTrack:Destroy()
			end
		end
		AnimatorInstance.CoreAnimationTrack:Stop()
		AnimatorInstance.CoreAnimationTrack:Destroy()
		AnimatorInstance.CoreAnimationInstance:Destroy()
		-- Clear all tables
		table.clear(AnimatorInstance.AnimationTable)
		table.clear(AnimationInstances)
		table.clear(AnimationTracks)
		-- Return nil
		AnimatorInstance = nil
		-- Return finish
		return
	end

	--[[ Initialization ]]

	for name: string, list: table in next, Animations.Animations do
		AnimatorInstance.AnimationTable[name] = {}
		AnimatorInstance.AnimationTable[name].anim = Instance.new("Animation")
		AnimatorInstance.AnimationTable[name].anim.Name = name
		AnimatorInstance.AnimationTable[name].anim.AnimationId = list[1]
		AnimatorInstance.AnimationTable[name].animTrack = Humanoid:LoadAnimation(AnimatorInstance.AnimationTable[name].anim)
		AnimatorInstance.AnimationTable[name].animTrack.Priority = Enum.AnimationPriority.Core
		ProcessAudioTrack(AnimatorInstance.AnimationTable[name].animTrack, Root)
		AnimatorInstance.AnimationTable[name].animTrack:GetMarkerReachedSignal("pause"):Connect(function()
			AnimatorInstance.AnimationTable[name].animTrack:AdjustSpeed(0)
		end)
		-- Can be modified to take into more animations, for dynamics, but uh, too much overhead
	end

	for name: string, list: table in next, Animations.Emotes do
		AnimatorInstance.AnimationTable[name] = {}
		AnimatorInstance.AnimationTable[name].anim = Instance.new("Animation")
		AnimatorInstance.AnimationTable[name].anim.Name = name
		AnimatorInstance.AnimationTable[name].anim.AnimationId = list[1]
		AnimatorInstance.AnimationTable[name].animTrack = Humanoid:LoadAnimation(AnimatorInstance.AnimationTable[name].anim)
		ProcessAudioTrack(AnimatorInstance.AnimationTable[name].animTrack, Root)
		AnimatorInstance.AnimationTable[name].animTrack:GetMarkerReachedSignal("pause"):Connect(function()
			AnimatorInstance.AnimationTable[name].animTrack:AdjustSpeed(0)
		end)
		-- Can be modified to take into more animations, for dynamics, but uh, too much overhead
	end

	--[[ Private Methods ]]

	local function keyframeReachedFunc(fn)
		if fn == "End" then
			local curAnim = AnimatorInstance.CoreAnimationInstance.Name
			if Animations.Emotes[curAnim] ~= nil then
				curAnim = "idle"
			end
			AnimatorInstance:PlayCoreAnimation(curAnim, 0.1, 1)
		end
	end

	--[[ Animator Methods ]]

	function AnimatorInstance:StopAllAnimations()
		for _, animationTrack: AnimationTrack in next, AnimationTracks do
			if animationTrack ~= nil then
				animationTrack:Stop()
				animationTrack:Destroy()
			end
		end
	end

	function AnimatorInstance:SetAnimationSpeed(speed)
		if AnimatorInstance.CoreAnimationTrack ~= nil then
			AnimatorInstance.CoreAnimationTrack:AdjustSpeed(speed)
		end
	end

	function AnimatorInstance:StopAnimation(name, transition)
		if AnimationTracks[name] ~= nil then
			AnimationTracks[name]:Stop(transition)
			AnimationTracks[name]:Destroy()
		end
	end

	function AnimatorInstance:PlayAnimation(anim, transition, options): AnimationTrack
		if AnimationTracks[anim.name] ~= nil then
			AnimationTracks[anim.name]:Stop(transition)
			AnimationTracks[anim.name]:Destroy()
		end

		AnimationTracks[anim.name] = Humanoid:LoadAnimation(anim)
		if options then -- pre-settings
			if options["priority"] ~= nil then
				AnimationTracks[anim.name].Priority = options["priority"]
			end
		end
		AnimationTracks[anim.name]:Play(transition)
		if options then -- post-settings
			if options["speed"] ~= nil then
				AnimationTracks[anim.name]:AdjustSpeed(options["speed"])
			end
		end
		AnimationInstances[anim.name] = anim

		return AnimationTracks[anim.name]
	end
	
	function AnimatorInstance:PlayCoreAnimation(name, transition, speed): AnimationTrack
		local animate = AnimatorInstance.AnimationTable[name]

		if animate == nil then
			return nil
		end

		if animate.anim ~= AnimatorInstance.CoreAnimationInstance then
			if AnimatorInstance.CoreAnimationTrack ~= nil then
				AnimatorInstance.CoreAnimationTrack:Stop(transition)
			end

			AnimatorInstance.CoreName = name
			AnimatorInstance.CoreAnimationTrack = animate.animTrack
			AnimatorInstance.CoreAnimationTrack.Priority = Enum.AnimationPriority.Core
			AnimatorInstance.CoreAnimationTrack:Play(transition, 10, speed)
			AnimatorInstance.CoreAnimationInstance = animate.anim

			if CoreAnimKeyframeHandler ~= nil then
				CoreAnimKeyframeHandler:Disconnect()
			end
			CoreAnimKeyframeHandler = AnimatorInstance.CoreAnimationTrack.KeyframeReached:connect(keyframeReachedFunc)

			return AnimatorInstance.CoreAnimationTrack
		end
	end
	
	function AnimatorInstance:PlayEmote(emote)
		if AnimatorInstance.State ~= "Standing" then
			return
		end
		AnimatorInstance:PlayCoreAnimation(emote, 0.2, 1)
	end

	local function setSpeed(speed: number)
		AnimatorInstance.Speed = speed
		AnimatorInstance:SetAnimationSpeed(speed)
	end

	local function getTP()
		return AnimatorInstance.CoreAnimationTrack.TimePosition
	end

	local function setTP(pos: number)
		game.TweenService:Create(
			AnimatorInstance.CoreAnimationTrack,
			TweenInfo.new(.1),
			{
				TimePosition = pos
			}
		):Play()
	end
	
	local curVMState = Player:GetAttribute('DisableViewmodel') or false
	
	local function disableViewmodel(bool)
		if curVMState == bool then
			return
		end
		curVMState = bool
		Player:SetAttribute('DisableViewmodel', bool)
	end
	
	local _JumpTime = tick()

	AnimatorInstance.StateFunctions = {
		["Running"] = function(speed: number)
			-- dirty way of keeping track of speed lololol
			AnimatorInstance.Speed = speed or AnimatorInstance.Speed
			speed = AnimatorInstance.Speed
			if Character:FindFirstChild('Humanoid') and Character.Humanoid.Sit then
				AnimatorInstance.State = "Sitting"
				AnimatorInstance:PlayCoreAnimation("sit", 0.3, 1)
			elseif Player:GetAttribute("Crawling") then
				disableViewmodel(true)
				AnimatorInstance.State = "Crawling"
				if speed > 0.1 then
					AnimatorInstance:PlayCoreAnimation("crawl", 0.3, (speed + 1) / 3)
					setSpeed((speed + 1) / 3)
				else
					if AnimatorInstance.CoreAnimationInstance.Name ~= "crawl" then
						AnimatorInstance:PlayCoreAnimation("crawl", 0.3, 0.3)
						setSpeed(0)
					end
					local tp = getTP()
					if tp > .5 and tp <= 1.5  then
						setTP(1)
					elseif tp > 1.5 then
						setTP(1.99)
					else
						setTP(0)
					end
					setSpeed(0)
				end
			elseif Player:GetAttribute("Crouching") then
				disableViewmodel(true)
				AnimatorInstance.State = "Crouching"
				if speed > 0.1 then
					AnimatorInstance:PlayCoreAnimation("crouch", 0.3, (speed + 1) / 14)
					setSpeed((speed + 1) / 14)
				else
					if AnimatorInstance.CoreAnimationInstance.Name ~= "crouch" then
						AnimatorInstance:PlayCoreAnimation("crouch", 0.3, 1)
						setSpeed(0)
					end
					local tp = getTP()
					if tp > (.83 / 4) and tp <= ((.83 / 4) * 3)  then
						setTP(((.83 / 4) * 2))
					elseif tp > ((.83 / 4) * 3) then
						setTP(.82)
					else
						setTP(0)
					end
					setSpeed(0)
				end
			elseif Player:GetAttribute('Running') and (speed > 1) then
				disableViewmodel(false)
				AnimatorInstance.State = "Running"
				AnimatorInstance:PlayCoreAnimation("run", .2, math.clamp(speed / 24, 0, 2))
				setSpeed(math.clamp(speed / 26, 0, 2))
			elseif speed > 0.1 then
				disableViewmodel(false)
				AnimatorInstance.State = "Walking"
				AnimatorInstance:PlayCoreAnimation("walk", 0.2, speed / 14)
				setSpeed(speed / 14)
			elseif Humanoid.HipHeight > -1 then
				disableViewmodel(false)
				Player:SetAttribute('DisableViewmodel', false)
				AnimatorInstance.State = "Standing"
				AnimatorInstance:PlayCoreAnimation("idle", 0.2, .2) -- looks like they're panting, add little detail that uses workflow to display this?
			end
		end,
		["Jumping"] = function()
			disableViewmodel(false)
			local _JumpTime = tick() + .4
			AnimatorInstance.State = "Jumping"
			AnimatorInstance:PlayCoreAnimation("jump", 0.15, 1)
		end,
		["Climbing"] = function(speed: number)
			disableViewmodel(false)
			AnimatorInstance.Speed = speed
			AnimatorInstance.State = "Climbing"
			setSpeed(speed / 12)
			AnimatorInstance:PlayCoreAnimation("climb", 0.1, speed / 12)
		end,
		["FreeFalling"] = function()
			if AnimatorInstance.State ~= "Crawling" and _JumpTime < tick() then
				disableViewmodel(false)
				AnimatorInstance.State = "FreeFalling"
				AnimatorInstance:PlayCoreAnimation("fall", 0.1, 1)
			end
		end,
	}

	--[[ State Connection Initialization ]]

	for state, callback in next, AnimatorInstance.StateFunctions do
		AnimatorInstance.Connections[state] = Humanoid[state]:Connect(callback)
	end

	-- dirty way of loading animations instantly

	for _, anim in next, AnimatorInstance.AnimationTable do
		if typeof(anim) == "Instance" and anim:IsA("Animation") then
			local t = Humanoid.Animator:LoadAnimation(anim.anim)
			t:Play()
			t:Stop()
			t:Destroy()
		end
	end
	
	local acceptedStates = {
		["Running"] = true,
		["Walking"] = true,
		["Crouching"] = true,
		["Crawling"] = true
	}

	Player:SetAttribute('Running', Player:GetAttribute('Running') or false)
	Player:SetAttribute('Crouching', Player:GetAttribute('Crouching') or false)
	Player:SetAttribute('Crawling', Player:GetAttribute('Crawling') or false)

	--AnimatorInstance.Connections["runningAttr"] = Player:GetAttributeChangedSignal("Running"):Connect(AnimatorInstance.StateFunctions["Running"])
	AnimatorInstance.Connections["crouchAttr"] = Player:GetAttributeChangedSignal("Crouching"):Connect(function()
		task.wait(0.1)
		AnimatorInstance.StateFunctions["Running"](Player.Character.HumanoidRootPart.Velocity.Magnitude)
	end)
	AnimatorInstance.Connections["crawlAttr"] = Player:GetAttributeChangedSignal("Crawling"):Connect(function()
		task.wait(0.1)
		AnimatorInstance.StateFunctions["Running"](Player.Character.HumanoidRootPart.Velocity.Magnitude)
	end)

	--Character.ChildAdded:Connect(function(inst)
	--	if inst:IsA('Tool') then
	--		task.wait(.01)
	--		AnimatorInstance.AnimationTable["tool"].animTrack:Play(.1)
	--	end
	--end)

	--Character.ChildRemoved:Connect(function(inst)
	--	if inst:IsA('Tool') then
	--		AnimatorInstance.AnimationTable["tool"].animTrack:Stop(.1)
	--	end
	--end)
	
	AnimatorInstance.Connections["RenderstepChecks"] = RunService.RenderStepped:Connect(function()
		if Root ~= nil and Humanoid ~= nil and AnimatorInstance.State == "Crawling" and (Root.Velocity * Vector3.new(1,0,1)).Magnitude > Humanoid.WalkSpeed + 10 then
			Root.Velocity = Vector3.new(0,0,0)
			Root.CFrame += Vector3.new(0,.1,0)
		end
	end)

	return AnimatorInstance
end

local AnimHandler = nil;

local dances = {"dance1", "dance2"}
local extraDances = {"shuffle", "carlton", "sponge", "cory", "praise", "smooth", "gaming", "shanty", "pp", "default", "torture", "aerostep", "robics"}

local emoteNames = { pat = true, boop = true, uamshanty = true, wave = false, point = false, dance1 = true, dance2 = true, laugh = false, cheer = false,
	shuffle = true, carlton = true, sponge = true, cory = true, praise = true, smooth = true, gaming = true, shanty = true,
	pp = true, default = true, torture = true, aerostep = true, robics = true, chill = true, chillback = true, chillsit = true,
	lay = true, salute = true }

Player.Chatted:connect(function(msg)
	local emote = ""
	if msg == "/e dance" then
		emote = dances[math.random(1, #dances)]
	elseif msg == "/e dances" then
		emote = extraDances[math.random(1, #extraDances)]
	elseif (string.sub(msg, 1, 3) == "/e ") then
		emote = string.sub(msg, 4)
	elseif (string.sub(msg, 1, 7) == "/emote ") then
		emote = string.sub(msg, 8)
	end

	if (emoteNames[emote] ~= nil) then
		AnimHandler:PlayEmote(emote)
	end
end)

function characterAdded(character)
	Character = character
	AnimHandler = Animator.new(character)
	local Humanoid: Humanoid = Character:FindFirstChild('Humanoid')
	if Humanoid then
		local dead: RBXScriptConnection?; dead = Humanoid.Died:Connect(function()
			dead:Disconnect()
			AnimHandler:Cleanup()
		end)
	end
end

if Player.Character ~= nil then
	characterAdded(Player.Character)
end

Player.CharacterAdded:Connect(characterAdded)

function playerAdded(player: Player)
	player.CharacterAdded:Connect(function(char)
		task.wait(5) -- wait for registrating
		local anims = {}
		local Humanoid: Humanoid = char:FindFirstChild('Humanoid')
		local Root: BasePart = char:FindFirstChild('HumanoidRootPart')
		if Humanoid ~= nil then
			Humanoid.AnimationPlayed:Connect(function(track)
				if anims[track.Name] == nil then
					ProcessAudioTrack(track, Root)
					anims[track.Name] = true
				end
			end)
			Humanoid.Died:Connect(function()
				table.clear(anims)
			end)
		end
	end)
end

for _, player: Player in next, Players:GetPlayers() do
	playerAdded(player)
end

Players.PlayerAdded:Connect(playerAdded)