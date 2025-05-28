local tws = game:GetService("TweenService")

local model = script.Parent

local button = model.Button.PrimaryPart
local originalButtonCF = button.CFrame

local door = model.Door

local speaker = model.Speaker

local openTweens = {}
local closeTweens = {}

for i,doorPiece in pairs(door:GetChildren()) do
	local part = doorPiece.Door
	local openedCF = doorPiece.OpenedPos.CFrame
	local closedCF = doorPiece.ClosedPos.CFrame
	
	table.insert(openTweens, tws:Create(part, TweenInfo.new(model:GetAttribute("OpenTime"), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {["CFrame"] = openedCF}))
	table.insert(closeTweens, tws:Create(part, TweenInfo.new(model:GetAttribute("OpenTime"), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {["CFrame"] = closedCF}))
end

local function openDoor()
	for i,tween in pairs(openTweens) do
		tween:Play()
	end
	
	speaker.OpenSound:Play()
end

local function closeDoor()
	for i,tween in pairs(closeTweens) do
		tween:Play()
	end
	
	speaker.CloseSound:Play()
end

local buttonCooldown = false

local cd = Instance.new("ClickDetector")
local activationDistance = 10
cd.MaxActivationDistance = activationDistance

cd.MouseClick:Connect(function(plr : Player)
	if buttonCooldown == true then return end
	
	local char = plr.Character
	if char == nil then return end
	
	local root = char:FindFirstChild("HumanoidRootPart")
	if root == nil then return end
	
	local distance = (root.Position - button.Position).Magnitude
	if distance < activationDistance+2 then
		buttonCooldown = true
		
		button.Click:Play()
		button.CFrame = originalButtonCF*CFrame.new(0.05, 0, 0)
		task.wait(.1)
		button.CFrame = originalButtonCF
		
		buttonCooldown = false
		
		if model:GetAttribute("IsMoving") == false then
			model:SetAttribute("IsMoving", true)
			
			if model:GetAttribute("IsOpen") == true then
				closeDoor()
				model:SetAttribute("IsOpen", false)
			else
				openDoor()
				model:SetAttribute("IsOpen", true)
			end
			
			task.wait(model:GetAttribute("OpenTime"))
			
			model:SetAttribute("IsMoving", false)
		end
	end
end)

cd.Parent = button