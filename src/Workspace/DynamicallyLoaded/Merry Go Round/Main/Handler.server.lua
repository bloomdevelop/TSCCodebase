local clickDectector = script.Parent.ClickDetector
local hinge = script.Parent.HingeConstraint

local var, db

clickDectector.MouseClick:Connect(function()
	if  db then return end
	db = true

	if 15 > hinge.AngularVelocity then
		hinge.AngularVelocity += 0.5
	end

	if not var then
		var = true
		script.Parent.Anchored = false
		script.Parent:SetNetworkOwner(nil)

		task.spawn(function()
			repeat
				if hinge.AngularVelocity > 0 then
					hinge.AngularVelocity -= 0.1
				else
					hinge.AngularVelocity = 0
					script.Parent.Anchored = true
					var = nil
				end
				task.wait(0.5)
			until not var
		end)
	end

	task.wait(0.5)
	db = nil
end)