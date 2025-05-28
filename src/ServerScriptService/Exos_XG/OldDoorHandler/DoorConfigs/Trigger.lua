return function(p,Door)
	local door
	for i,v in pairs(workspace.Doors:GetChildren()) do
		if v:IsAncestorOf(Door) then
			door = v
		end
	end
	if door ~= nil then
		local sound = Door:findFirstChild("doorsound",true)
		if sound then
			sound:Play()
		end
		require(script.Parent[door.Name])(p,door)
	end
end