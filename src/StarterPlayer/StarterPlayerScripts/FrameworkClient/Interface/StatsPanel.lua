Typing = require(script.Parent.Parent.Typing)
return function(Framework: Typing.FrameworkType, Interface: Typing.InterfaceType)
	-- INITILAIZATION
	
	local StatsPanel = {
		UI = Interface.StatsPanel,
		HealthUI = nil,
		StaminaUI = nil,
		ContaminationUI = nil,
		Health = 100,
		MaxHealth = 100,
		Stamina = 100,
		MaxStamina = 100,
		Player = Framework.Services.Players.LocalPlayer :: Player,
		InjuriesFolder = nil :: Folder,
		OnPainkillers = false,
		PainkillerMultiplier = 1,
		MaxHealthPenalty = 0,
		MaxHealthFactor = nil,
		UninjuredMaxHealth = nil,
		Humanoid = nil :: Humanoid,
		StaminaBuff = 1,
		HasBrokenLeg = false,
		StaminaDecrease = nil,
		CreditRemote = Framework.Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpdateCredits"),
		NumberSpinner = require(Framework.Services.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("NumberSpinner")),
		CreditSpinner = nil,
		StaminaBool = 0,
		LatexValues = nil,
		InfectionLevel = nil,
		MaxInfectionValue = nil,
		FullImmunity = nil,
		ContaminationUIDisplay = false,
		CIP = nil,
		Infected = require(Framework.Services.ReplicatedStorage:WaitForChild("InfectedCheckModule"))
	}
	
	StatsPanel.HealthUI = StatsPanel.UI.Stats.Health
	StatsPanel.StaminaUI = StatsPanel.UI.Stats.Stamina
	StatsPanel.ContaminationUI = StatsPanel.UI.Stats.Contamination
	StatsPanel.InjuriesFolder = StatsPanel.Player:FindFirstChild("Injuries") or StatsPanel.Player:WaitForChild("Injuries")
	StatsPanel.CreditSpinner = StatsPanel.NumberSpinner.new()

	-- STRUCTURE
	
	function StatsPanel:UpdateHealth(): nil
		if StatsPanel.Health >= 1e10 or StatsPanel.MaxHealth >= 1e10 then
			StatsPanel.HealthUI.Text.Text = "INFINITE"
			StatsPanel.HealthUI.Text.Health.Visible = false
			StatsPanel.HealthUI.Text.MaxHealth.Visible = false
			StatsPanel.HealthUI.Delayed.Fill:TweenSize(UDim2.new(1,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.1, true)
			StatsPanel.HealthUI.Total.Fill:TweenSize(UDim2.new(1,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.1, true)
		else
			StatsPanel.HealthUI.Text.Text = "/"
			StatsPanel.HealthUI.Text.Health.Visible = true
			StatsPanel.HealthUI.Text.MaxHealth.Visible = true
			StatsPanel.HealthUI.Text.Health.Text = tostring(math.round(StatsPanel.Health))
			StatsPanel.HealthUI.Text.MaxHealth.Text = tostring(math.round(StatsPanel.MaxHealth))
			
			StatsPanel.PainkillerMultiplier = 1
			StatsPanel.OnPainkillers = StatsPanel.Player:GetAttribute("PainkillerTimer") ~= nil
			if StatsPanel.OnPainkillers then
				StatsPanel.PainkillerMultiplier = 0.2
			end
			StatsPanel.MaxHealthPenalty = 0
			for i,Injury in pairs(StatsPanel.InjuriesFolder:GetChildren()) do
				StatsPanel.MaxHealthPenalty += 10
				if Injury.Name == "ArterialBleeding" then
					StatsPanel.MaxHealthPenalty += 10
				end
			end
			StatsPanel.MaxHealthPenalty *= StatsPanel.PainkillerMultiplier
			
			StatsPanel.UninjuredMaxHealth = StatsPanel.MaxHealth + StatsPanel.MaxHealthPenalty
			StatsPanel.MaxHealthFactor = StatsPanel.MaxHealth / StatsPanel.UninjuredMaxHealth
			
			if StatsPanel.MaxHealthPenalty > 0 then
				StatsPanel.HealthUI.Injury.Visible = true
				StatsPanel.HealthUI.Injury.Fill.Size = UDim2.new(0,-(StatsPanel.MaxHealthPenalty / StatsPanel.UninjuredMaxHealth) * 160,1,0)
			else
				StatsPanel.HealthUI.Injury.Visible = false
			end
			
			StatsPanel.HealthUI.Delayed.Fill:TweenSize(UDim2.new(0,math.clamp((StatsPanel.Health / StatsPanel.MaxHealth) * 160 * StatsPanel.MaxHealthFactor,0,160),1,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 1, true)
			StatsPanel.HealthUI.Total.Fill:TweenSize(UDim2.new(0,math.clamp((StatsPanel.Health / StatsPanel.MaxHealth) * 160 * StatsPanel.MaxHealthFactor,0,160),1,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.1, true)
		end
	end
	
	function StatsPanel:UpdateStamina(Step): nil
		StatsPanel.StaminaBuff = StatsPanel.Player.Character:GetAttribute("StaminaBuff") or 1
		StatsPanel.HasBrokenLeg = false
		StatsPanel.OnPainkillers = StatsPanel.Player:GetAttribute("PainkillerTimer") ~= nil
		
		if StatsPanel.InjuriesFolder ~= nil and StatsPanel.InjuriesFolder:FindFirstChild("BrokenLeg") ~= nil then
			StatsPanel.HasBrokenLeg = true
			StatsPanel.StaminaUI.Text.Visible = true
		else
			StatsPanel.StaminaUI.Text.Visible = false
		end
		
		if Framework.Playerstates:GetPositionState() == "Running" then
			if StatsPanel.Stamina <= 0 then
				Framework.Playerstates.SetPositionState("none")
				if StatsPanel.StaminaBool <= 2 then
					StatsPanel.StaminaBool = 2
				end
			else
				StatsPanel.StaminaDecrease = 5 / StatsPanel.StaminaBuff
				if StatsPanel.HasBrokenLeg then
					StatsPanel.StaminaDecrease *= 4
					if StatsPanel.OnPainkillers then
						StatsPanel.StaminaDecrease *= 0.2
					end
				end
				
				if StatsPanel.Infected(StatsPanel.Player) then
					StatsPanel.StaminaDecrease *= 0.9
				end
				
				StatsPanel.StaminaDecrease *= Step
				
				StatsPanel.Stamina -= StatsPanel.StaminaDecrease
				if StatsPanel.StaminaBool <= 1 then
					StatsPanel.StaminaBool += 1
				end
			end
		else
			if StatsPanel.StaminaBool <= 0 then
				if Framework.Playerstates:GetPositionState() == "Crouching" or Framework.Playerstates:GetPositionState() == "Crawling" then
					StatsPanel.StaminaBuff += 1
				end
				StatsPanel.Stamina += 15 * StatsPanel.StaminaBuff * Step
			end
		end
		
		if StatsPanel.Stamina < 0 then
			StatsPanel.Stamina = 0
		elseif StatsPanel.Stamina > StatsPanel.MaxStamina then
			StatsPanel.Stamina = StatsPanel.MaxStamina
		end
		
		if StatsPanel.Stamina >= StatsPanel.MaxStamina then
			StatsPanel.StaminaUI.Total.Fill:TweenSize(UDim2.new(1,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.1, true)
		else
			StatsPanel.StaminaUI.Total.Fill.Size = UDim2.new(0,(StatsPanel.Stamina / StatsPanel.MaxStamina) * 160,1,0)
		end
	end
	
	function StatsPanel:UpdateCredits(Value): nil
		if StatsPanel.UI.Credit.Frame:FindFirstChild("UIListLayout") and StatsPanel.UI.Credit.Frame.UIListLayout.HorizontalAlignment ~= Enum.HorizontalAlignment.Left then
			StatsPanel.UI.Credit.Frame.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		end
		if StatsPanel.UI.Credit.Frame:FindFirstChild("Prefix") then
			StatsPanel.UI.Credit.Frame.Prefix:Destroy()
		end
		StatsPanel.CreditSpinner.Value = Value
	end
	
	function StatsPanel:UpdateContamination(): nil
		local function ToggleContaminationUI(Bool: boolean)
			if StatsPanel.ContaminationUIDisplay ~= Bool then
				StatsPanel.ContaminationUIDisplay = Bool
				if Bool then
					StatsPanel.UI:TweenSize(UDim2.new(0,200,0,95), Enum.EasingDirection.Out, Enum.EasingStyle.Bounce, 1, true)
				else
					StatsPanel.UI:TweenSize(UDim2.new(0,200,0,65), Enum.EasingDirection.Out, Enum.EasingStyle.Bounce, 1, true)
				end
			end
		end
		
		if StatsPanel.Infected(StatsPanel.Player) then
			ToggleContaminationUI(true)
			StatsPanel.ContaminationUI.Text.Text = "INFECTED"
			StatsPanel.ContaminationUI.Text.Visible = true
			StatsPanel.ContaminationUI.Total.Fill:TweenSize(UDim2.new(1,0,1,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.3, true)
		elseif StatsPanel.FullImmunity.Value then
			ToggleContaminationUI(true)
			StatsPanel.ContaminationUI.Text.Text = "IMMUNE"
			StatsPanel.ContaminationUI.Text.Visible = true
			StatsPanel.ContaminationUI.Total.Fill:TweenSize(UDim2.new(0,0,1,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.3, true)
		elseif StatsPanel.InfectionLevel.Value > 0 then
			ToggleContaminationUI(true)
			StatsPanel.ContaminationUI.Text.Visible = false
			StatsPanel.ContaminationUI.Total.Fill:TweenSize(UDim2.new(0,(StatsPanel.InfectionLevel.Value / StatsPanel.MaxInfectionValue.Value) * 160,1,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.3, true)
		else
			ToggleContaminationUI(false)
			StatsPanel.ContaminationUI.Text.Visible = false
			StatsPanel.ContaminationUI.Total.Fill:TweenSize(UDim2.new(0,0,1,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.3, true)
		end
	end
	
	function StatsPanel:Load(Character): nil
		if not (Character) then return end
		Framework.Logger.debug("[ STATSPANEL / DEBUG ]", "Character Detected.")
		StatsPanel.Humanoid = nil
		StatsPanel.Humanoid = Character:FindFirstChildOfClass("Humanoid") or Character:WaitForChild("Humanoid")
		if (StatsPanel.Humanoid) then
			StatsPanel.Humanoid.Changed:Connect(function(key)
				if key == "MaxHealth" then
					StatsPanel.MaxHealth = StatsPanel.Humanoid.MaxHealth
				elseif key == "Health" then
					StatsPanel.Health = StatsPanel.Humanoid.Health
				end
				StatsPanel:UpdateHealth()
			end)
			StatsPanel.Stamina = StatsPanel.MaxStamina
			StatsPanel.MaxHealth = StatsPanel.Humanoid.MaxHealth
			StatsPanel.Health = StatsPanel.Humanoid.Health
			StatsPanel:UpdateHealth()
		end
		StatsPanel.InfectionLevel.Changed:Connect(function()
			StatsPanel:UpdateContamination()
		end)
		StatsPanel.MaxInfectionValue.Changed:Connect(function()
			StatsPanel:UpdateContamination()
		end)
		StatsPanel.FullImmunity.Changed:Connect(function()
			StatsPanel:UpdateContamination()
		end)
		StatsPanel.CIP.Changed:Connect(function()
			StatsPanel:UpdateContamination()
		end)
		StatsPanel.Player.Team.Changed:Connect(function()
			StatsPanel.UpdateContamination()
		end)
		StatsPanel:UpdateContamination()
	end

	-- FINALIZE
	
	StatsPanel.Player.CharacterAdded:Connect(function(Character)
		StatsPanel.LatexValues = Character:FindFirstChild("LatexValues") or Character:WaitForChild("LatexValues")
		StatsPanel.InfectionLevel = StatsPanel.LatexValues:FindFirstChild("InfectionLevel") or StatsPanel.LatexValues:WaitForChild("InfectionLevel")
		StatsPanel.MaxInfectionValue = StatsPanel.LatexValues:FindFirstChild("MaxInfectionValue") or StatsPanel.LatexValues:WaitForChild("MaxInfectionValue")
		StatsPanel.FullImmunity = StatsPanel.LatexValues:FindFirstChild("FullImmunity") or StatsPanel.LatexValues:WaitForChild("FullImmunity")
		StatsPanel.CIP = StatsPanel.LatexValues:FindFirstChild("IsCIP") or StatsPanel.LatexValues:WaitForChild("IsCIP")
		StatsPanel:Load(Character)
	end)
	
	if (StatsPanel.Player.Character) then
		StatsPanel.LatexValues = StatsPanel.Player.Character:FindFirstChild("LatexValues") or StatsPanel.Player.Character:WaitForChild("LatexValues")
		StatsPanel.InfectionLevel = StatsPanel.LatexValues:FindFirstChild("InfectionLevel") or StatsPanel.LatexValues:WaitForChild("InfectionLevel")
		StatsPanel.MaxInfectionValue = StatsPanel.LatexValues:FindFirstChild("MaxInfectionValue") or StatsPanel.LatexValues:WaitForChild("MaxInfectionValue")
		StatsPanel.FullImmunity = StatsPanel.LatexValues:FindFirstChild("FullImmunity") or StatsPanel.LatexValues:WaitForChild("FullImmunity")
		StatsPanel.CIP = StatsPanel.LatexValues:FindFirstChild("IsCIP") or StatsPanel.LatexValues:WaitForChild("IsCIP")
		StatsPanel:Load(StatsPanel.Player.Character)
	end
	
	StatsPanel.CreditSpinner.Duration = 0.5
	StatsPanel.CreditSpinner.Decimals = 0
	StatsPanel.CreditSpinner.Parent = StatsPanel.UI.Credit
	StatsPanel.CreditSpinner.Position = UDim2.new(0,30,0,0)
	StatsPanel.CreditSpinner.Size = UDim2.new(1,-30,1,0)
	StatsPanel.CreditSpinner.TextSize = 20
	StatsPanel.CreditSpinner.TextStrokeTransparency = 0.75
	StatsPanel.CreditSpinner.TextStrokeColor3 = Color3.new(0,0,0)
	StatsPanel.CreditSpinner.TextTransparency = 0.1
	StatsPanel.CreditSpinner.Font = Enum.Font.Gotham
	StatsPanel:UpdateCredits(0)
	StatsPanel.CreditRemote.OnClientEvent:Connect(function(Value)
		StatsPanel:UpdateCredits(Value)
	end)
	
	Framework.Services.RunService.RenderStepped:Connect(function(Step)
		StatsPanel:UpdateStamina(Step)
	end)
	
	coroutine.wrap(function()
		while task.wait(1) do
			if StatsPanel.StaminaBool > 0 then
				StatsPanel.StaminaBool -= 1
			end
		end
	end)()

	Interface.StatsPanel = StatsPanel
end