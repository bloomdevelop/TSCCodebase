local part = script.Parent
local Lighting = game.Lighting
inzone = false
local isTouched = false  
local RESET_SECONDS = 0.1
function OnTouch(part)
	if not isTouched then  
		isTouched = true 
		inzone = not inzone
		if inzone == true then
			Lighting.Ambient = Color3.new(0,0,0)
			inzone = false
		else
			Lighting.Ambient = Color3.new(67,75,85)
			inzone = true
			wait(RESET_SECONDS)
			isTouched = false 
		end
	end
end