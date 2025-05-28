local TweenService = game:GetService("TweenService")

local speed = 30

local folder = game.Workspace:FindFirstChild("Tram-381h23p5ub32ug")
local nodes = folder.Nodes
local tram = folder.TramMain
local sfx = tram.TramSFX
local S1B = tram.Station1Button.ClickDetector
local S2B = tram.Station2Button.ClickDetector


local numOfNodes = 0
for _,v in pairs(nodes:GetChildren()) do
	numOfNodes += 1
end

local db = false
local db1 = false
local db2 = false



function S1Go()
	if (tram.Position - nodes[numOfNodes].Position).Magnitude < 1 then
		if db == false then
			db = true
			wait(2)
			onClick()
			db = false
		end
	elseif (tram.Position - nodes["1"].Position).Magnitude > 1 and (tram.Position - nodes[numOfNodes].Position).Magnitude > 1 and db == false then
		tram.CFrame = nodes["1"].CFrame
	end
end

function S2Go()
	if (tram.Position - nodes["1"].Position).Magnitude < 1 then
		if db == false then
			db = true
			wait(2)
			onClick()
			db = false
		end
	elseif (tram.Position - nodes["1"].Position).Magnitude > 1 and (tram.Position - nodes[numOfNodes].Position).Magnitude > 1 and db == false then
		tram.CFrame = nodes[numOfNodes].CFrame
	end
end

function onClick()
	sfx.Breaks:Play()
	wait(2)
	if (tram.Position - nodes["1"].Position).Magnitude < 1 then
		sfx.Start.Playing = true
		sfx.Run.Playing = true
		for count = 2,numOfNodes,1 do
			local ditance = (tram.Position - nodes[count].Position).Magnitude
			local info
			if count == 2 then
				info = TweenInfo.new(
					ditance/speed+3,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.In,
					0,
					false,
					0
				)
			elseif count == numOfNodes then
				sfx.Stop.Playing = true
				sfx.Run.Playing = false
				info = TweenInfo.new(
					ditance/speed+3,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out,
					0,
					false,
					0
				)
			else
				info = TweenInfo.new(
					ditance/speed,
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.InOut,
					0,
					false,
					0
				)
			end
			local tween = TweenService:Create(tram,info,{CFrame = nodes[count].CFrame})
			tween:Play()
			tween.Completed:wait()
		end
	elseif (tram.Position - nodes[numOfNodes].Position).Magnitude < 1 then
		sfx.Start.Playing = true
		sfx.Run.Playing = true
		for count = numOfNodes-1,1,-1 do
			local ditance = (tram.Position - nodes[count].Position).Magnitude
			local info
			if count == numOfNodes-1 then
				info = TweenInfo.new(
					ditance/speed+3,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.In,
					0,
					false,
					0
				)
			elseif count == 1 then
				sfx.Stop.Playing = true
				sfx.Run.Playing = false
				info = TweenInfo.new(
					ditance/speed+3,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out,
					0,
					false,
					0
				)
			else
				info = TweenInfo.new(
					ditance/speed,
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.InOut,
					0,
					false,
					0
				)
			end
			local tween = TweenService:Create(tram,info,{CFrame = nodes[count].CFrame})
			tween:Play()
			tween.Completed:wait()
		end
	end
	wait(10)
end

S1B.MouseClick:Connect(S1Go)
S2B.MouseClick:Connect(S2Go)
