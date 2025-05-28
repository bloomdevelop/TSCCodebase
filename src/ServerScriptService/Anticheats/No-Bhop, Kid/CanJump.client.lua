canjump = true
script.Parent.Humanoid.Changed:connect(function(p)
	if p == "Jump" then
		if canjump then
			canjump = false --NO CARROTS, NO BUNNIES.
			wait(1.5)
			canjump = true
		else
			script.Parent.Humanoid.Jump = false
		end
	end
end)