local sst = game:GetService("ServerStorage")

local npc = script.Parent

local root = npc.HumanoidRootPart

local defaultCF = root.CFrame

local animations = npc.Animations

local parryAnimation = npc.Humanoid.Animator:LoadAnimation(animations.MaidStickParryKyran)

local originalShirtTemplate = npc.Shirt.ShirtTemplate
local originalPantsTemplate = npc.Pants.PantsTemplate

--[[
local originalAccessories = {}
for i,v in pairs(npc:GetChildren()) do
	if v:IsA("Accessory") then
		originalAccessories[v] = true
	end
end
]]

local MaidMorph = sst:WaitForChild("Chars"):WaitForChild("Utility & Maintenance"):WaitForChild("Maid")
local function morphCharacter(character: Model)
	for _,item in next, MaidMorph:GetChildren() do
		if character:FindFirstChild(item.Name) then character:FindFirstChild(item.Name):Destroy() end
		item:Clone().Parent = character
	end
end


local function getAttacker()
	for i,plr in pairs(game.Players:GetPlayers()) do
		local char = plr.Character
		if char then
			local heldTool = char:FindFirstChildOfClass("Tool")
			if heldTool ~= nil and heldTool.Name == "Maid Stick" then
				local root = char:FindFirstChild("HumanoidRootPart")
				if root and (root.Position - npc.HumanoidRootPart.Position).Magnitude < 15 then
					return plr, heldTool
				end
			end
		end
	end
	
	return nil
end

local parrying = false

npc.ChildAdded:Connect(function(child)
	local sus = false
	
	if child:IsA("Shirt") then
		child.ShirtTemplate = originalShirtTemplate
		sus = true
	elseif child:IsA("Pants") then
		child.PantsTemplate = originalPantsTemplate
		sus = true
	elseif child:IsA("Accessory") then
		child:Destroy()
		sus = true
	end
		
	if sus == true and parrying == false then
		local plr, tool = getAttacker()
		
		if plr ~= nil then
			parrying = true
			
			local plrChar = plr.Character
			local plrRoot = plrChar.HumanoidRootPart
			
			npc:PivotTo(CFrame.lookAt(root.Position, Vector3.new(plrRoot.Position.X, root.Position.Y, plrRoot.Position.Z)))
			plrRoot.CFrame = npc.HumanoidRootPart.CFrame*CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(180), 0)
			
			plrRoot.Anchored = true
			
			local parryAnimationPlr = plrChar.Humanoid.Animator:LoadAnimation(animations.MaidStickParryPlayer) :: AnimationTrack
			
			parryAnimationPlr:Play()
			parryAnimation:Play()
			
			parryAnimationPlr.Stopped:Connect(function()
				plrRoot.Anchored = false
				
				plrChar.Humanoid.Health = 0
				
				local bf = Instance.new("BodyForce")
				bf.Force = plrRoot.CFrame.RightVector*7000
				bf.Parent = plrRoot
				
				game.Debris:AddItem(bf, .2)
				
				parryAnimationPlr:Destroy()
			end)
			
			parryAnimation:GetMarkerReachedSignal("SwapWeapon"):Wait()
			tool.Parent = npc
			
			parryAnimation:GetMarkerReachedSignal("Impact"):Wait()
			npc.Torso.Parry1:Play()
			npc.Torso.Parry2:Play()
			
			morphCharacter(plrChar)
			
			parryAnimation:GetMarkerReachedSignal("DeleteWeapon"):Wait()
			tool:Destroy()
			
			parryAnimation.Stopped:Wait()

			npc:PivotTo(defaultCF)
			
			parrying = false
		end
	end
end)