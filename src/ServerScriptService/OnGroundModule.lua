local module = {}

module.OnGround = function(tool)
	if tool.Parent == game.Workspace then
		for i = 1,30,1 do
			if tool.Parent == game.Workspace then
				wait(1)
			else
				return
			end
		end
		tool.Handle.Anchored = true
	elseif tool.Handle.Anchored == true and tool.Parent ~= game.Workspace then
		tool.Handle.Anchored = false
		return
	end
end

return module