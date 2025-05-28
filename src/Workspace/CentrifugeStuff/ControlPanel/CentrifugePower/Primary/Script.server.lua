local PullSound = script.Parent.PullSound
local Alert = script.Parent.Alert
local Startup = script.Parent.Startup

function onClicked()
	PullSound:Play()
	Startup:Play()
	wait(0.5)
	Alert:Play()
end

script.Parent.ClickDetector.MouseClick:connect(onClicked)
