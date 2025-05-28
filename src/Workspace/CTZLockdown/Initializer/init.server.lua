-- yes this is gross but it's better than what we had previously (same script manually duplicated three times and placed in three separate locations)

for i,v in pairs(script.Parent:GetChildren()) do
	if v.Name == "CTZLockdownSwitch" then
		local s = script.Script:Clone()
		s.Parent = v.Primary.ClickDetector
		s.Disabled = false
	end
end