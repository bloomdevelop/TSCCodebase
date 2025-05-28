-- // Steven_Scripts, 2022

local sst = game:GetService("ServerStorage")

local bindablesFolder = sst.Bindables

local ring = script.Parent

local playersBoxing = {}
local diedConnections = {}

local joinCooldown = {}

local boundaryParts = ring.Boundaries:GetChildren()

local function removePlayer(plr)
	table.remove(playersBoxing, table.find(playersBoxing, plr))

	if diedConnections[plr] then
		diedConnections[plr]:Disconnect()
	end
	
	local char = plr.Character
	if char then
		char:SetAttribute("Boxing", nil)
	end
end

local function addPlayer(plr, boundaryPart)
	local char = plr.Character
	char:SetAttribute("Boxing", true)

	local teleportCF = CFrame.new(boundaryPart.CFrame*CFrame.new(0, 0, -5).Position)
	bindablesFolder.Anticheat.AuthorizeTeleport:Fire(plr, teleportCF)

	table.insert(playersBoxing, plr)

	diedConnections[plr] = char.Humanoid.Died:Connect(function()
		removePlayer(plr)

		local sound = script.KO:Clone()
		sound.Parent = char.Head
		sound:Play()
	end)
end

local function onPlayerLeaving(plr)
	if table.find(playersBoxing, plr) ~= nil then
		removePlayer(plr)
	end
end

local function onBoundaryTouched(boundaryPart, hit)
	local char = hit.Parent
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health > 0 then
		local plr = game.Players:GetPlayerFromCharacter(char)
		if plr and joinCooldown[plr] == nil then
			joinCooldown[plr] = true

			if table.find(playersBoxing, plr) == nil then
				addPlayer(plr, boundaryPart)
			elseif boundaryPart:FindFirstChild("CantLeave") == nil then
				removePlayer(plr)

				local teleportCF = CFrame.new(boundaryPart.CFrame*CFrame.new(0, 0, 5).Position)
				bindablesFolder.Anticheat.AuthorizeTeleport:Fire(plr, teleportCF)
			end

			task.wait(2)

			joinCooldown[plr] = nil
		end
	end
end

for i,part in pairs(boundaryParts) do
	part.Touched:Connect(function(hit)
		onBoundaryTouched(part, hit)
	end)
end

game.Players.PlayerRemoving:Connect(onPlayerLeaving)