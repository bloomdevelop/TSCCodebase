local tool = script.Parent

local handle = tool.Handle
local glowPart = tool.GlowPart

local equipped = false
local char = nil

tool.Equipped:Connect(function()
	equipped = true

	char = tool.Parent
	local charAtEquip = char
	task.wait(.2)
	if tool.Parent == charAtEquip then
		handle.Click:Play()
	end
	task.wait(.1)
	if tool.Parent == charAtEquip then
		glowPart.Transparency = 0
		glowPart.ServerLight.Enabled = true
		glowPart.RadialLight.Enabled = true
	end
end)

tool.Unequipped:Connect(function()
	equipped = false

	glowPart.Transparency = 1
	glowPart.ServerLight.Enabled = false
	glowPart.RadialLight.Enabled = false
end)