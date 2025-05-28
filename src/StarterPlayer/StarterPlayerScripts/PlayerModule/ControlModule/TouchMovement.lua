--[[
	// FileName: TouchJump
	// Version 1.0
	// Written by: jmargh
	// Description: Implements jump controls for touch devices. Use with Thumbstick and Thumbpad
--]]

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

--[[ Constants ]]--
local TOUCH_CONTROL_SHEET = "rbxasset://textures/ui/Input/TouchControlsSheetV2.png"

--[[ The Module ]]--
local BaseCharacterController = require(script.Parent:WaitForChild("BaseCharacterController"))
local TouchMovement = setmetatable({}, BaseCharacterController)
TouchMovement.__index = TouchMovement

function TouchMovement.new()
	local self = setmetatable(BaseCharacterController.new() :: any, TouchMovement)

	self.parentUIFrame = nil
	self.buttons = nil
	--self.characterAddedConn = nil
	--self.humanoidStateEnabledChangedConn = nil
	--self.humanoidParentConn = nil
	--self.externallyEnabled = false
	--self.humanoid = nil -- saved reference because property change connections are made using it

	return self
end

function TouchMovement:EnableButton(enable)
	if enable then
		if not self.buttons then
			self:Create()
		end
	else
	end
end

function TouchMovement:UpdateEnabled()
	if nil then
		self:EnableButton(true)
	else
		self:EnableButton(false)
	end
end

function TouchMovement:HumanoidChanged(prop)
	local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
	end
end

function TouchMovement:HumanoidStateEnabledChanged(state, isEnabled)
	if state == Enum.HumanoidStateType.Jumping then
		self.jumpStateEnabled = isEnabled
		self:UpdateEnabled()
	end
end

function TouchMovement:CharacterAdded(char)
	if self.humanoidChangeConn then
		self.humanoidChangeConn:Disconnect()
		self.humanoidChangeConn = nil
	end

	self.humanoid = char:FindFirstChildOfClass("Humanoid")
	while not self.humanoid do
		char.ChildAdded:wait()
		self.humanoid = char:FindFirstChildOfClass("Humanoid")
	end

	self.humanoidWalkSpeedConn = self.humanoid:GetPropertyChangedSignal("Walkspeed"):Connect(function()
		--self.speed = self.humanoid.WalkSpeed
		self:UpdateEnabled()
	end)

	self.humanoidParentConn = self.humanoid:GetPropertyChangedSignal("Parent"):Connect(function()
		if not self.humanoid.Parent then
			self.humanoidWalkSpeedConn:Disconnect()
			self.humanoidJumpPowerConn = nil
			self.humanoidParentConn:Disconnect()
			self.humanoidParentConn = nil
		end
	end)

	self.humanoidStateEnabledChangedConn = self.humanoid.StateEnabledChanged:Connect(function(state, enabled)
		self:HumanoidStateEnabledChanged(state, enabled)
	end)

	self.walkSpeed = self.humanoid.WalkSpeed
	self.movementStateEnabled = self.humanoid:GetStateEnabled(Enum.HumanoidStateType.Running)
	self:UpdateEnabled()
end

function TouchMovement:SetupCharacterAddedFunction()
	self.characterAddedConn = Players.LocalPlayer.CharacterAdded:Connect(function(char)
		self:CharacterAdded(char)
	end)
	if Players.LocalPlayer.Character then
		self:CharacterAdded(Players.LocalPlayer.Character)
	end
end

function TouchMovement:Enable(enable, parentFrame)
	if parentFrame then
		self.parentUIFrame = parentFrame
	end
	self.externallyEnabled = enable
	self:EnableButton(enable)
end

function TouchMovement:Create()
	if not self.parentUIFrame then
		return
	end

	if self.buttons then
		for _, button in next, self.buttons do
			button:Destroy()
		end
		self.buttons = nil
	end

	local minAxis = math.min(self.parentUIFrame.AbsoluteSize.x, self.parentUIFrame.AbsoluteSize.y)
	local isSmallScreen = minAxis <= 500
	local jumpButtonSize = isSmallScreen and 40 or 90
	
	self.buttons = {}
	
	self.buttons.sprint = Instance.new("ImageButton")
	self.buttons.sprint.Name = "SprintButton"
	self.buttons.sprint.Visible = false
	self.buttons.sprint.BackgroundTransparency = 1
	self.buttons.sprint.Image = TOUCH_CONTROL_SHEET
	self.buttons.sprint.ImageRectOffset = Vector2.new(1, 146)
	self.buttons.sprint.ImageRectSize = Vector2.new(144, 144)
	self.buttons.sprint.Size = UDim2.new(0, jumpButtonSize, 0, jumpButtonSize)

    self.jumpButton.Position = isSmallScreen and UDim2.new(1, -(jumpButtonSize*1.5-10), 1, -jumpButtonSize - 20) or
        UDim2.new(1, -(jumpButtonSize*1.5-10), 1, -jumpButtonSize * 1.75)

	local touchObject: InputObject? = nil
	self.jumpButton.InputBegan:connect(function(inputObject)
		--A touch that starts elsewhere on the screen will be sent to a frame's InputBegan event
		--if it moves over the frame. So we check that this is actually a new touch (inputObject.UserInputState ~= Enum.UserInputState.Begin)
		if touchObject or inputObject.UserInputType ~= Enum.UserInputType.Touch
			or inputObject.UserInputState ~= Enum.UserInputState.Begin then
			return
		end

		touchObject = inputObject
		self.jumpButton.ImageRectOffset = Vector2.new(146, 146)
		self.isCrawling = true
	end)

	local OnInputEnded = function()
		touchObject = nil
		self.isJumping = false
		self.jumpButton.ImageRectOffset = Vector2.new(1, 146)
	end

	self.jumpButton.InputEnded:connect(function(inputObject: InputObject)
		if inputObject == touchObject then
			OnInputEnded()
		end
	end)

	GuiService.MenuOpened:connect(function()
		if touchObject then
			OnInputEnded()
		end
	end)

	if not self.characterAddedConn then
		self:SetupCharacterAddedFunction()
	end

	self.jumpButton.Parent = self.parentUIFrame
end

return TouchMovement
