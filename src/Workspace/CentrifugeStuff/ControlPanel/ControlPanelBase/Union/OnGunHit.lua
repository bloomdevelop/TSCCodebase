BrokenTime = 0.3
local hasBeenHit = false
local BreakSounds = script.Parent.BreakSounds
local HitsLeft = 3
local module = function(playerWhoShot)
	HitsLeft -= 1
	if HitsLeft <= 0 and not hasBeenHit  then
		hasBeenHit = true
		local BreakSound = script.Parent.BreakSounds["BreakSound"..math.random(1,3)]
		BreakSound.Parent = script.Parent
		BreakSound:Play()
		script.Name = "OnGunHit"
		end
	end
return module