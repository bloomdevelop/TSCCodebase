Typing = require(script.Parent.Parent.Typing)
return function(Framework: Typing.FrameworkType)
	-- INITILAIZATION
	local Animator: Typing.AniamtorType = {}

	-- STRUCTURE
	
	function Animator.new(Character: Typing.CharacterType): selfType
		local animator = Framework.Modules.Immutable.JoinDictionaries({
			StateFunctions = {},
			Humanoid = Character:FindFirstChild('Humanoid') :: Humanoid,
			Character = Character,
			CoreAnimations = {},
			Animations = {},
			Tracks = {},
			CoreAnimationTrack = nil,
			CoreAnimation = nil,
			Connections = {},
			State = 'None',
			Speed = 1,
		}, Animator)
		
		return animator
	end
	
	-- PRIVATE METHODS

	local function keyframeReachedFunc(self, fn)
		if fn == "End" then
			local curAnim = self.CoreAnimation.Name
			if self.CoreAnimations[curAnim] ~= nil then
				curAnim = "idle"
			end
			self:PlayCoreAnimation(curAnim, 0.1, 1)
		end
	end
	
	-- PUBLIC METHODS
	
	function Animator.Cleanup(self: Typing.AnimatorInstanceType)
		for index, conn: RBXScriptConnection in next, self.Connections do
			conn:Disconnect()
		end
		for _, list: Typing.AnimationList in next, self.CoreAnimations do
			for _, index in next, list do
				index.animationTrack:Stop()
				index.animationTrack:Destroy()
				index.animation:Destroy()
			end
		end
		for _, track: AnimationTrack in next, self.Tracks do
			track.animationTrack:Stop()
			track.animationTrack:Destroy()
			track.animation:Destroy()
		end
		table.clear(self.Connections)
		table.clear(self.CoreAnimations)
		table.clear(self.Tracks)
		table.clear(self) -- bye
	end
	
	function Animator.Initialize(self: Typing.AnimatorInstanceType, animations: {}, stateFunctions: {})
		-- initialize animation instances
		for name: string, list: Typing.Array<string> | Typing.Array<{ id: string, weight: number}> in next, animations.Animations do
			self.CoreAnimations[name] = {}
			for index, indexed: string | Typing.RawAnimationIndex in next, list do
				local anim: Animation = Instance.new('Animation')
				anim.Name = name
				anim.AnimationId = (type(indexed) == "string") and indexed or indexed.id
				local track: AnimationTrack = self.Humanoid:LoadAnimation(anim)
				track.Priority = Enum.AnimationPriority.Core
				table.insert(self.CoreAnimations[name], {
					animation = anim,
					animationTrack = track,
					weight = (type(indexed) == "string") and 1 or indexed.id
				})
			end
		end
		for name: string, list: Typing.Array<string> in next, animations.Emotes do
			self.CoreAnimations[name] = {}
			for i, index: string | Typing.RawAnimationIndex in next, list do
				local anim: Animation = Instance.new('Animation')
				anim.Name = name
				anim.AnimationId = (type(index) == "string") and index or index.id
				local track: AnimationTrack = self.Humanoid:LoadAnimation(anim)
				track.Priority = Enum.AnimationPriority.Core
				table.insert(self.CoreAnimations[name], {
					animation = anim,
					animationTrack = track,
					weight = (type(index) == "string") and 1 or index.id
				})
			end
		end
		-- initialize state callbacks
		for state: string, callback: (...any) -> (...any) in next, stateFunctions do
			self.Connections[state] = self.Humanoid[state]:Connect(callback)
		end
		self.StateFunctions = stateFunctions
	end
	
	--function Animator.UpdateAnimations(self: Typing.AnimatorInstanceType, animations: {})
		
	--end
	
	function Animator.StopAnimation(self: Typing.AnimatorInstanceType, name: string, transition: number?)
		if self.Tracks[name] ~= nil then
			self.Tracks[name]:Stop(transition)
			self.Tracks[name]:Destroy()
		end
	end
	
	function Animator.StopAllAnimations(self: Typing.AnimatorInstanceType, transition: number?)
		for _, animationTrack: AnimationTrack in next, self.Tracks do
			if animationTrack ~= nil then
				animationTrack:Stop()
				animationTrack:Destroy()
			end
		end
	end
	
	function Animator.SetAnimationSpeed(self: Typing.AnimatorInstanceType, speed: number?)
		self.Speed = speed
		if self.CoreAnimationTrack then
			self.CoreAnimationTrack:AdjustSpeed(speed)
		end
	end
	
	function Animator.PlayAnimation(self: Typing.AnimatorInstanceType, anim: Animation, options: Typing.AnimatorOptionsType): AnimationTrack
		if self.Tracks[anim.Name] then
			self.Tracks[anim.Name]:Stop(options.transition or 0.1)
			self.Tracks[anim.Name]:Destroy()
		end
		
		self.Tracks[anim.Name] = self.Humanoid:LoadAnimation(anim)
		if options["priority"] and (typeof(options["priority"]) == "EnumItem") and (options["priority"].EnumType == Enum.AnimationPriority) then
			self.Tracks[anim.Name].Priority = options["priority"]
		end
		if options["weight"] and type(options["weight"]) == "number" then
			self.Tracks[anim.Name]:AdjustWeight(options["weight"])
		end
		self.Tracks[anim.Name]:Play(options.transition)
		if options["speed"] and type(options["speed"]) == "number" then
			self.Tracks[anim.Name]:AdjustSpeed(options["speed"])
		end
		
		return self.Tracks[anim.Name]
	end
	
	function Animator.PlayCoreAnimation(self: Typing.AnimatorInstanceType, name: string, transition: number, speed: number): AnimationTrack?
		if not self.CoreAnimations[name] then
			return Framework.Logger.debug("[ ANIMATOR / DEBUG ]", string.format('%s is not a valid animation name.', tostring(name)))
		end
		local selected = self.CoreAnimations[name][math.random(1, #self.CoreAnimations[name])]
		if not selected then
			return nil
		end
		if selected.animation ~= self.CoreAnimation then
			if self.CoreAnimationTrack then
				self.CoreAnimationTrack:Stop(transition)
			end

			if self.Connections["KeyframeHandler"] then
				self.Connections["KeyframeHandler"]:Disconnect()
			end
			self.CoreAnimationTrack = selected.animationTrack
			self.Connections["KeyframeHandler"] = self.CoreAnimationTrack.KeyframeReached:Connect(function(...) keyframeReachedFunc(self, ...) end)
			self.CoreAnimationTrack.Priority = Enum.AnimationPriority.Core
			self.CoreAnimationTrack:Play(transition, 10, speed)
			self.CoreAnimation = selected.animation
			
			return self.CoreAnimationTrack
		end
	end
	
	function Animator.PlayEmote(self: Typing.AnimatorInstanceType, emote: string)
		self.State = "Emoting"
		self:PlayCoreAnimation(emote, 0.2, 1)
	end

	function Animator.GetTimePosition(self: Typing.AnimatorInstanceType): number
		return self.CoreAnimationTrack.TimePosition
	end

	function Animator.SetTimePosition(self: Typing.AnimatorInstanceType, pos: number, transition: number?): number
		if not transition then
			self.CoreAnimationTrack.TimePosition = pos
		else
			Framework.Services.TweenService:Create(self.CoreAnimationTrack, TweenInfo.new(transition), { TimePosition = pos }):Play()
		end
	end

	-- FINALIZE

	Framework.Logger.debug('[ ANIMATOR / DEBUG ]', 'Initialized animator.')

	return Animator
end