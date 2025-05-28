local remote = script:WaitForChild("RemoteEvent")
local PlayerService = game:GetService("Players")
local plr = PlayerService.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local backpack = plr:WaitForChild("Backpack")

local f1
local f2
local f3

local gunList = {
	["AK-47"] = true,
	["AR15"] = true,
	["Flamethrower"] = true,
	["P90"] = true,
	["PPK"] = true,
	["UMP"] = true,
	["USP"] = true
}

f1 = backpack.ChildAdded:Connect(function(child)
	if child:IsA("Tool") and gunList[child.Name] then
		local count = 0
		for _,v in pairs(backpack:GetChildren()) do
			if gunList[v.Name] then
				count = count + 1
				if count >= 4 then
					wait()
					remote:FireServer(child)
				end
			end
		end
	end
end)

f2 = char.ChildAdded:Connect(function(child)
	if child:IsA("Tool") and gunList[child.Name] then
		local count = 0
		for _,v in pairs(backpack:GetChildren()) do
			if gunList[v.Name] then
				count = count + 1
				if count >= 3 then
					wait()
					char.Humanoid:UnequipTools()
					remote:FireServer(child)
				end
			end
		end
	end
end)

f3 = char.Humanoid.Died:Connect(function()
	f1:Disconnect()
	f2:Disconnect()
	f3:Disconnect()
end)