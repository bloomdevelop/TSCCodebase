local tool = script.Parent
local player = tool.Parent.Parent

local setting = require(tool:WaitForChild('Settings'))
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

if not player:IsA('Player') then script:Destroy() end

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

if tool:FindFirstChild('Liquid') then tool.Liquid.Color = chatColor end
if chatColor == NAME_COLORS[1] then
	tool.Name = 'Cup of strawberry juice'
	setting.Message = 'It tastes like strawberry juice.'
elseif chatColor == NAME_COLORS[2] then
	tool.Name = 'Cup of juice'
	setting.Message = 'It tastes like a combination of fruit juices.'
elseif chatColor == NAME_COLORS[3] then
	tool.Name = 'Cup of Mountain Dew'	
	setting.Message = 'It tastes like a Mountain Dew drink.'
elseif chatColor == NAME_COLORS[4] then
	tool.Name = 'Cup of Fanta Cassis'
	setting.Message = 'It tastes like a Fanta Cassis drink.'
elseif chatColor == NAME_COLORS[5] then
	tool.Name = 'Cup of tropical juice'
	setting.Message = 'It tastes like a combination of tropical fruits.'
elseif chatColor == NAME_COLORS[6] then
	tool.Name = 'Cup of lemonade'
	setting.Message = 'It tastes like a lemonade.'
elseif chatColor == NAME_COLORS[7] then
	tool.Name = 'Cup of smoothie'
	setting.Message = 'It tastes like a smoothie combined with fruits.'
elseif chatColor == NAME_COLORS[8] then
	tool.Name = 'Cup of Fanta Lemon'
	setting.Message = 'It tastes like a Fanta Lemon drink.'
end
script:Destroy()