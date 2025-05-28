local Click = script.Parent.Click

function onClicked()
	Click:Play()
	if workspace:FindFirstChild("PartyMode") then
		workspace.PartyMode.Parent = game.ServerStorage
	end
end

script.Parent.ClickDetector.MouseClick:connect(onClicked)