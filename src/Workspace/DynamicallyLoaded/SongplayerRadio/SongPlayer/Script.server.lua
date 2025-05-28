local Song = script.Parent.radio
local cooldown = false
function onClicked()
	if not cooldown then
		cooldown = true
		if Song.Playing then
			Song:Stop()
		else
			Song:Play()
		end
		wait(1)
		cooldown = false
	end
end

script.Parent.ClickDetector.MouseClick:Connect(onClicked)