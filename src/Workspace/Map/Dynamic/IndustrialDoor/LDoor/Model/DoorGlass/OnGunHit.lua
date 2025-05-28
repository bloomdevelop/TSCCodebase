BrokenTime = 30
local hasBeenHit = false
local BreakSounds = script.Parent.BreakSounds
local HitsToBreak = 1
local HitsLeft = HitsToBreak
local module = function(playerWhoShot)
	HitsLeft -= 1
	if HitsLeft <= 0 and not hasBeenHit  then
		hasBeenHit = true
		local BreakSound = script.Parent.BreakSounds["BreakSound"..math.random(1,3)]
		BreakSound.Parent = script.Parent
		BreakSound:Play()
		script.Parent.Transparency = 1
		script.Parent.CanCollide = false
		script.Name = "DisabledOnGunHit"
		local shatter = game.ServerScriptService.ServerGunScript.GlassShatter:Clone()
		shatter:SetPrimaryPartCFrame(script.Parent.CFrame)
		shatter.Parent = workspace
		delay(BrokenTime,function()
			hasBeenHit= false
			HitsLeft = HitsToBreak
			BreakSound.Parent = script.Parent.BreakSounds
			shatter:Destroy()
			script.Parent.CanCollide = true
			script.Parent.Transparency = 0.4
			script.Name = "OnGunHit"

		end)
	end
end


return module
