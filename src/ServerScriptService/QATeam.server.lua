local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local PlaceID = game.PlaceId

local function IsQATeam(Player : Player)
	if Player:IsInGroup(15987241) then
		return true
	end
	
	if Player:IsInGroup(12715058) then
		return true
	end
	
	if Player:GetRankInGroup(11577231) >= 100 then
		return true
	end
	
	return false
end

task.spawn(function()
	if PlaceID == 9672334663 and not RunService:IsStudio() then
		print("[QATeam] ALPHA Game Detected")
		if Workspace:GetAttribute("QATeam") then
			warn("[QATeam] QATeam Lock Active!")
			Players.PlayerAdded:Connect(function(Player)
				local Succes = pcall(function()
					if not IsQATeam(Player) then
						TeleportService:Teleport(7131355525, Player)
						task.delay(10, function()
							if Player then
								Player:Kick("[QATeam LOCKED]\nALPHA Version access is only for QA Testers.")
							end
						end)
					end
				end)
				if not Succes then
					Player:Kick("[QATeam]\nError")
				end
				Succes = nil
			end)
		else
			print("[QATeam] QAteam Lock Inactive!")
			script:Destroy()
		end
	else
		script:Destroy()
	end
end)
