local PlayerService = game:GetService("Players")

local regions = script.Parent.Regions

local size = 10

function onPlrLeave(plr)
	if regions:FindFirstChild(plr.Name) then
		regions:FindFirstChild(plr.Name):Destroy()
	end
end

function CheckPlr()
	for _,v in pairs(PlayerService:GetPlayers()) do
		if v then
			if v.Character then
				local plrFound = false
				if regions:FindFirstChild(v.Name) then
					local plrRegion = regions:FindFirstChild(v.Name)
					local region = Region3.new(Vector3.new(plrRegion.Position.X-size,plrRegion.Position.Y-size,plrRegion.Position.Z-size),Vector3.new(plrRegion.Position.X+size,plrRegion.Position.Y+size,plrRegion.Position.Z+size))
					local partsInRegion = game.Workspace:FindPartsInRegion3WithWhiteList(region,{v.Character})
					for _,v in pairs(partsInRegion) do
						if v.Parent:FindFirstChild("Humanoid") then
							plrFound = true
						end
					end
					if plrFound == false then
						plrRegion.CFrame = v.Character.HumanoidRootPart.CFrame
						plrRegion.Time.Value = 0
					elseif plrFound == true then
						plrRegion.Time.Value += 1
					end
				else
					local region = Instance.new("Part")
					region.Parent = regions
					region.Name = v.Name
					region.Anchored = true
					region.CanCollide = false
					region.CanTouch = false
					region.Material = Enum.Material.SmoothPlastic
					region.Transparency = 0.75
					region.Size = Vector3.new(20,20,20)
					region.CFrame = v.Character.HumanoidRootPart.CFrame
					local counter = Instance.new("NumberValue")
					counter.Parent = region
					counter.Name = "Time"
				end
			end
		end
	end
end

PlayerService.PlayerRemoving:Connect(onPlrLeave)

while true do
	wait(5)
	pcall(CheckPlr)
end