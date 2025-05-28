--local ReaderScreen = script.Parent.Parent.Parent.DumbLightScriptIgnore
--local Prompt = script.Parent
--local Players = game:GetService("Players")
--local Player = Players.LocalPlayer
--local Lasergate = workspace.LasergateContainmentZoneEntrance.LaserGate
--function ScanKeycard(plr)
--	if plr then
--		if plr.Backpack:FindFirstChild("Card-L3") then
--			ReaderScreen.BrickColor = BrickColor.new ("Shamrock")

--			script.Parent.Parent.AccessGranted.Value = true
--			Prompt.Enabled = false
--			workspace.LasergateContainmentZoneEntrance.LaserHitbox.CanTouch = false
--			workspace.LasergateContainmentZoneEntrance.LaserHitbox.Wirring:Stop()
--			for i,v in pairs(Lasergate:GetDescendants()) do
--				if v.Name == ("LaserBarrier") then
--					local LaserBarrier = Lasergate:WaitForChild("LaserBarrier")
--					LaserBarrier.emmiter.MotionBeam.Enabled = false
--				end
--			end

--			wait(15)
--			workspace.LasergateContainmentZoneEntrance.LaserHitbox.CanTouch = true
--			workspace.LasergateContainmentZoneEntrance.LaserHitbox.Wirring:Play()

--			for i,v in pairs(Lasergate:GetDescendants()) do
--				if v.Name == ("LaserBarrier") then
--					local LaserBarrier = Lasergate:WaitForChild("LaserBarrier")
--					LaserBarrier.emmiter.MotionBeam.Enabled = true
--				end
--			end

--		else
--			script.Parent.Parent.AccessDenied:Play()
--			ReaderScreen.BrickColor = BrickColor.new ("Persimmon")
--			wait(0.5)
--			ReaderScreen.BrickColor = BrickColor.new ("Institutional white")
--		end
--	end
--end

--Prompt.Triggered:Connect(ScanKeycard)