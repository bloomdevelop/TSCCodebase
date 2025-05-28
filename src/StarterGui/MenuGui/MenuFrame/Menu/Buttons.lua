-- // Steven_Scripts, 2022

local rst = game:GetService("ReplicatedStorage")
local stg = game:GetService("StarterGui")
local ss = game:GetService("SoundService")
local tws = game:GetService("TweenService")

local remotesFolder = rst.Remotes

local plr = game.Players.LocalPlayer

local plrGui = plr:WaitForChild("PlayerGui")

local menuFrame = script.Parent.Parent	
local cover = menuFrame.Parent.Cover
local sidebar = menuFrame.Sidebar

local sounds = menuFrame.Sounds

local camera = workspace.CurrentCamera

local colorCorrect = Instance.new("ColorCorrectionEffect")
colorCorrect.Parent = camera

local shutdownTween1 = tws:Create(cover.ShutdownEffect, TweenInfo.new(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 2)})
local shutdownTween2 = tws:Create(cover.ShutdownEffect, TweenInfo.new(.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 2)})

local fadeOutTween = tws:Create(cover, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {BackgroundTransparency = 0})
local fadeInTween = tws:Create(cover, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {BackgroundTransparency = 1})

local buttonLiftPosition = UDim2.new(0, 3, 0, -3)
local buttonHoverPosition = UDim2.new(0, 2, 0, -2)
local buttonHoldPosition = UDim2.new(0, 0, 0, 0)

local selectedUI = nil

local ignoredTeams = {
	["Menu"] = true,
	["Latex"] = true
}

local buttonObject = {}
buttonObject.__index = buttonObject

local viewButtonObjectDictionary = {}

local function closeUI()
	local oldbuttonObject = viewButtonObjectDictionary[selectedUI]
	selectedUI.Visible = false
	oldbuttonObject.Light.On.Visible = false
	selectedUI = nil
end

function buttonObject.new(ButtonFrame)
	local self = setmetatable({}, buttonObject)

	-- print("okie")

	local button = ButtonFrame.Button
	local details = ButtonFrame.Top
	local light = details.Light

	local buttonType = ButtonFrame.ButtonType.Value

	self.Button = button
	self.Details = details
	self.Light = light
	self.ButtonType = ButtonFrame.ButtonType.Value

	if buttonType == "view" then
		local viewUI = ButtonFrame.ViewUI.Value
		if viewUI == nil then
			ButtonFrame.ViewUI:GetPropertyChangedSignal("Value"):Wait()
			viewUI = ButtonFrame.ViewUI.Value
		end
		self.UI = viewUI

		viewButtonObjectDictionary[viewUI] = self
	end

	-- print("hookin' up stuff")

	-- this absolutely does not feel right but I have no idea how else to do it
	button.MouseEnter:Connect(function()
		-- print("entered")
		self:OnMouseEnter()
	end)
	button.MouseLeave:Connect(function()
		self:OnMouseLeave()
	end)
	button.MouseButton1Down:Connect(function()
		self:OnMouseButton1Down()
	end)
	button.MouseButton1Up:Connect(function()
		self:OnMouseButton1Up()
	end)

	return self
end

function buttonObject:OpenUI()
	if selectedUI ~= nil then closeUI() end

	self.UI.Visible = true
	selectedUI = self.UI
end

function buttonObject:OnMouseButton1Down()
	sounds.ClickDown:Play()

	self.Details.Position = buttonHoldPosition

	self.Light.On.Visible = true
	self.Light.On.ImageColor3 = Color3.new(0, 1, 0)

	if self.ButtonType == "view" then
		if selectedUI == self.UI then
			closeUI()
		else
			self:OpenUI()
		end
	elseif self.ButtonType == "play" then
		local refreshGui = menuFrame.RefreshGui
		if refreshGui.Value == true then
			if ignoredTeams[plr.Team.Name] then
				sounds.Deny:Play()
				local label = sidebar.Buttons.Teams.Top.TextLabel
				for i=1, 3 do
					label.TextColor3 = Color3.new(1, 0, 0)
					task.wait(.15)
					label.TextColor3 = Color3.new(1, 1, 1)
					task.wait(.15)
				end
				return
			end
			if selectedUI ~= nil then closeUI() end

			refreshGui.Value = false

			sounds.Switch:Play()
			sounds.PowerDown:Play()
			-- sounds.Intro.TimePosition = 0.6
			-- sounds.Intro:Play()

			cover.ShutdownEffect.BackgroundTransparency = 0
			cover.BackgroundTransparency = 0

			menuFrame.Visible = false

			shutdownTween1:Play()
			task.wait(.3)
			shutdownTween2:Play()
			task.wait(.45)
			-- Reset stuff for later
			cover.ShutdownEffect.BackgroundTransparency = 1
			cover.ShutdownEffect.Size = UDim2.new(1, 0, 1, 0)

			task.wait(.5)

			remotesFolder.Teams.TeamChanger:InvokeServer("Start")
			-- ss.AmbientReverb = ("Hallway")

			task.wait(.5)

			plr.CameraMinZoomDistance = 7

			plrGui.InterfaceUI.Enabled = true

			fadeInTween:Play()

			sounds.WakeyWakey:Play()

			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = plr.Character:WaitForChild("Head")

			task.wait(4.5)

			plr.CameraMinZoomDistance = 0.5

			camera.CameraSubject = plr.Character

			stg:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
			stg:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
		end
	end
end

function buttonObject:OnMouseButton1Up()
	sounds.ClickUp:Play()

	if self.ButtonType ~= "view" then
		self.Light.On.ImageColor3 = Color3.new(1, 1, 1)
	end

	self.Details.Position = buttonHoverPosition
end

function buttonObject:OnMouseEnter(a, b, c, d)
	sounds.Hover:Play()

	local light = self.Light

	if self.ButtonType ~= "view" or selectedUI ~= self.UI then
		light.On.ImageColor3 = Color3.new(1, 1, 1)
		light.On.Visible = true
	end
	self.Details.Position = buttonHoverPosition
end

function buttonObject:OnMouseLeave()
	local light = self.Light

	if self.ButtonType ~= "view" or selectedUI ~= self.UI then
		light.On.Visible = false
	end
	self.Details.Position = buttonLiftPosition
end

-- print("got here")

for i,v in pairs(sidebar.Buttons:GetChildren()) do
	if v:IsA("Frame") then
		-- print("creatin'")
		buttonObject.new(v)
	end
end

return true