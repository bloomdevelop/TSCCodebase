-- // Steven_Scripts, 2022

local plr = game.Players.LocalPlayer

local menuFrame = script.Parent.Parent
local cameraEffects = menuFrame.Viewport.CameraEffects

local function addZeroIfOneCharacter(text)
	if string.len(text) == 1 then
		return "0"..text
	end
	return text
end

coroutine.wrap(function()
	while true do
		if menuFrame.Visible == true then
			local date = os.date("*t")
			
			cameraEffects.Date.Text = date.month.."/"..date.day.."/"..date.year.." "..date.hour..":"..addZeroIfOneCharacter(date.min)..":"..addZeroIfOneCharacter(date.sec)
			task.wait(1)
		else
			task.wait(4)
		end
	end
end)()

return true