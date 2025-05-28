-- // Steven_Scripts, 2022

local rst = game:GetService("ReplicatedStorage")
local cs = game:GetService("CollectionService")

local remotesFolder = rst.Remotes

local plrStationInteractions = {}
local jobStations = {}

local function isWithinRange(plr, model, range)
	local primaryPart = model.PrimaryPart
	local char = plr.Character

	if primaryPart and char then
		local root = char:FindFirstChild("HumanoidRootPart")
		if root and (root.Position - primaryPart.Position).Magnitude < range then
			return true
		end
	end

	return false
end

local function jobStationStopRequest(plr, model, completed)
	local jobStation = jobStations[model]
	if jobStation then
		local lastStationInteraction = plrStationInteractions[plr.UserId]

		plrStationInteractions[plr.UserId] = {
			Model = nil,
			Timestamp = os.clock()
		}

		jobStation:OnEnded(plr, lastStationInteraction, completed)
	end
end

local function jobStationStartRequest(plr, model)
	local jobStation = jobStations[model]
	
	if jobStation then
		local lastStationInteraction = plrStationInteractions[plr.UserId]
		if lastStationInteraction.Model ~= nil then
			---- Cancel player's current task
			jobStationStopRequest(plr, lastStationInteraction.Model, false)
		end
		
		if isWithinRange(plr, model, 5) and jobStation:CanStart(plr, lastStationInteraction) then
			plrStationInteractions[plr.UserId] = {
				Model = model,
				Timestamp = os.clock()
			}
			
			coroutine.wrap(function()
				jobStation:OnStarted(plr, lastStationInteraction)
			end)()
			
			return true
		end
	end
	
	return false
end

local function playerAdded(plr)
	plrStationInteractions[plr.UserId] = {
		Model = nil,
		Timestamp = os.clock(),
	}
end

local function playerRemoving(plr)
	local stationInteraction = plrStationInteractions[plr.UserId]
	if stationInteraction.Model ~= nil then
		jobStationStopRequest(plr, stationInteraction.Model, false)
	end
	
	plrStationInteractions[plr.UserId] = nil
end

---- Initializing
local models = cs:GetTagged("JobStation")

for i,model in pairs(models) do
	local jobType = model.JobType.Value

	local module = script:FindFirstChild(jobType)
	if module == nil then
		warn("Job station '"..jobType.."' does not exist! ("..model:GetFullName()..")")
	else
		module = require(module)

		local jobStation = module.new(model)
		jobStations[model] = jobStation
	end
end

remotesFolder.JobStations.Start.OnServerInvoke = jobStationStartRequest
remotesFolder.JobStations.Stop.OnServerEvent:Connect(jobStationStopRequest)

game.Players.PlayerAdded:Connect(playerAdded)
game.Players.PlayerRemoving:Connect(playerRemoving)