-- // Steven_Scripts, 2022

local sst = game:GetService("ServerStorage")
local cs = game:GetService("CollectionService")

local bindablesFolder = sst.Bindables

local authorizedTeleports = {}
local ignoredPlayers = {}

local permanentRaycastBlacklist = {}

local disabled = true -- Set this to true if you need to temporarily disable the noclip prevention.
local noExceptions = false -- Set this to true to prevent the noclip prevention from ignoring DI+

local function checkIsPartOfOpenDoor(part : BasePart, maxRecursions : number)
	local parent = part.Parent
	for i=1, maxRecursions do
		if parent:IsA("Workspace") then
			-- Nope
			return false
		elseif table.find(cs:GetTags(parent), "DoorInteractable") and parent.Closed.Value == false then
			return true, parent
		end

		parent = parent.Parent
	end

	return false
end

local getPathBlocked
getPathBlocked = function(origin, goal, temporaryBlacklist)
	if temporaryBlacklist == nil then
		temporaryBlacklist = {}
	end

	local raycastParams = RaycastParams.new()

	local localBlacklist = permanentRaycastBlacklist
	for i,v in pairs(temporaryBlacklist) do
		table.insert(localBlacklist, v)
	end

	raycastParams.FilterDescendantsInstances = localBlacklist
	raycastParams.IgnoreWater = true

	local direction = goal - origin
	local result = workspace:Raycast(origin, direction, raycastParams)

	if result and result.Instance ~= nil then
		local instance = result.Instance
		if instance:IsA("BasePart") and (instance.CanCollide == false or instance.Anchored == false) then
			-- Not a solid wall; doesn't count. Add to permanent blacklist and try again.
			table.insert(permanentRaycastBlacklist, instance)
			return getPathBlocked(origin, goal, temporaryBlacklist)
		else
			-- Check to see if it's an open door
			local isPartOfOpenDoor, door = checkIsPartOfOpenDoor(instance, 4)
			if isPartOfOpenDoor then
				-- Part of an open door. Add door to temporary blacklist and try again.
				table.insert(temporaryBlacklist, door)
				return getPathBlocked(origin, goal, temporaryBlacklist)
			else
				-- Path's blocked
				return true
			end
		end
	else
		-- Path's clear
		return false
	end
end

local function playerAdded(plr: Player)
	local rank = plr:GetRankInGroup(11577231)
	if disabled == true or (rank >= 10 and noExceptions == false) then
		-- Either the player is a department intern or higher, or the noclip prevention is disabled. Don't perform noclip checks.
		ignoredPlayers[plr] = true
		return
	end
	
	if disabled == true or (plr:IsInGroup(12715058) and noExceptions == false) then
		-- Either the player is a department intern or higher, or the noclip prevention is disabled. Don't perform noclip checks.
		ignoredPlayers[plr] = true
		return
	end

	plr.CharacterAdded:Connect(function(char)
		local root = char:WaitForChild("HumanoidRootPart")
		local hum = char:WaitForChild("Humanoid")
		local lastPosition = root.Position

		table.insert(permanentRaycastBlacklist, char)

		-- Wait for them to load in
		if char.Parent == nil then
			repeat task.wait() until char.Parent ~= nil
		end

		-- Start checking
		while char.Parent ~= nil do
			task.wait(.2)
			local newPosition = root.Position

			if authorizedTeleports[plr] == true then
				-- Ignore it this time
				authorizedTeleports[plr] = nil
			else
				local pathblocked = getPathBlocked(lastPosition, newPosition)
				if pathblocked then
					-- Something blocked that way, send the player back
					if hum.Sit == true then hum.Sit = false end
					
					root.CFrame = CFrame.new(lastPosition)
					newPosition = lastPosition
				end
			end

			lastPosition = newPosition
		end
	end)

	plr.CharacterRemoving:Connect(function(char)
		table.remove(permanentRaycastBlacklist, table.find(permanentRaycastBlacklist, char))
	end)
end

local function playerRemoving(plr)
	if ignoredPlayers[plr] == true then
		ignoredPlayers[plr] = nil
	end
end

local function authorizeTeleport(plr, cf)
	local char = plr.Character
	if not char then char = plr.CharacterAdded:Wait() end
	local root = char:WaitForChild("HumanoidRootPart", 10)

	if root then
		if ignoredPlayers[plr] == nil then
			authorizedTeleports[plr] = true
		end
		root.CFrame = cf
	end
end

bindablesFolder.Anticheat.AuthorizeTeleport.Event:Connect(authorizeTeleport)
game.Players.PlayerAdded:Connect(playerAdded)
game.Players.PlayerRemoving:Connect(playerRemoving)