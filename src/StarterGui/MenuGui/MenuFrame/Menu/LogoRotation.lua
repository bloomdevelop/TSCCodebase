local plr = game.Players.LocalPlayer

local menuFrame = script.Parent.Parent
local logoRotate = menuFrame.Sidebar.Logo.Rotate

coroutine.wrap(function()
	while true do
		if menuFrame.Visible == true then
			logoRotate.Rotation = logoRotate.Rotation+0.4
			if logoRotate.Rotation > 360 then
				logoRotate.Rotation = 0
			end
			task.wait(.0333)
		else
			task.wait(10)
		end
	end
end)()

return true