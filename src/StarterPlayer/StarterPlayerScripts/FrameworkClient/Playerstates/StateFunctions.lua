Typing = require(script.Parent.Parent.Typing)
return function(Framework: Typing.FrameworkType, Animator: Typing.AnimatorInstanceType)
	local _JumpTime = tick()
	
	return {
		["Running"] = function(speed: number)
			if Animator.State == "Emoting" and speed < 1 then
				return
			end
			if Animator.Character:FindFirstChild('Humanoid') and Animator.Character.Humanoid.Sit then
				Animator.State = "Sitting"
				Animator:PlayCoreAnimation("sit", 0.3, 1)
			elseif Framework.Playerstates.Player:GetAttribute("State") == "Crawling" then
				Framework.Playerstates.Viewmodel:SetState(false)
				Framework.Playerstates.Animator.State = "Crawling"
				if speed > 0.1 then
					Animator:PlayCoreAnimation("crawl", 0.3, (speed + 1) / 3)
					Animator:SetAnimationSpeed((speed + 1) / 3)
				else
					if Animator.CoreAnimation.Name ~= "crawl" then
						Animator:PlayCoreAnimation("crawl", 0.3, 0.3)
						Animator:SetAnimationSpeed(0)
					end
					local tp = Animator:GetTimePosition()
					if tp > .5 and tp <= 1.5  then
						Animator:SetTimePosition(1, 0.1)
					elseif tp > 1.5 then
						Animator:SetTimePosition(1.99, 0.1)
					else
						Animator:SetTimePosition(0, 0.1)
					end
					Animator:SetAnimationSpeed(0)
				end
			elseif Framework.Playerstates.Player:GetAttribute("State") == "Crouching" then
				Framework.Playerstates.Viewmodel:SetState(false)
				Animator.State = "Crouching"
				if speed > 0.1 then
					Animator:PlayCoreAnimation("crouch", 0.3, (speed + 1) / 14)
					Animator:SetAnimationSpeed((speed + 1) / 14)
				else
					if Animator.CoreAnimation.Name ~= "crouch" then
						Animator:PlayCoreAnimation("crouch", 0.3, 1)
						Animator:SetAnimationSpeed(0)
					end
					local tp = Animator:GetTimePosition()
					if tp > (.83 / 4) and tp <= ((.83 / 4) * 3)  then
						Animator:SetTimePosition(((.83 / 4) * 2), 0.1)
					elseif tp > ((.83 / 4) * 3) then
						Animator:SetTimePosition(.82, 0.1)
					else
						Animator:SetTimePosition(0, 0.1)
					end
					Animator:SetAnimationSpeed(0)
				end
			elseif Framework.Playerstates.Player:GetAttribute('State') == "Running" and (speed > 1) then
				Framework.Playerstates.Viewmodel:SetState(true)
				Animator.State = "Running"
				Animator:PlayCoreAnimation("run", .2, math.clamp(speed / 24, 0, 2))
				Animator:SetAnimationSpeed(math.clamp(speed / 26, 0, 2))
			elseif speed > 0.1 then
				Framework.Playerstates.Viewmodel:SetState(true)
				Animator.State = "Walking"
				Animator:PlayCoreAnimation("walk", 0.2, speed / 14)
				Animator:SetAnimationSpeed(speed / 14)
			else
				Framework.Playerstates.Viewmodel:SetState(true)
				Framework.Playerstates.Player:SetAttribute('DisableViewmodel', false)
				Animator.State = "Standing"
				Animator:PlayCoreAnimation("idle", 0.2, .2) -- looks like they're panting, add little detail that uses workflow to display this?
			end
		end,
		["Jumping"] = function()
			Framework.Playerstates.Viewmodel:SetState(true)
			local _JumpTime = tick() + .4
			Animator.State = "Jumping"
			Animator:PlayCoreAnimation("jump", 0.15, 1)
		end,
		["Climbing"] = function(speed: number)
			Framework.Playerstates.Viewmodel:SetState(true)
			Animator.Speed = speed
			Animator.State = "Climbing"
			Animator:SetAnimationSpeed(speed / 12)
			Animator:PlayCoreAnimation("climb", 0.1, speed / 12)
		end,
		["FreeFalling"] = function()
			if (Animator.State ~= "Crawling" and _JumpTime < tick()) or (_JumpTime + 1) < tick() then
				Framework.Playerstates.Viewmodel:SetState(true)
				Animator.State = "FreeFalling"
				Animator:PlayCoreAnimation("fall", 0.1, 1)
			end
		end,
	}
end