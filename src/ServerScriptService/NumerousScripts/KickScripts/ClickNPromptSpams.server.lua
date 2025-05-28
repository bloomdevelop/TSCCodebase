
local Players = game:GetService('Players')
local WHM = require(game.ServerScriptService["Hayper's Scripts"].WebhookHandler)

local round = math.round

local Cache = {}

local bypassed = {
	"Primary",
	"CoffeePot",
	"Station1CallButton",
	"Station2CallButton",
	"Station1Button",
	"Station2Button",
	"Button",
	"Hitbox"
}

function trigger(trigger: ClickDetector | ProximityPrompt, player: Player)
	--print(player.Name .. " interacted with " .. trigger.Parent.Name)
	Cache[player.Name] = (Cache[player.Name] or 0) + 1
	if bypassed[tonumber((trigger.Parent :: Part).Name) :: number] ~= nil then
		return
	end
	if trigger.MaxActivationDistance == 0 then
		WHM.queueMessage(player.Name .. " [" .. player.UserId .. "] interacted with " .. (trigger.Parent :: Part).Name .. ". (Disabled)", "Button")
		player:Kick('\n\nRemoved for using a prompt too far.\n\nInteraction has been logged.')
	elseif (trigger.Parent :: Part):IsA('BasePart') and player.Character ~= nil and player.Character:FindFirstChild('HumanoidRootPart') then
		local distance = math.abs(((trigger.Parent :: Part).Position - ((player.Character :: Model):FindFirstChild("HumanoidRootPart") :: Part).Position).Magnitude)
		if (math.abs(trigger.MaxActivationDistance) + 15) < distance then
			WHM.queueMessage(player.Name .. " [" .. player.UserId .. "] interacted with " .. (trigger.Parent :: Part).Name .. " from " .. round(distance) .. " of " .. round(trigger.MaxActivationDistance) .. " studs.", "Button")
		end
		if (math.abs(trigger.MaxActivationDistance) + 20) < distance then
			player:Kick('\n\nRemoved for using a prompt too far.\n\nInteraction has been logged.')
		end
	end
end

for _, i: Instance in next, game.Workspace:GetDescendants() do
	if i:IsA('ClickDetector') then
		i.MouseClick:Connect(function(...) trigger(i, ...) end)
	elseif i:IsA('ProximityPrompt') then 
		i.Triggered:Connect(function(...) trigger(i, ...) end)
	end
end

coroutine.wrap(function()
	while true do
		for p, i in next, Cache do
			if i > 30 then
				if Players:FindFirstChild(p) ~= nil then
					Players[p]:Kick('\n\nRemoved for spamming prompts')
				else
					Cache[p] = nil
				end
			end
			Cache[p] -= 1
		end
		task.wait(0.4)
	end
end)()
