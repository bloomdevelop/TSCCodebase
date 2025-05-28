-- remotes
local cuffsEvent = game:GetService('ReplicatedStorage'):WaitForChild('CuffsEvent')

local functions = {
	connections = {},
	toggled = {},
	animation = {},
	cuffed = {}
}

function functions.Toggle(bool, playerCharacter, targetCharacter)
	local player = game:GetService('Players'):GetPlayerFromCharacter(playerCharacter)
	local playerHumanoid = playerCharacter.Humanoid
	local targetHumanoid = targetCharacter.Humanoid
	local playerRoot = playerCharacter.HumanoidRootPart
	local playerTarget = game:GetService('Players'):GetPlayerFromCharacter(targetCharacter)
	
	for _, connection in next, functions.connections do
		connection:Disconnect()
	end
	
	if playerTarget then
		functions.toggled[playerCharacter] = bool
		functions.cuffed[playerTarget] = bool

		cuffsEvent:FireClient(playerTarget, bool and 'Cuffed' or 'Uncuffed', playerCharacter.Name)
		
		playerHumanoid.Died:connect(function()
			cuffsEvent:FireClient(player, 'Uncuffing')
			
			functions.cuffed[playerTarget] = nil
			functions.toggled[playerCharacter] = nil
		end)

		targetHumanoid.Died:connect(function()
			cuffsEvent:FireClient(player, 'Uncuffing')
			
			functions.cuffed[playerTarget] = nil
			functions.toggled[playerCharacter] = nil
		end)
		
		functions.connections[#functions.connections + 1] = playerCharacter.AncestryChanged:connect(function(c, parent)
			if (parent == nil) then
				functions.toggled[c] = nil
			end
		end)

		while functions.toggled[playerCharacter] do
			local distance = player:DistanceFromCharacter(targetCharacter.HumanoidRootPart.Position)
			local Y_DIST = (playerRoot.Position.Y - targetCharacter.HumanoidRootPart.Position.Y)

			if (Y_DIST >= 5) then
				targetHumanoid.Jump = true
			end

			if (distance >= 4.5) then
				targetHumanoid:MoveTo(playerRoot.Position)
			end

			wait(.15)
		end
		
		cuffsEvent:FireClient(playerTarget, 'Uncuffed', playerCharacter.Name)
	else
		-- feature for NPC maybe in future
	end
end

return functions