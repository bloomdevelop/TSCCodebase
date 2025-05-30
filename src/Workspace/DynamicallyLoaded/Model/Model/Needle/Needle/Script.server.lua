local TS = game.TweenService
local Needle = script.Parent
local Middle = script.Parent.Parent.Middle
local MidLeft = script.Parent.Parent.MidLeft
local MidRight = script.Parent.Parent.MidRight
local Left = script.Parent.Parent.PosLeft
local Right = script.Parent.Parent.PosRight
local FarLeft = script.Parent.Parent.FarLeft
local FarRight = script.Parent.Parent.FarRight
while true do
	TS:Create(Needle,TweenInfo.new(0.2,Enum.EasingStyle.Bounce),{CFrame = Right.CFrame}):Play()
	wait(0.2)
	TS:Create(Needle,TweenInfo.new(0.5,Enum.EasingStyle.Bounce),{CFrame = FarRight.CFrame}):Play()
	wait(0.2)
	TS:Create(Needle,TweenInfo.new(0.5,Enum.EasingStyle.Bounce),{CFrame = Right.CFrame}):Play()
	wait(0.2)
	TS:Create(Needle,TweenInfo.new(0.2,Enum.EasingStyle.Bounce),{CFrame = MidLeft.CFrame}):Play()
	wait(0.2)
	TS:Create(Needle,TweenInfo.new(0.6,Enum.EasingStyle.Bounce),{CFrame = Middle.CFrame}):Play()
	wait(0.2)
	TS:Create(Needle,TweenInfo.new(0.2,Enum.EasingStyle.Bounce),{CFrame = Middle.CFrame}):Play()
	wait(0.2)
	TS:Create(Needle,TweenInfo.new(0.1,Enum.EasingStyle.Bounce),{CFrame = MidLeft.CFrame}):Play()
	wait(0.2)
	TS:Create(Needle,TweenInfo.new(0.3,Enum.EasingStyle.Bounce),{CFrame = FarLeft.CFrame}):Play()
	wait(0.2)
	TS:Create(Needle,TweenInfo.new(0.2,Enum.EasingStyle.Bounce),{CFrame = MidRight.CFrame}):Play()
	wait(0.2)
	TS:Create(Needle,TweenInfo.new(0.4,Enum.EasingStyle.Bounce),{CFrame = Left.CFrame}):Play()
	wait(0.2)
	TS:Create(Needle,TweenInfo.new(0.4,Enum.EasingStyle.Bounce),{CFrame = Left.CFrame}):Play()
	wait(0.2)
	TS:Create(Needle,TweenInfo.new(0.2,Enum.EasingStyle.Bounce),{CFrame = Middle.CFrame}):Play()
	wait(0.2)
	TS:Create(Needle,TweenInfo.new(0.3,Enum.EasingStyle.Bounce),{CFrame = MidRight.CFrame}):Play()
	wait(0.2)
	TS:Create(Needle,TweenInfo.new(0.3,Enum.EasingStyle.Bounce),{CFrame = FarLeft.CFrame}):Play()
	wait(0.2)
	TS:Create(Needle,TweenInfo.new(0.5,Enum.EasingStyle.Bounce),{CFrame = MidLeft.CFrame}):Play()
	wait(0.5)
	TS:Create(Needle,TweenInfo.new(0.6,Enum.EasingStyle.Bounce),{CFrame = Middle.CFrame}):Play()
	wait(0.5)
	TS:Create(Needle,TweenInfo.new(0.2,Enum.EasingStyle.Bounce),{CFrame = FarRight.CFrame}):Play()
	wait(0.5)
	TS:Create(Needle,TweenInfo.new(0.3,Enum.EasingStyle.Bounce),{CFrame = MidRight.CFrame}):Play()
	wait(0.2)
	TS:Create(Needle,TweenInfo.new(0.2,Enum.EasingStyle.Bounce),{CFrame = Middle.CFrame}):Play()
	wait(0.2)
	TS:Create(Needle,TweenInfo.new(0.5,Enum.EasingStyle.Bounce),{CFrame = Left.CFrame}):Play()
	wait(0.5)
	TS:Create(Needle,TweenInfo.new(0.2,Enum.EasingStyle.Bounce),{CFrame = Middle.CFrame}):Play()
	wait(0.5)
	TS:Create(Needle,TweenInfo.new(0.5,Enum.EasingStyle.Bounce),{CFrame = MidRight.CFrame}):Play()
	wait(0.5)
	TS:Create(Needle,TweenInfo.new(0.3,Enum.EasingStyle.Bounce),{CFrame = Right.CFrame}):Play()
	wait(0.2)
	TS:Create(Needle,TweenInfo.new(0.2,Enum.EasingStyle.Bounce),{CFrame = Middle.CFrame}):Play()
	wait(0.2)
	TS:Create(Needle,TweenInfo.new(0.2,Enum.EasingStyle.Bounce),{CFrame = MidLeft.CFrame}):Play()
	wait(0.5)
	TS:Create(Needle,TweenInfo.new(0.4,Enum.EasingStyle.Bounce),{CFrame = MidRight.CFrame}):Play()
	wait(0.5)
	TS:Create(Needle,TweenInfo.new(0.2,Enum.EasingStyle.Bounce),{CFrame = MidLeft.CFrame}):Play()
	wait(0.5)
	TS:Create(Needle,TweenInfo.new(0.1,Enum.EasingStyle.Bounce),{CFrame = FarLeft.CFrame}):Play()
	wait(0.5)
	TS:Create(Needle,TweenInfo.new(0.4,Enum.EasingStyle.Bounce),{CFrame = Middle.CFrame}):Play()
	wait(0.5)
	TS:Create(Needle,TweenInfo.new(0.5,Enum.EasingStyle.Bounce),{CFrame = MidRight.CFrame}):Play()
	wait(0.5)
end