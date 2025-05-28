local GunModule = require(script.Parent.Parent.Parent.GunGiver)
local clickDetector = script.Parent.ClickDetector

function onClick(plr)
	GunModule.GiveGun(plr,clickDetector)
	
end

clickDetector.MouseClick:Connect(onClick)