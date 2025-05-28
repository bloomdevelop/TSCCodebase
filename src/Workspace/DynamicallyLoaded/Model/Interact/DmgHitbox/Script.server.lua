local healthLoss = 12 -- damage from brick
local coolDown = .3 -- damage per .5 seconds
local loseHealth = true
function killBrick(hit)
	local h = hit.Parent:findFirstChild("Humanoid")
	if h~= nil and loseHealth == true then
		loseHealth = false
		h.Health = h.Health - healthLoss
		wait(coolDown)
		loseHealth = true
	end
end




script.Parent.Touched:connect(killBrick)
