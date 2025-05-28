Typing = require(script.Parent.Typing)
return function(Framework: Typing.FrameworkType)
	-- INITILAIZATION
	local Network: Typing.NetworkTyping = {
		Pings = {},
		Keys = {},
		Ticks = {},
		Watchers = {},
		Events = {},
		Players = {},
		Remotes = {
			Fetch		= Framework.Services.ReplicatedStorage:WaitForChild('Network'):WaitForChild('Fetch'),
			Send		= Framework.Services.ReplicatedStorage:WaitForChild('Network'):WaitForChild('Send')
		}
	}
	
	-- PRIVATE VARIABLES
	
	local _lastPing: number = tick()

	-- STRUCTURE
	
	function Network.GenKey(self, player: Player): number
		if not self.Keys[player] then
			self.Keys[player] = 1
		end
		self.Keys[player] = 312622 * self.Keys[player] % 312628
		return self.Keys[player]
	end
	
	function Network.GetKey(self, player: Player): number
		if not self.Keys[player] then
			self.Keys[player] = 1
		end
		return self.Keys[player]
	end
	
	function Network.GetPing(self, player: Player): number
		if not self.Pings[player.Name] then
			self.Pings[player.Name] = 0
		end
		return self.Pings[player.Name]
	end

	function Network.Add(self, name: string, callback: (Player, ...any) -> (...any)): nil
		if self.Events[name] then
			Framework.Logger.debug('[ NETWORK / DEBUG ]', 'Event "' .. name .. '" already exists.')
			return nil
		end
		self.Events[name] = callback
		Framework.Logger.debug('[ NETWORK / DEBUG ]', 'Event "' .. name .. '" has been added.')
	end

	function Network.Remove(self, name: string): nil
		if not self.Events[name] then
			Framework.Logger.debug('[ NETWORK / DEBUG ]', 'Event "' .. name .. '" doesn\'t exists.')
			return nil
		end
		self.Events[name] = nil
		Framework.Logger.debug('[ NETWORK / DEBUG ]', 'Event "' .. name .. '" has been removed.')
	end

	function Network.Modify(self, name: string, callback: (Player, ...any) -> (...any)): nil
		if not self.Events[name] then
			Framework.Logger.debug('[ NETWORK / DEBUG ]', 'Event "' .. name .. '" doesn\'t exists. Overwriting anyways.')
		end
		self.Events[name] = callback
		Framework.Logger.debug('[ NETWORK / DEBUG ]', 'Event "' .. name .. '" has been modified.')
	end

	function Network.Send(self, to: Player | string | Array<Player | string>, name: string, ...: any): nil
		if type(to) == 'string' then
			to = Framework.Services.Players:FindFirstChild(to)
		end
		if type(to) == 'userdata' then
			self.Remotes.Send:FireClient(to, name, ...)
		elseif type(to) == 'table' then
			for _, plr: Player | string in next, to do
				if type(plr) == 'string' then
					plr = Framework.Services.Players:FindFirstChild(plr)
				end
				self.Remotes.Send:FireClient(plr, name, ...)
			end
			table.clear(to)
		else
			Framework.Logger.error('[ NETWORK / ERROR ]', 'Invalid player argument provided.', to)
		end
	end

	function Network.Fetch(self, to: Player | string | Array<Player | string>, name: string, ...: any): nil
		if type(to) == 'string' then
			to = Framework.Services.Players:FindFirstChild(to)
		end
		if type(to) == 'userdata' then
			self.Remotes.Send:FireClient(to, name, ...)
		elseif type(to) == 'table' then
			for _, plr: Player | string in next, to do
				if type(plr) == 'string' then
					plr = Framework.Services.Players:FindFirstChild(plr)
				end
				self.Remotes.Send:FireClient(plr, name, ...)
			end
			table.clear(to)
		else
			Framework.Logger.error('[ NETWORK / ERROR ]', 'Invalid player argument provided.', to)
		end
	end
	
	local function call(from: Player, name: string, key: number, ...: any): any
		if key == Network:GenKey(from) then
			if Network.Events[name] then
				return Network.Events[name](from, ...)
			end
		else
			local extraData = {
				['Key Sent'] = key,
				['Key Pass'] = Network:GetKey(from)
			}
			local identification = Framework.NACS:GenerateIdentification('player', from, extraData)
			Framework.Moderation:Log('Kick', from, 'Invalid Network Key', identification)
			Framework.Moderation:Kick(from, 'Server Network', 'Invalid key', identification)
			Framework.Moderation:Fire('Alert', string.format('%s sent an invalid key.', from.Name), Framework.Moderation.Enums.Priority.High, identification)
		end
		return nil
	end
	
	-- FINALIZE
	
	Network.Remotes.Send.OnServerEvent:Connect(call)
	Network.Remotes.Fetch.OnServerInvoke = call
	
	local reasons = {
		[0] = 'Unknown',
		[1] = 'Destroyed a child from client framework',
		[2] = 'Added a child from client framework',
		[3] = 'Destroyed client framework',
	}
	
	Network:Add('GameAnnounce', function(player, reason)
		local extraData = {
			['Reason'] = reason or reasons[reason] or reasons[0]
		}
		Framework.Logger.debug('[ PLAYER / FATAL ]', string.format('%s tried to exploit the client. | Reason: %s', player.Name, reason or reasons[reason] or reasons[0]))
		player:Kick(' ')
		local identification = Framework.NACS:GenerateIdentification('player', player, extraData)
		Framework.Moderation:Log('Kick', player, 'Exploiting client framework', identification)
		Framework.Moderation:Kick(player, 'Server Network', 'Unknown Client Behaviour', identification)
		Framework.Moderation:Fire('Alert', string.format('%s tried to exploit the framework.', player.Name), Framework.Moderation.Enums.Priority.Fatal, identification)
	end)
	
	Network:Add('ping', function(player, stick, ptick)
		local ctick = tick()
		local ping = (ctick - stick) / 2
		local dtick = ptick - ping
		ping = ping < 0.5 and ping or 0.5
		if Network.Ticks[player.Name] then
			Network.Ticks[player.Name] = (0.95 * Network.Ticks[player.Name]) + (0.05 * dtick)
		else
			Network.Ticks[player.Name] = dtick
		end
		if Network.Pings[player.Name] then
			Network.Pings[player.Name] = (0.95 * Network.Pings[player.Name]) + (0.05 * ping)
		else
			Network.Pings[player.Name] = ping
		end
	end)
	
	Framework.Services.RunService.Heartbeat:Connect(function()
		local lol = tick()
		if 1 / 1 < lol - _lastPing then
			_lastPing = lol
			for _, p: Player in next, Network.Players do
				Network:Send(p, "ping", lol, Network.Pings[p.Name])
			end
		end
	end)
	
	local function registerPlayer(player: Player)
		table.insert(Network.Players, player)
		Network.Pings[player.Name] = 0
		Network.Ticks[player.Name] = 0
		Network:Send(player, 'ping', tick(), 0)
		Framework.Logger.debug('[ NETWORK / DEBUG ]', string.format('Added %s to registry and pinged initialized.', player.Name))
	end
	
	local function unregisterPlayer(player: Player)
		table.remove(Network.Players, table.find(Network.Players, player))
		Network.Pings[player.Name] = nil
		Network.Ticks[player.Name] = nil
		Framework.Logger.debug('[ NETWORK / DEBUG ]', string.format('Removed %s from registry.', player.Name))
	end
	
	Framework.Services.Players.PlayerAdded:Connect(registerPlayer)
	Framework.Services.Players.PlayerRemoving:Connect(unregisterPlayer)

	for _, p: Player in next, Framework.Services.Players:GetPlayers() do
		registerPlayer(p)
	end
	
	Framework.Logger.debug('[ NETWORK / DEBUG ]', 'Initialized network, listening to clients.')

	return Network
end