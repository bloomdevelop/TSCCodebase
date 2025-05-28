seat = script.Parent
function added(child)
	if (child.className=="Weld") then
		human = child.part1.Parent:FindFirstChild("Humanoid")
		if human ~= nil then
			anim = human:LoadAnimation(seat["sitanim"..math.random(1,3)])
			anim:Play()
		end
	 end
end

function removed(child2)
	if anim ~= nil then
		anim:Stop()
		anim:Destroy()
	end
end

seat.ChildAdded:connect(added)
seat.ChildRemoved:connect(removed)