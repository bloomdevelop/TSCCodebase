-- Do we really need this?

local PS = game:GetService("Players")
local WS = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local RunSer = game:GetService("RunService")
local plr = PS.LocalPlayer
local cam = WS.CurrentCamera
local wt = 1800
local folder = WS:WaitForChild("DynamicallyLoaded",wt)
local chunkFolder = RS:WaitForChild("ChunkFolder",wt)
local chunkList = chunkFolder:GetChildren()
local partList = {}

local LightFolder = WS:WaitForChild("LightsFolder",wt)
local AlarmLights = WS:WaitForChild("AlarmLight",wt)
local MarkerLights = WS:WaitForChild("MarkerLights",wt)

folder.ChildAdded:Connect(function(child)
	table.insert(partList,child)
end)

local function isInsideBrick(v1, v2)
	local v3 = v2.CFrame:PointToObjectSpace(v1)
	return (math.abs(v3.X) <= v2.Size.X / 2)
		and (math.abs(v3.Y) <= v2.Size.Y / 2)
		and (math.abs(v3.Z) <= v2.Size.Z / 2)
end

local function F3(v1,v2)
	if v1:IsA("Model") then
		local pos = v1:GetPivot()
		return isInsideBrick(Vector3.new(pos.X,pos.Y,pos.Z),v2)
	else
		return isInsideBrick(v1.Position,v2)
	end
end

local function isInRange(v)
	local main = nil
	while true do
		if main == nil then
			local e = v:FindFirstChild('ChunkMain')
			if e then
				main = e
			else
				task.wait(10)
			end
			e = nil
		else
			if plr and cam then
				if (main.Position - cam.CFrame.Position).Magnitude < 500 then
					v.Parent = WS
				else
					v.Parent = nil
				end
			end
		end
		task.wait(1)
	end
end

for _,v in pairs(chunkList) do
	local cor = coroutine.wrap(isInRange)
	cor(v)
end

local function renfunc()
	local part = {}
	while true do
		if partList[1] then
			table.insert(part,partList[1])
			table.remove(partList,1)
			local found = false
			for _,v in pairs(chunkList) do
				if part[1] == nil then
					table.remove(part,1)
					break
				end
				if v:FindFirstChild("ChunkMain") and F3(part[1],v.ChunkMain) == true then
					RunSer.RenderStepped:Wait()
					found = true
					if part[1] then
						part[1].Parent = v
					end
					table.remove(part,1)
				end
			end
			if found == false then
				table.remove(part,1)
			end
		end
		RunSer.RenderStepped:Wait()
	end
end

local cor = coroutine.wrap(renfunc)
cor()
local cor = coroutine.wrap(renfunc)
cor()
local cor = coroutine.wrap(renfunc)
cor()
local cor = coroutine.wrap(renfunc)
cor()
local cor = coroutine.wrap(renfunc)
cor()

for _,v in pairs(folder:GetChildren()) do
	if v:IsA("Model") then
		table.insert(partList,v)
	end
end

for _,v in pairs(LightFolder:GetChildren()) do
	if v:IsA("Folder") then
		for _,e in pairs(v:GetChildren()) do
			if e:IsA("Model") then
				table.insert(partList,e)
			elseif e:IsA("Folder") then
				for _,r in pairs(e:GetChildren()) do
					if r:IsA("Model") then
						table.insert(partList,r)
					end
				end
			end
		end
	end
end

for _,v in pairs(AlarmLights:GetChildren()) do
	if v:IsA("Model") then
		table.insert(partList,v)
	end
end

for _,v in pairs(MarkerLights:GetChildren()) do
	if v:IsA("Model") then
		table.insert(partList,v)
	end
end