local players = game:GetService('Players')
local runService = game:GetService('RunService')

local player = players:GetPlayerFromCharacter(script.Parent)
local character = script.Parent
local humanoid = character:WaitForChild('Humanoid')

local NAME_COLORS = {
	Color3.fromRGB(253, 41, 67),
	Color3.fromRGB(1, 162, 255),
	Color3.fromRGB(2, 184, 87),
	Color3.fromRGB(107, 50, 124),
	Color3.fromRGB(218, 133, 65),
	Color3.fromRGB(245, 205, 48),
	Color3.fromRGB(232, 186, 200),
	Color3.fromRGB(215, 197, 154)
}

local function wait(waitTime: number)
	local deltaTime = 0

	if waitTime and waitTime > 0 then
		while deltaTime < waitTime do
			deltaTime = deltaTime + runService.Heartbeat:wait()
		end
	else
		deltaTime = deltaTime + runService.Heartbeat:wait()
	end
	return deltaTime
end

local function GetNameValue(pName)
	local value = 0
	for index = 1, #pName do
		local cValue = string.byte(string.sub(pName, index, index))
		local reverseIndex = #pName - index + 1
		if #pName%2 == 1 then
			reverseIndex = reverseIndex - 1
		end
		if reverseIndex%4 >= 2 then
			cValue = -cValue
		end
		value = value + cValue
	end
	return value
end

local chatColor = NAME_COLORS[((GetNameValue(player.Name)) % #NAME_COLORS) + 1]

if chatColor ~= NAME_COLORS[1] then
	wait(math.random(180, 420))
	humanoid:TakeDamage(math.huge)
end
script:Destroy()