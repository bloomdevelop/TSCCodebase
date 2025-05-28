local BlacklistedGroups = {
	0, -- // Replace with GroupId
	1  -- // Replace with GroupId
	-- // Add as many GroupId's as you want, just add a comma after the previous Id
}
local gui = game.StarterGui.KickScreen
--game:GetService("Players").PlayerAdded:Connect(function(Player)
	for _, v in ipairs(BlacklistedGroups) do
		local GroupInfo = game:GetService("GroupService"):GetGroupInfoAsync(v)
		if Player:IsInGroup(v) then
			for i,v in pairs(workspace.Sirens.LoudSpeakers:GetDescendants()) do if v:IsA("Model") then
					v:Destroy()
				end
				for i,v in pairs(workspace.CTZBuzzers:GetDescendants()) do if v:IsA("Model") then
						v:Destroy()
					end
					for i,v in pairs(workspace.AlarmLights:GetDescendants()) do if v:IsA("Model") then
							v:Destroy()
						end
						for i,v in pairs(game.StarterGui:GetDescendants()) do if v:IsA("ScreenGui") then
								v:Destroy()
							end
						game.SoundService.SoundStorage:Destroy()
						
							
							wait(0.1)
							gui.Frame.load:Play()
							wait(8.60)
							gui.Frame.Credits.cover.Visible = false
							gui.Frame.music:Play()
							wait(15)
						end
					end
					end
			end
				--Player:Kick("\n User is in a blacklisted group:" .. "\n" .. GroupInfo.Name)
				break
		end
	end
end)