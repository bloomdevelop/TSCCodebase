local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local Remote = ReplicatedStorage.Remotes.RadioEffect

Remote.OnServerEvent:Connect(function(plr)
	plr:Kick('Invalid request.')
end)

local running = false
local audios = {}

for _, f in next, ReplicatedStorage.SFX.Radio:GetChildren() do
	if f:IsA('Folder') then
		audios[f.Name] = #f:GetChildren()
	end
end

function shortwave()
	running = true
	local rand = math.random(1, audios["Shortwave"])
	Remote:FireAllClients("Shortwave", rand)
	task.wait(ReplicatedStorage.SFX.Radio.Shortwave["Shortwave"..tostring(rand)].TimeLength)
	running = false
end

function random()
	running = true
	local rand = math.random(1, audios["Random"])
	Remote:FireAllClients("Random", rand)
	task.wait(ReplicatedStorage.SFX.Radio.Random["Random"..tostring(rand)].TimeLength)
	running = false
end

RunService.Heartbeat:Connect(function()
	if not running then
		local r = math.random(1, 1000)
		if r < 4 then
			random()
		elseif r < 3 then
			shortwave()
		end
	end
end)
