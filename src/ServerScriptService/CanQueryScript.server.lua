for i,v in pairs(workspace:GetDescendants())do
	if v:isA("BasePart") and not v.CanCollide then
		v.CanQuery = false
	end
end