local jobStation = {}
jobStation.__index = jobStation

function jobStation.new(model)
	local self = setmetatable({}, jobStation)
	
	local cooldownVal = Instance.new("BoolValue")
	cooldownVal.Name = "Cooldown"
	cooldownVal.Parent = model
	
	self.Dishes = model.Dishes:GetChildren()
	self.Model = model
	self.Main = model.PrimaryPart
	self.CooldownValue = cooldownVal
	self.MinimumCompletionTime = 4/0.08*0.15
	self.PlayerInteracting = nil
	
	self:DirtyDishes()
	
	return self
end

function jobStation:StartFaucet()
	self.Main.Valve:Play()
	self.Main.Water:Play()

	self.Main.Gas.Enabled = true
end

function jobStation:StopFaucet()
	self.Main.Valve:Play()
	self.Main.Drain:Play()

	self.Main.Water:Stop()

	self.Main.Gas.Enabled = false
end

function jobStation:DirtyDishes()
	for i,dish in pairs(self.Dishes) do
		dish.Material = Enum.Material.CorrodedMetal
	end
end

function jobStation:CleanDishes()
	for i,dish in pairs(self.Dishes) do
		dish.Material = Enum.Material.Glass
	end
end

-- Distance checking is done automatically by JobStationSystem, don't worry about that
function jobStation:CanStart(plr, lastStationInteraction)
	if self.CooldownValue.Value == false and self.PlayerInteracting == nil then
		return true
	else
		return false
	end
end

function jobStation:OnEnded(plr, lastStationInteraction, completed)
	if self.PlayerInteracting == plr then
		self:StopFaucet()
		self.PlayerInteracting = nil
		
		if completed then
			---- Client says it finished the task. Let's see if that's possible.
			
			local timeUsed = os.clock() - lastStationInteraction.Timestamp
			if timeUsed >= self.MinimumCompletionTime then
				---- Player's been doing this task for long enough
				self.CooldownValue.Value = true
				
				-- Reward player
				local cash = plr:WaitForChild("leaderstats"):WaitForChild("Cash")
				cash.Value = cash.Value + 45
				
				self.Main.Earn:Play()
				
				-- Put self on cooldown
				self:CleanDishes()
				task.wait(50)
				self:DirtyDishes()
				
				-- Cooldown over
				self.CooldownValue.Value = false
			end
		end
	end
end

function jobStation:OnStarted(plr, lastStationInteraction)
	self:StartFaucet()
	self.PlayerInteracting = plr
end

return jobStation