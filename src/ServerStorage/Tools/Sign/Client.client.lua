local PS = game:GetService('Players')
local UIS = game:GetService('UserInputService')
local TS = game:GetService('TweenService')
local WS = game:GetService('Workspace')
local plr = PS.LocalPlayer
local cam = WS:WaitForChild('Camera')
local char
local anim

local tool = script.Parent
local holdAnim = tool:WaitForChild("HoldAnim")
local remote = tool:WaitForChild("Remote")
local gui = script:WaitForChild("SignGui")
local MainFrame = gui:WaitForChild("Frame")
local TopBar = MainFrame:WaitForChild("Bar")
local inputBox = MainFrame:WaitForChild("TextBox")

tool.Equipped:Connect(function()
	gui.Parent = plr.PlayerGui
	char = plr.Character or plr.CharacterAdded:Wait()
	if char:FindFirstChild("Humanoid") then
		anim = char.Humanoid:LoadAnimation(holdAnim)
		anim:Play()
	end
end)

tool.Unequipped:Connect(function()
	gui.Parent = script
	if anim then
		anim:Stop()
	end
end)

MainFrame.TextBox.FocusLost:Connect(function()
	if tonumber(inputBox.Text) then
		remote:FireServer(tonumber(inputBox.Text))
	else
		inputBox.Text = "Not Valid ID"
	end
end)

local dragging = false
local dragSpeed = 0.25
local dragStart = nil
local startPos = nil

local function updateInput(input)
	local delta = input.Position - dragStart
	local pos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	TS:Create(MainFrame,TweenInfo.new(dragSpeed),{Position = pos}):Play()
end

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true 
		dragStart = input.Position
		startPos = MainFrame.Position
	end
end)
TopBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)
UIS.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		if dragging then
			updateInput(input)
		end
	end
end)