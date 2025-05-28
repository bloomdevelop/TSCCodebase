-- yes it literally just plays a song

local char = script.Parent

char:GetAttributeChangedSignal("Boxing"):Connect(function()
	if char:GetAttribute("Boxing") == true and workspace.RiotInfo.Rioting.Value == false then
		script.SandmanTheme:Play()
	else
		script.SandmanTheme:Stop()
	end
end)