local TS = game:GetService("TweenService")

local Interact = script.Parent.Parent

local TurnedPos = Interact.TurnedPos
local UnturnedPos = Interact.UnturnedPos

local sussy = Interact.Parent.mogus:WaitForChild("OnGunHit")

local ValveOpen = TS:Create(Interact.Valve, TweenInfo.new(2,Enum.EasingStyle.Bounce), {CFrame = TurnedPos.CFrame})
local ValveClose = TS:Create(Interact.Valve, TweenInfo.new(2,Enum.EasingStyle.Bounce), {CFrame = UnturnedPos.CFrame})

local debounce, closed

script.Parent.MouseClick:Connect(function()
	if debounce or closed then return end
	debounce = true
	task.wait(1)

	ValveClose:Play()
	Interact.TurnSound:Play()
	task.wait(2)

	Interact.LockingSound:Play()
	Interact.Particles.Gas.Enabled = false
	Interact.Particles.Sparks.Enabled = false
	Interact.DmgHitbox.CanTouch = false

	Interact.gas:Stop()
	sussy.Name = "NotOnGunHit"

	closed = true
	debounce = nil
end)

warn("This is fixed, Not sure if this is intended.")