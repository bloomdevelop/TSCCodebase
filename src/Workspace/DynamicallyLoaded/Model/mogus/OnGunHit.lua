BrokenTime = 1
local Interact = script.Parent.Parent.Interact
local hasBeenHit = false
local BreakSounds = script.Parent.BreakSounds
local HitsToBreak = 1
local HitsLeft = HitsToBreak
local module = function(playerWhoShot)
	if not Interact.Particles.Gas.Enabled then
		hasBeenHit = false
	end
	HitsLeft -= 1
	if HitsLeft <= 0 and not hasBeenHit then
		hasBeenHit = true
		local BreakSound = script.Parent.BreakSounds["BreakSound"..math.random(1,3)]
		BreakSound.Parent = script.Parent
		BreakSound:Play()
		Interact.Particles.Gas.Enabled = true
		Interact.Particles.Sparks.Enabled = true
		Interact.gas:Play()
		Interact.DmgHitbox.CanTouch = true
		Interact.ClickDetector.MaxActivationDistance = 5
		HitsLeft = true
	end
end


return module
