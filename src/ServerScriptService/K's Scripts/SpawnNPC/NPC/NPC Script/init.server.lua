-- Services
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")
local ChatService = game:GetService("Chat")

-- ModuleScripts
local Ragdoller = require(script.RagdollScript)

-- Refs
local Char = script.Parent
local Hum = Char.Humanoid
local HRP = Char.HumanoidRootPart

-- Billboard GUI
local BillboardGui = script.BillboardGui; BillboardGui.Adornee = HRP; BillboardGui.Enabled = true

-- Billboard Refs
local NPCName = BillboardGui.Frame.NpcName; NPCName.Text = Hum.DisplayName
local HealthBar = BillboardGui.Frame.HealthDisplay
local HealthVal = BillboardGui.Frame.HealthValue;
local HealthUpdate = BillboardGui.Frame.HealthUpdate; HealthUpdate.Visible = false

-- Tween Info
local TI1 = TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
local TI2 = TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)

-- Script Variables
local PreviousHealth = 0
local DisplayingHealth, ChatDebounce = true, false

-- Regeneration Variables
local PendingHealing, Healing = false, false
local LastDamage = tick()

-- AI Variables
local Attacker = nil
local Wandering = false


local HurtPhrases = {
}


-- Friday Night Functions
local function Chat(text)
	coroutine.resume(coroutine.create(function()
		if ChatDebounce then return end
		ChatDebounce = true

		local Phrase = text
		if type(text) == "table" then if #text <= 0 then return end Phrase = text[math.random(1,#text)] end

		ChatService:Chat(Char.Head, Phrase, Enum.ChatColor.White)
		wait(5)
		ChatDebounce = false
	end))
end

local function DisplayHealth(bool)
	coroutine.resume(coroutine.create(function()
		if bool == DisplayingHealth then return end
		if bool then
			HealthVal:TweenPosition(UDim2.fromScale(0.83,0.7),TI2.EasingDirection,TI2.EasingStyle,TI2.Time,true)
			TweenService:Create(HealthVal,TI2,{TextTransparency = 0}):Play()
			TweenService:Create(HealthVal.UIStroke,TI2,{Transparency = 0}):Play()
		else
			HealthVal:TweenPosition(UDim2.fromScale(0.75,0.7),TI2.EasingDirection,TI2.EasingStyle,TI2.Time,true)
			TweenService:Create(HealthVal,TI2,{TextTransparency = 1}):Play()
			TweenService:Create(HealthVal.UIStroke,TI2,{Transparency = 1}):Play()
		end
		DisplayingHealth = bool
	end))
end

local function DisplayChange(HealthChange, Health)
	coroutine.resume(coroutine.create(function()
		local HealthChangeText = HealthUpdate:Clone()
		if HealthChange < 0 and Health >= 0 then
			HealthChangeText.TextColor3 = Color3.fromRGB(255, 0, 0)
		elseif Health > 0 then
			HealthChange = ("+" .. tostring(HealthChange))
		else HealthChangeText:Destroy() return end
		HealthChangeText.Text = (HealthChange)
		HealthChangeText.Visible = true; HealthChangeText.Parent = HealthUpdate.Parent
		HealthChangeText:TweenPosition(UDim2.fromScale(0.18,0.5),TI1.EasingDirection,TI1.EasingStyle,TI1.Time,true)
		TweenService:Create(HealthChangeText,TI1,{TextTransparency = 1}):Play()
		TweenService:Create(HealthChangeText.UIStroke,TI1,{Transparency = 1}):Play()
		wait(TI1.Time)
		HealthChangeText:Destroy()
	end))
end

local function RegenerationFunc()
	coroutine.resume(coroutine.create(function()
		if PendingHealing or Healing then return end
		PendingHealing = true
		wait(5)
		PendingHealing = false
		if Healing or not ((tick() - LastDamage) >= 5) then return end
		Healing = true
		while Hum.Health < Hum.MaxHealth and Hum.Health > 0 and ((tick() - LastDamage) >= 5) do
			Hum.Health += 1
			wait(1)
		end
		Healing = false
	end))
end

local function UpdateHealth()
	local Health = Hum.Health
	local MaxHealth = Hum.MaxHealth
	
	local HealthChange = Health - PreviousHealth
	
	PreviousHealth = Hum.Health
	
	-- Do Visual Stuff
	HealthVal.Text = (math.floor(Health) .. "/" .. math.floor(MaxHealth))
	HealthBar.Bar:TweenSize(UDim2.fromScale(Health/MaxHealth,1),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,0.5,true)
	DisplayChange(HealthChange, Health)
	if Health ~= MaxHealth and Health > 0 then DisplayHealth(true) else DisplayHealth(false) end
	
	-- Chat and Damage Timer
	if HealthChange < 0 and Health > 0 then Chat(HurtPhrases); LastDamage = tick() end
	
	-- Regeneration Queue
	RegenerationFunc()
end

UpdateHealth()
DisplayHealth(false)

Hum:GetPropertyChangedSignal("Health"):Connect(UpdateHealth)
Hum:GetPropertyChangedSignal("MaxHealth"):Connect(UpdateHealth)

Hum.Died:Connect(function()
	if Ragdoller then Ragdoller(Char) end
	wait(5)
	Char:Destroy()
end)

-- NPC Stuff

coroutine.resume(coroutine.create(function()
	if script:GetAttribute("AI") == true then
		while Hum.Health > 0 and Attacker == nil do -- Wander!
			local pos = HRP.Position
			Hum:MoveTo(Vector3.new(HRP.Position.X+math.random(0,20),HRP.Position.Y,HRP.Position.Z+math.random(0,20)))
			wait(10)
		end
	end
end))