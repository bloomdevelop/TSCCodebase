local hitbox = script.Parent
local cameraModel = hitbox.CameraModel.Value

local indicatorLight = cameraModel.IndicatorLight

local broken = hitbox.Broken
local playersViewingFolder = hitbox.PlayersViewing

local defaultRepairTime = 60*5
local repairTimer = defaultRepairTime

local module = function(playerWhoShot, damage, gun, gunData)
	local isWrench = gun.Name == "Wrench"
	
	if isWrench == false and broken.Value == false then
		broken.Value = true
		
		hitbox.Sparks.Enabled = true
		hitbox.Sparks:Emit(100)
		
		hitbox.Break:Play()
		hitbox.Alarm:Play()
		
		indicatorLight.Color = Color3.new(0.1, 0.1, 0.1)
		
		repairTimer = defaultRepairTime
		while broken.Value == true do
			repairTimer = repairTimer - task.wait(.5)
			if repairTimer <= 0 then
				break
			end
		end
		
		hitbox.Sparks.Enabled = false
		
		hitbox.Alarm:Stop()
		hitbox.Repair:Play()
		
		if #playersViewingFolder:GetChildren() == 0 then
			-- Nobody is viewing this camera
			indicatorLight.Color = Color3.new(1, 1, 1)
		else
			-- At least one person is viewing this camera
			indicatorLight.Color = Color3.new(1, 0, 0)
		end
		
		broken.Value = false
	elseif isWrench == true and broken.Value == true then
		hitbox.RepairWrench:Play()
		
		broken.Value = false
	end
end

return module