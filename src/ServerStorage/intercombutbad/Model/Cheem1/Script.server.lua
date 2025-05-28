local Click = script.Parent.Click

function onClicked()
	wait(0.1)
	script.Parent.ClickDetector.MaxActivationDistance = 0
	Click:Play()
	game.SoundService.SoundStorage.Intercom.Beep:Play()
	wait(2.5)
	game.SoundService.SoundStorage.Music.BabyRemix2:Play()
	wait(36)
	wait(3)
	script.Parent.ClickDetector.MaxActivationDistance = 5
end

script.Parent.ClickDetector.MouseClick:connect(onClicked)