--// 
--// NUMEROUS DESIGNS AND PROGRAMMING
--// COPYRIGHT 2022 (C)
--// ALL RIGHTS RESERVED
--// GRANTED PERMISSION TO USE TO THUNDER SCIENTIFIC CORPORATION GROUP
--// 

-- PREINITIALIZATION

_G.FRAMEWORK_DEBUG = false or game:GetService('RunService'):IsStudio()

Typing = require(script.Typing)

local Framework: Typing.FrameworkType = nil


function printError(message, stack)
	local outMessages = {
		"---- Unhandled Error Handler | Numerous -----",
		string.format("Message<%s,%d> :\n%s\n", type(message), #message, message),
		string.format("Stack<%s,%d> :\n%s", type(stack), #stack, stack),
		"----------------------------------"}

	warn(table.concat(outMessages, "\n"))
end

function __frameworkCall(self, i: string | Instance, recursive: boolean)
	if type(i) == "string" then
		local r = rawget(self, i)
		if not r then
			local module = script:FindFirstChild(i, recursive) or Framework.Services.ReplicatedStorage:WaitForChild("Modules"):FindFirstChild(i, recursive)
			assert(module, i .. " is not a valid module.")
			local success = pcall(function()
				r = require(module)
				if type(r) == "function" then
					r = r(Framework)
				end
				rawset(self, i, r)
			end)
			if not success then
				Framework.Logger.warn(i .. ' failed to load')
				return nil
			end
		end
		return r
	elseif type(i) == "userdata" --[[ is an Instance ]] and i:IsA('ModuleScript') then
		local exec
		local success = pcall(function(i)
			exec = require(i)
		end)
		if success then
			return exec
		else
			Framework.Logger.warn(i.Name .. ' failed to load')
			return nil
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
	"ServerStorage",
	"Teams",
	"SoundService",
	"Chat",
	"RunService"
}

for _, service_name: string in next, _requiredServices do
	Framework.Services(service_name)
end

-- CORE

Framework.Logger.print("Another day, another bug. Hello clients!")
Framework("Network")
Framework("PlayerHandler")