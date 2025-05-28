-- // Steven_Scripts, 2022

local cs = game:GetService("CollectionService")
local tws = game:GetService("TweenService")
local rst = game:GetService("ReplicatedStorage")

local remotesFolder = rst.Remotes
local cabinets = cs:GetTagged("CabinetInteractable")

local cabinetInteractable = {}
cabinetInteractable.__index = cabinetInteractable

function cabinetInteractable.new(cabinet : Model)
	local self = setmetatable({}, cabinetInteractable)

	local promptPart = cabinet.PrimaryPart
	local doors = {}

	local door1 = cabinet:FindFirstChild("Door1")
	if door1 ~= nil then
		table.insert(doors, door1)
	end

	local door2 = cabinet:FindFirstChild("Door2")
	if door2 ~= nil then
		table.insert(doors, door2)
	end

	local closedValue = Instance.new("BoolValue")
	closedValue.Name = "Closed"
	closedValue.Value = true
	closedValue.Parent = cabinet

	local prompt = Instance.new("ProximityPrompt")
	prompt.MaxActivationDistance = 5
	prompt.ObjectText = "Locker"
	prompt.ActionText = "Open"
	prompt.RequiresLineOfSight = false
	prompt.KeyboardKeyCode = Enum.KeyCode.F
	prompt.Style = Enum.ProximityPromptStyle.Custom
	prompt.Parent = promptPart

	self.Cabinet = cabinet
	self.Doors = doors
	self.Prompt = prompt
	self.Cooldown = false

	prompt.Triggered:Connect(function(plr)
		self:OnPromptTriggered(plr)
	end)

	return self
end

function cabinetInteractable:OnPromptTriggered(plr : Player)
	if self.Cooldown == true then return end
	self.Cooldown = true

	local prompt = self.Prompt
	prompt.Enabled = false

	local closedValue = self.Cabinet.Closed
	closedValue.Value = not closedValue.Value

	if closedValue.Value == true then
		self:Close()
	else
		self:Open()
	end

	self.Cooldown = false
	prompt.Enabled = true
end

function cabinetInteractable:Open()
	self.Cabinet.Closed.Value = false

	for i,door in pairs(self.Doors) do
		door.Interact.OpenSound:Play()
	end

	self.Prompt.ActionText = "Close"

	remotesFolder.Cabinets.CabinetStateChanged:FireAllClients(self.Cabinet)

	task.wait(0.45)

	for i,door in pairs(self.Doors) do
		door.DoorPos.Primary.CFrame = door.DoorPos.OpenPos.CFrame
	end
end


function cabinetInteractable:Close()
	self.Cabinet.Closed.Value = true

	for i,door in pairs(self.Doors) do
		door.Interact.CloseSound:Play()
	end

	self.Prompt.ActionText = "Open"
	remotesFolder.Cabinets.CabinetStateChanged:FireAllClients(self.Cabinet)

	task.wait(0.45)

	for i,door in pairs(self.Doors) do
		door.DoorPos.Primary.CFrame = door.DoorPos.ClosedPos.CFrame
	end
end

for i, cabinet in pairs(cabinets) do
	cabinetInteractable.new(cabinet)
end