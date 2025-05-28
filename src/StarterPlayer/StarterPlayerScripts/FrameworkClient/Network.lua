Typing = require(script.Parent.Typing)
return function(Framework: Typing.FrameworkType)
	-- INITILAIZATION
	local Network: Typing.NetworkType = {
		Key = 1,
		Ping = 0,
		Watchers = {},
		Events = {},
		Queue = {},
		Remotes = {
			Fetch		= Framework.Services.ReplicatedStorage:WaitForChild('Network'):WaitForChild('Fetch'),
			Send		= Framework.Services.ReplicatedStorage:WaitForChild('Network'):WaitForChild('Send')
		},
		IgnoredEvents = {
			['armrep'] = true,
			['headrep'] = true,
			['torsorep'] = true
		}
	}

	-- STRUCTURE

	function Network.GetKey(self): number
		return self.Key
	end

	function Network.GenKey(self): number
		self.Key = 312622 * self.Key % 312628
		return self.Key
	end

	function Network.GetPing(self): number
		return self.Ping
	end

	--function Network.Watch(self, name: string, callback: (...any) -> (...any)): nil
	--	if not self.Watchers[name] then
	--		self.Watchers[name] = {}
	--		Framework.Logger.debug('[ NETWORK / DEBUG ]', 'Watcher list %s does not exist. Creating empty table...')
	--	end
	--	table.insert(self.Watchers[name], callback)
	--	Framework.Logger.debug('[ NETWORK / DEBUG ]', 'Added callback ', callback, ' to watcher list %s')
	--end

	--function Network.Unwatch(self, name: string): nil
	--	if self.Watchers[name] then
	--		table.clear(self.Watchers[name])
	--		Framework.Logger.debug('[ NETWORK / DEBUG ]', 'Cleared watcher list %s')
	--	else
	--		Framework.Logger.debug('[ NETWORK / DEBUG ]', 'Watcher list %s does not exist.')
	--	end
	--end

	function Network.Add(self, name: string, callback: (...any) -> (...any)): nil
		if self.Events[name] then
			Framework.Logger.error('[ NETWORK / FATAL ]', string.format('Event "%s" already exists.', name))
			return
		end
		self.Events[name] = callback
		Framework.Logger.debug('[ NETWORK / DEBUG ]', string.format('Added event "%s".', name))
		if self.Queue[name] then
			local total = #self.Queue[name]
			Framework.Logger.debug('[ NETWORK / DEBUG ]', string.format('Unpacking %d data packets to event "%s".', total, name))
			for i = 1, total do
				callback(unpack(self.Queue[name][i]))
			end
			table.clear(self.Queue[name])
			Framework.Logger.debug('[ NETWORK / DEBUG ]', string.format('Unpacked %d data packets to event "%s".', total, name))
		end
	end

	function Network.Remove(self, name: string): nil
		if self.Events[name] then
			self.Events[name] = nil
			Framework.Logger.debug('[ NETWORK / DEBUG ]', string.format('Removed event "%s".', name))
		else
			Framework.Logger.debug('[ NETWORK / DEBUG ]', string.format('Event "%s" does not exist.', name))
		end
	end

	function Network.Modify(self, name: string, callback: (...any) -> (...any)): nil
		if self.Events[name] then
			self.Events[name] = callback
			Framework.Logger.debug('[ NETWORK / DEBUG ]', string.format('Removed event "%s".', name))
		else
			Framework.Logger.debug('[ NETWORK / DEBUG ]', string.format('Event "%s" does not exist.', name))
		end
	end

	function Network.Send(self, name: string, ...): nil
		self.Remotes.Send:FireServer(name, self:GenKey(), ...)
	end

	function Network.Fetch(self, name, ...): (...any)
		return self.Remotes.Fetch:InvokeServer(name, self:GenKey(), ...)
	end

	local function call(name, ...): any | nil
		local event = Network.Events[name]
		if event then
			return event(...)
		else
			if Network.IgnoredEvents[name] then
				return nil
			end
			if not Network.Queue[name] then
				Network.Queue[name] = {}
				Framework.Logger.debug('[ NETWORK / DEBUG ]', string.format('Queue list "%s" created.', name))
			end
			Network.Queue[name][#Network.Queue[name] + 1] = {...}
		end
		return nil
	end

	-- FINALIZE

	Network.Remotes.Send.OnClientEvent:Connect(call)
	Network.Remotes.Fetch.OnClientInvoke = call

	Network:Add('ping', function(a, b)
		Network.Ping = b
		Network:Send('ping', a, tick())
	end)

	Framework.Logger.debug('[ NETWORK / DEBUG ]', 'Initialized network, listening to server.')

	return Network
end