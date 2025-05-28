game.ReplicatedFirst:RemoveDefaultLoadingScreen()

local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
PlayerGui:SetTopbarTransparency(0)

local GUI = script.LoadingScreen:Clone()
GUI.Parent = PlayerGui

repeat task.wait(1) until game:IsLoaded()
task.wait(4.3)

local camera = workspace.CurrentCamera or workspace:WaitForChild('Camera')
camera.CameraType = Enum.CameraType.Scriptable
camera.CFrame = CFrame.new(1517.44189, 88.4140472, -279.569427, 0.959258497, -0.0928317234, 0.266843736, 7.45058149e-09, 0.94447881, 0.32857272, -0.282530189, -0.315186173, 0.905999184)

GUI:WaitForChild("Frame", 600):TweenPosition(UDim2.new(0,0,1,0),"InOut","Sine",0.5)
task.wait(0.5)

GUI:Destroy()