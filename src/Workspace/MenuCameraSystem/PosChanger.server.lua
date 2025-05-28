local TweenService = game:GetService("TweenService")
local Camera = game.Workspace.CurrentCamera
local CameraPositions = script.Parent.Positions
local Lighting = game:GetService("Lighting")

---Lighting
local FadeOut = TweenService:Create(game.Lighting,TweenInfo.new(20),{ExposureCompensation = -10}) 
local FadeIn = TweenService:Create(game.Lighting,TweenInfo.new(20),{ExposureCompensation = 0}) 

---CamChanges
local RightToLine = TweenService:Create(Camera,TweenInfo.new(0),{CFrame = CameraPositions.LinePan1.CFrame})
local LineToBehind = TweenService:Create(Camera,TweenInfo.new(0),{CFrame = CameraPositions.BehindPan1.CFrame})
local BehindToObs = TweenService:Create(Camera,TweenInfo.new(0),{CFrame = CameraPositions.ObsPan1.CFrame})
local ObsToRight = TweenService:Create(Camera,TweenInfo.new(0),{CFrame = CameraPositions.RightWallPan1.CFrame})

---Sequences
local RightWallPan = TweenService:Create(Camera,TweenInfo.new(20),{CFrame = CameraPositions.RightWallPan2.CFrame})
local LinePan = TweenService:Create(Camera,TweenInfo.new(20),{CFrame = CameraPositions.LinePan2.CFrame})
local BehindPan = TweenService:Create(Camera,TweenInfo.new(20),{CFrame = CameraPositions.BehindPan2.CFrame})
local ObsPan = TweenService:Create(Camera,TweenInfo.new(20),{CFrame = CameraPositions.ObsPan2.CFrame})


while true do
	FadeIn:Play()
	RightWallPan:Play()
	wait(20)
	FadeOut:Play()
	wait(1)
	RightToLine:Play()
	wait(1)
	
	FadeIn:Play()
	LinePan:Play()
	wait(20)
	FadeOut:Play()
	wait(1)
	LineToBehind:Play()
	wait(1)
	
	FadeIn:Play()
	BehindPan:Play()
	wait(20)
	FadeOut:Play()
	wait(1)
	BehindToObs:Play()
	wait(1)
	
	FadeIn:Play()
	ObsPan:Play()
	wait(20)
	FadeOut:Play()
	wait(1)
	ObsToRight:Play()
	wait(1)
end