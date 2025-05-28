return function(playerWhoShot, _ ,damage)
	local c = playerWhoShot.Character :: Model
	if not c then return end
	local h = c:FindFirstChildOfClass("Humanoid")
	if not h then return end
	h.Health -= damage
end