local Players = game:GetService("Players")
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:wait()
local humanoid = char:WaitForChild("Humanoid",600)
local hrp = char:WaitForChild("HumanoidRootPart",600)
local RunService = game:GetService('RunService')

local LastTrainCFrame

local Function
local Function2

Function = RunService.Heartbeat:Connect(function()
	if humanoid.Sit == false then
		local Ignore = char
		local ray = Ray.new(hrp.CFrame.p,Vector3.new(0,-10,0))
		local Hit, Position, Normal, Material = workspace:FindPartOnRay(ray,Ignore)
		if Hit and Hit.Name == "TramPart" and Hit.Parent and Hit.Parent.Name == "TramMain" then
			local Train = Hit.Parent
			if LastTrainCFrame == nil then
				LastTrainCFrame = Train.CFrame
			end
			local TrainCF = Train.CFrame 
			local Rel = TrainCF * LastTrainCFrame:inverse()
			LastTrainCFrame = Train.CFrame
			hrp.CFrame = Rel * hrp.CFrame
		else
			LastTrainCFrame = nil
		end
		Function2 = humanoid.Died:Connect(function()
			Function:Disconnect() -- Stop memory leaks
			Function2:Disconnect() -- Stop memory leaks
			--... But failed to stop the leak...
		end)
	else
		LastTrainCFrame = nil
	end
end)