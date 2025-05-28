--// 
--// NUMEROUS DESIGNS AND PROGRAMMING
--// COPYRIGHT 2022 (C)
--// ALL RIGHTS RESERVED
--// GRANTED PERMISSION TO USE TO THUNDER SCIENTIFIC CORPORATION GROUP
--// 

-- PREINITIALIZATION

_G.FRAMEWORK_DEBUG = false or game:GetService('RunService'):IsStudio()

local Typing = require(script.Typing)

local Framework: Typing.FrameworkType = {}

function printError(message, stack)
	local outMessages = {
		"---- Unhandled Error Handler | Numerous -----",
		string.format("Message<%s,%d> :\n%s\n", type(message), #message, message),
		string.format("Stack<%s,%d> :\n%s", type(stack), #stack, stack),
		"----------------------------------"}

	warn(table.concat(outMessages, "\n"))
end

function __task(self: Framework, r: nil, i: string)
	local module = script:FindFirstChild(i)
	assert(module, i .. " is not a valid module.")
	self.Logger.print('Starting module "' .. i .. '".')
	--local success = pcall(function()
		r = require(module)
		if type(r) == "function" then
			r = r(Framework)
		end
		return r
	--end)
	--if not success then
	--	self.Logger.warn('"' .. i .. '" failed to load')
	--	return nil
	--else
	--	self.Logger.print('Module "' .. i .. '" loaded.')
	--	return r
	--end
end

function __frameworkCall(self, i: string, threaded: boolean)
	if type(i) == "string" then
		local r = rawget(self, i)
		if not r then
			if threaded then
				local coro = coroutine.create(__task)
				local passed, data = coroutine.resume(coro, self, r, i)
				r = data
			else
				local data = __task(self, r, i)
				if data then
					rawset(self, i, data)
				end
			end
		end
		return r
	else
		self.Logger.error("Invalid argument provided.")
	end
end

function __moduleCall(self, i: string, recursive: boolean)
	if type(i) == "string" then
		local r = rawget(self, i)
		if not r then
			local module = Framework.Services.ReplicatedStorage:WaitForChild("Modules"):FindFirstChild(i, recursive)
			assert(module, i .. " is not a valid module.")
			Framework.Logger.print('Starting module "' .. i .. '".')
			local success = pcall(function()
				r = require(module)
				if type(r) == "function" then
					r = r(Framework)
				end
				rawset(self, i, r)
			end)
			if not success then
				Framework.Logger.warn('"' .. i .. '" failed to load')
				return nil
			else
				Framework.Logger.print('Module "' .. i .. '" loaded.')
			end
		end
	else
		Framework.Logger.error("Invalid argument provided.")
	end
end

function __serviceCall(self, i)
	local service = rawget(self, i) or game:FindService(i)
	if not service then
		warn(i .. " is not a service.")
		return nil
	end
	return service
end

function nprint(...)
	print('[ NUMEROUS / PRINT ]', ...)
end

function ndebug(...)
	if not _G.FRAMEWORK_DEBUG then
		return
	end
	warn('[ NUMEROUS / DEBUG ]', ...)
end

function nwarn(...)
	warn('[ NUMEROUS / WARN ]', ...)
end

function nerror(...)
	warn('[ NUMEROUS / ERROR ]', ...)
end

-- INITIALIZATION

Framework = setmetatable({
	Logger = { print = nprint, debug = ndebug, warn = nwarn, error = nerror },
	Functions = {},
	Announce = function(...)
		Framework("Network")
		Framework.Network:Send('GameAnnounce', ...)
	end,
	Modules = setmetatable({}, {
		__index = __moduleCall,
		__call = __moduleCall
	}),
	Services = setmetatable({},{
		__index = __serviceCall,
		__call = __serviceCall
	}),
}, {
	__index = __frameworkCall,
	__call = __frameworkCall
}) :: any

Framework.Services.ScriptContext.Error:Connect(function(message, trace, src)
	if script ~= src then
		return
	end
	printError(message, trace)
end)

Framework.Services("RunService")

if Framework.Services.RunService:FindFirstChild("__NUMEROUS_SERVER") then
	return warn(
		"\n-----------------------------" ..
			"\n- SERVER IS ALREADY STARTED -" ..
			"\n-----------------------------"
	)
else
	Instance.new("BoolValue", Framework.Services.RunService).Name = "__NUMEROUS_SERVER"
end

-- POST INITIALIZATION
local _requiredServices: {string} = {
	"Workspace",
	"Players",
	"ReplicatedFirst",
	"ReplicatedStorage",
	"Teams",
	"SoundService",
	"Chat",
	"RunService"
}

for _, service_name: string in next, _requiredServices do
	Framework.Services(service_name)
end

-- CORE

Typing(Framework)
Framework.Logger.print("Can't wait to crash! Hello server.")
Framework.Modules("Immutable")
Framework.Modules("Raycaster")
Framework.Modules("Animations")
Framework("Network")
Framework("UserInput")
Framework("Interface")
Framework("Playerstates")
Framework("BodyViewPoint")

--Framework.UserInput:AddInput('ping', Enum.KeyCode.X, function()
--	Framework.Logger.print(string.format('Ping is %dms', math.round(Framework.Network:GetPing() * 1000)))
--end)