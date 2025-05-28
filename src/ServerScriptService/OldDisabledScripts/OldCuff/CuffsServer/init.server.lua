-- remotes
local cuffsEvent = game:GetService('ReplicatedStorage'):WaitForChild('CuffsEvent')
local cuffsFunction = game:GetService('ReplicatedStorage'):WaitForChild('CuffsFunction')

-- modules
local cuffsModule = require(script.CuffsModule)

-- variables
local MAX_DETAIN_DISTANCE = 20
local lastAnim = {}
local lastCuff = {}

cuffsFunction.OnServerInvoke = function(player, ...)
	local args = {...}
	
	if (args[1]:lower() == 'getcuffdata') then
		return {
			Animation = cuffsModule.animation[player],
			Cuffed = cuffsModule.cuffed[player]
		}
	end
end

cuffsEvent.OnServerEvent:connect(function(player, ...)
	local args = {...}
	local target = args[2]
	
	if game:GetService("CollectionService"):HasTag(target,"CustomCharacter") then
		return
	end
	
	if not lastCuff[player] then
		lastCuff[player] = {
			target = nil,
			connections = {}
		}
	end

	if (args[1]:lower() == 'togglecuffanimation') and lastCuff[player].target then
		local targetPlayer = game:GetService('Players'):GetPlayerFromCharacter(lastCuff[player].target)

		if targetPlayer then
			lastAnim[targetPlayer] = not lastAnim[targetPlayer]
			cuffsModule.animation[targetPlayer] = lastAnim[targetPlayer]
			cuffsModule.cuffed[targetPlayer] = lastAnim[targetPlayer]

			cuffsEvent:FireClient(targetPlayer, 'ToggleCuffAnimation', lastAnim[targetPlayer])
		end
	end
	if (args[1]:lower() == 'cuff') and not lastCuff[player].target then
		local humanoid = target:FindFirstChildOfClass('Humanoid')
		local isPlayer = game:GetService('Players'):GetPlayerFromCharacter(target)
		local distance = player:DistanceFromCharacter(target.HumanoidRootPart.Position)
		local text = ('You are detaining %s\nClick to release, F to toggle cuffs')
		local tool = player.Character:FindFirstChild('Cuffs')
	
		for _, connection in next, lastCuff[player].connections do
			connection:Disconnect()
		end
	
		if (distance > MAX_DETAIN_DISTANCE) or (humanoid.Health <= 0) or not tool then
			return
		end
	
		if isPlayer then
			lastCuff[player].connections[#lastCuff[player].connections + 1] = tool.AncestryChanged:connect(function(_, parent)
				if not cuffsModule.toggled[player.Character] then
					for _, connection in next, lastCuff[player].connections do
						connection:Disconnect()
					end
					
					return
				end
				
				if (parent ~= player.Character) then
					cuffsEvent:FireClient(player, 'Cuffing', target, 'You are detaining ' .. target.Name, .04)
				else
					cuffsEvent:FireClient(player, 'Cuffing', target, text:format(target.Name), .075)
				end
			end)
			
			cuffsEvent:FireClient(player, 'Cuffing', target, text:format(target.Name), .075)
		end
		
		lastCuff[player].target = target
		cuffsModule.Toggle(true, player.Character, target)
	elseif (args[1]:lower() == 'uncuff') and lastCuff[player].target then
		cuffsEvent:FireClient(player, 'Uncuffing')
		cuffsModule.Toggle(false, player.Character, target or lastCuff[player].target)
		
		lastCuff[player].target = nil
	end
end)

game:GetService('Players').PlayerAdded:connect(function(player)
	player.CharacterAdded:connect(function(character)
		cuffsEvent:FireClient(player, 'ToggleCuffAnimation', cuffsModule.cuffed[player])
		
		lastAnim[player] = false
		cuffsModule.animation[player] = false
	end)
end)