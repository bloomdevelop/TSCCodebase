local ServerStorage = game:GetService("ServerStorage")
local Teams = game:GetService("Teams")

local gunList: {string} = {
	"P90",
	"UMP",
	"USP",
	"AR15",
	"FMG-9",
	"PPK",
	"QBZ-95",
	"Flamethrower",
	"MP5",
	"Neutralizer"
}

local function getGunAmount(player: Player): number
	local gunCount = 0

	for _, child in ipairs((player:FindFirstChildOfClass("Backpack") :: Backpack):GetChildren()) do
		if not child:IsA("Tool") then continue end
		if not table.find(gunList, child.Name) then continue end
		gunCount += 1
	end

	if player.Character then
		for _, child in ipairs((player.Character :: Model):GetChildren()) do
			if not child:IsA("Tool") then continue end
			if not table.find(gunList, child.Name) then continue end
			gunCount += 1
		end
	end

	return gunCount
end

return {
	GiveGun = function(player: Player, clickDetector: ClickDetector)
		if not clickDetector.Parent or not clickDetector.Parent:IsA("BasePart") then return end
		
		if player.Team == Teams["Menu"] or player.Team == Teams["Test Subject"] or player.Team == Teams["Solitary Confinement"] or player.Team == Teams["Latex"] or player.Team == Teams["Contained Infected Subject"] or player.Team == Teams["CIS Solitary"] then return end
		
		if player:DistanceFromCharacter((clickDetector.Parent :: BasePart).Position) > clickDetector.MaxActivationDistance+1.1 then return end

		local Tool = clickDetector.Parent :: BasePart

		if table.find(gunList, Tool.Name) and getGunAmount(player) >= 3 then return end

		local GunModel = Tool:WaitForChild("GunModel") :: Model
		local Cooldown = Tool:WaitForChild("Cooldown") :: NumberValue
		local OriginalActivationDistance = clickDetector.MaxActivationDistance

		clickDetector.MaxActivationDistance = -OriginalActivationDistance

		for _, child in ipairs(GunModel:GetDescendants()) do
			if not child:IsA("BasePart") then continue end
			child.Transparency = 1
		end

		local ToolClone = ServerStorage.Tools:FindFirstChild(Tool.Name):Clone()
		ToolClone.Parent = player:FindFirstChildOfClass("Backpack")

		task.wait(Cooldown.Value)

		clickDetector.MaxActivationDistance = OriginalActivationDistance

		for _, child in ipairs(GunModel:GetDescendants()) do
			if not child:IsA("BasePart") then continue end
			child.Transparency = 0
		end
	end
}