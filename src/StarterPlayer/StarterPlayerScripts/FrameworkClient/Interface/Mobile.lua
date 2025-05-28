Typing = require(script.Parent.Parent.Typing)
return function(Framework: Typing.FrameworkType, Interface: Typing.InterfaceType)
	-- INITILAIZATION
	
	local Mobile = {
		Detected = false,
		UI = Interface.Mobile,
		Buttons = {}
	}
	
	for _, key: ImageButton | TextButton in pairs(Mobile.UI:GetChildren()) do
		if key:IsA("ImageButton") or key:IsA("TextButton") then
			Mobile.Buttons[key.Name] = key
		end
	end
	
	local DeniedStates = {
		[Enum.HumanoidStateType.Jumping] = true,
		[Enum.HumanoidStateType.Freefall] = true,
		[Enum.HumanoidStateType.FallingDown] = true
	}
	
	-- STRUCTURE
	
	local ButtonInput = {
		["run"] = {
			UI = Mobile.UI.RunButton,
			Func = function(Input: boolean): boolean
				if (Input) then
					if Framework.Interface.StatsPanel.Stamina > 0 then
						Framework.Playerstates.SetPositionState("sprint")
					else
						Framework.Playerstates.SetPositionState("none")
					end
				else
					Framework.Playerstates.SetPositionState("none")
				end
				return true
			end
		},
		["up"] = {
			UI = Mobile.UI.UpButton,
			Func = function(Input: boolean): boolean
				if (Input) then
					if Framework.Playerstates:GetPositionState() == "Crawling" then
						Framework.Playerstates.SetPositionState("crouch")
					elseif Framework.Playerstates:GetPositionState() == "Crouching" then
						Framework.Playerstates.SetPositionState("none")
					else
						Mobile:RequestJump()
					end
				end
				return true
			end
		},
		["down"] = {
			UI = Mobile.UI.DownButton,
			Func = function(Input: boolean): boolean
				if (Input) then
					if Framework.Playerstates:GetPositionState() ~= "Crawling" then
						if Framework.Playerstates:GetPositionState() ~= "Crouching" then
							Framework.Playerstates.SetPositionState("crouch")
						else
							Framework.Playerstates.SetPositionState("crawl")
						end
					end
				end
				return true
			end,
		}
	}
	
	function Mobile:RequestJump(): nil
		if Framework.Playerstates.Character and Framework.Playerstates.Character:FindFirstChild('Humanoid') and not (DeniedStates[Framework.Playerstates.Character.Humanoid:GetState()]) then
			Framework.Playerstates.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			Framework.Playerstates.Character.Humanoid.Jump = Framework.Playerstates.Character.Humanoid:GetAttribute("CanJump")
		end
	end
	
	function Mobile.IsMobile(): boolean
		return Mobile.Detected
	end
	
	function Mobile:SetState(bool: boolean)
		Mobile.UI.Visible = Mobile.Detected and bool
	end
	
	function Mobile:HandleInput(Button: ImageButton | TextButton, Input: boolean): nil
		if Mobile.Detected then
			for _, key in next, ButtonInput do
				if Button == key.UI then
					key.Func(Input)
					Framework.Logger.debug('[ MOBILE / DEBUG ]', 'Mobile Input Detected, Input: '.._)
				end
			end
		end
	end
	
	(Framework.Services.UserInputService :: UserInputService).InputBegan:Connect(function(io: InputObject, _)
		if io.UserInputType == Enum.UserInputType.Touch then
			if not (Mobile.Detected) then
				Framework.Logger.debug('[ MOBILE / DEBUG ]', 'Touch detected, switching to mobile.')
			end
			Mobile.Detected = true
			Mobile:SetState(true)
		else
			if (Mobile.Detected) then
				Framework.Logger.debug("[ MOBILE / DEBUG ]", "Non-Touch detected, mobile input disabled.")
			end
			Mobile.Detected = false
			Mobile:SetState(false)
		end
	end)
	
	for _, key: ImageButton | TextButton in next, Mobile.Buttons do
		key.InputBegan:Connect(function() Mobile:HandleInput(key, true) end)
		key.InputEnded:Connect(function() Mobile:HandleInput(key, false) end)
	end

	-- FINALIZE

	Interface.Mobile = Mobile
end