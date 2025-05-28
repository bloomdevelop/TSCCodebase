local module = function(playerWhoShot,damage)
	playerWhoShot.Character.Humanoid.Health -= damage
end

return module
