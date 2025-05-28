local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')

local Network = {}

local Replication = {
	_Connections = {},
	_Coroutines = {},
	Replications = {
		Heads = {},
		Torsos = {},
	}
}

IsRealNumber = function(num)
	return (typeof(num) == "number") and (num == num) and (math.abs(num) ~= math.huge)
end

do 
	Network.__index = Network

	Network.Remote 				= ReplicatedStorage.Remotes.Replicate
	Network.lastPing			= tick()
	Network.pingRate			= 1
	Network.keys				= {}
	Network.pings				= {}
	Network.watchers			= {}
	Network.events				= {}
	Network.dtick				= {}
	Network.players				= Players:GetPlayers()

	function Network:GetKey(player)
		if not Network.keys[player] then
			Network.keys[player] = 1
		end
		Network.keys[player] = 8675435*Network.keys[player]%8675439
		return Network.keys[player]
	end

	function Network:GetPing(player)
		if not Network.pings[player] then
			Network.pings[player] = 0
		end
		return Network.pings[player]
	end

	function Network:Watch(name, callback)
		Network.watchers[name] = callback
	end

	function Network:Add(name, callback)
		if Network.events[name] then return warn('[ Network ] : This event "'..name..'" already exists.') end
		Network.events[name] = callback
	end

	function Network:Remove(name)
		if Network.events[name] then
			Network.events[name] = nil
			--print('[ Network ] : Removed event "'..name..'".')
		else
			warn('[ Network ] : This event "'..name..'"" does not exist.')
		end
	end

	function Network:Modify(name, callback)
		if Network.events[name] then
			Network.events[name] = callback
			--print('[ Network ] : Changed event "'..name..'".')
		else
			warn('[ Network ] : This event "'..name..'"" does not exist.')
		end
	end

	function Network:Send(player, name, ...)
		local watcher = Network.watchers[name]
		if watcher then
			watcher(...)
		end
		if type(player) == "table" then
			for _, plr in next, player do
				Network.Remote:FireClient(plr, name, ...)
			end
		else
			Network.Remote:FireClient(player, name, ...)
		end
	end

	function Network:Bounce(name, ...)
		local watcher = Network.watchers[name]
		if watcher then
			watcher(...)
		end
		Network.Remote:FireAllClients(name, ...)
	end

	local function call(player, name, key, ...)
		local lolkey = Network.keys[player]
		if key == Network:GetKey(player) then
			local event = Network.events[name]
			if event then
				return event(player, ...)
			end
		else
			player:Kick('funky guy')
			Network.keys[player] = lolkey
		end
	end

	local function bouncecall(player, name, key, ...)
		local lolkey = Network.keys[player]
		if key == Network:GetKey(player) then
			local watcher = Network.watchers[name]
			if watcher then
				watcher(...)
			end
			for _, plr in next, Network.players do
				if plr ~= player then
					Network.Remote:FireClient(plr, name, ...)
				end
			end
		else
			player:Kick('Stop it!!')
			Network.keys[player] = lolkey
		end
	end

	Network.Remote.OnServerEvent:Connect(call)

	--print('[ SERVER ]( NETWORK ) : Initialized connections to remotes')

	Network:Add("ping", function(player, stick, ptick)
		local ctick = tick()
		local ping  = ( ctick - stick ) / 2
		local dtick = ptick - ping
		ping = ping < 0.5 and ping or 0.5
		if Network.dtick[player] then
			Network.dtick[player] = (0.95 * Network.dtick[player]) + (0.05 * dtick)
		else
			Network.dtick[player] = dtick
		end
		if Network.pings[player] then
			Network.pings[player] = (0.95 * Network.pings[player]) + (0.05 * ping)
		else
			Network.pings[player] = ping
		end
	end)

	--print('[ SERVER ]( NETWORK ) : Initialized network pinging')

	RunService.Heartbeat:Connect(function()
		--print('-- PINGING')
		local loltick = tick()
		if 1 / Network.pingRate < loltick - Network.lastPing then
			Network.lastPing = loltick
			for _, player in next, Network.players do
				Network:Send(player, "ping", loltick, Network.pings[player])
			end
		end
	end)

	Players.PlayerAdded:Connect(function(player)
		table.insert(Network.players, player)
		Network:Send(player, "ping", tick(), 0)
	end)

	Players.PlayerRemoving:Connect(function(player)
		for index, plr in next, Network.players do
			if plr.Name == player.Name then
				table.remove(Network.players, index)
			end
		end
		if Network.dtick[player] then
			Network.dtick[player] = nil
		end
		if Network.pings[player] then
			Network.pings[player] = nil
		end
		if Network.keys[player] then
			Network.keys[player] = nil
		end
	end)
end

do 
	--[[ Register Replication ]]

	Replication._Coroutines["BodyReplication"] = coroutine.create(function()
		while true do
			task.wait(0.15)
			Network:Bounce("armrep", Replication.Replications.Arms)
			Network:Bounce("headrep", Replication.Replications.Heads)
			Network:Bounce("torsorep", Replication.Replications.Torsos)
		end
	end)

	--print('[ SERVER ]( REPLICATION ) : Initialized replication in Coroutines at BodyReplication')

	Network:Add("headrep", function(player, vect)
		if not IsRealNumber(vect.X) then return end
		if not IsRealNumber(vect.Y) then return end
		Replication.Replications.Heads[player.Name] = vect
	end)

	Network:Add("torsorep", function(player, vect)
		if not IsRealNumber(vect.X) then return end
		if not IsRealNumber(vect.Y) then return end
		Replication.Replications.Torsos[player.Name] = vect
	end)

	--print('[ SERVER ]( REPLICATION ) : Initialized network listeners')

	Replication._Connections["PlayerRemoving"] = Players.PlayerRemoving:Connect(function(
		player)
		-- --print('[ SERVER ]( REPLICATION ) : Removed player "'..player.Name..'" from Replication')
		for _,t in next, Replication.Replications do
			for k, _ in next, t do
				if k == player.Name then
					t[k] = nil
				end
			end
		end
	end)

	coroutine.resume(Replication._Coroutines["BodyReplication"])

	--print('[ SERVER ]( REPLICATION ) : Started replication in _Coroutines at BodyReplication')
end

