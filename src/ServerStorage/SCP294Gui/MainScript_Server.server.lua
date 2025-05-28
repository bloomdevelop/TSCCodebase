local debris = game:GetService('Debris')

local player = script.Parent:FindFirstAncestorOfClass('Player')
local character = player.Character
local humanoid = character:WaitForChild('Humanoid')
local scp = workspace:FindFirstChild('SCP-294', true)

assert(scp, 'Could not find SCP-294 in Workspace!')
assert(scp:FindFirstChild('Body') and scp:FindFirstChild('Cup'), 'Got a different SCP-294 model in Workspace! Try renaming the other SCP-294 model.')

local body = scp:WaitForChild('Body')
local pad = scp:WaitForChild('Pad')
local cup = scp:WaitForChild('Cup')

local panel = script.Parent:WaitForChild('Panel')
local keyboard = panel:WaitForChild('Keyboard')
local enter = panel:WaitForChild('Enter')
local back = panel:WaitForChild('Back')
local close = script.Parent:WaitForChild('Close')

local resetter = scp:WaitForChild('Resetter')

local debounce = false
local drink = ''
local drinkChars = {}
local dispensing = scp:WaitForChild('Dispensing')
local user = scp:WaitForChild('User')

function closeGui()
	user.Value = ''
	resetter:Fire()
	debris:AddItem(script.Parent, 0.05)
end

for _, key in pairs(keyboard:GetChildren()) do
	if key:IsA('TextButton') then
		key.MouseButton1Down:Connect(function()
			if not debounce and not dispensing.Value and not body.OutOfRange.Playing then
				local char = key.Name
				if key.Name == 'Spacebar' then char = ' ' end
				drink = drink..char
				table.insert(drinkChars, char)
				pad.SurfaceGui.Input.Text = string.upper(drink)
			end
		end)
	end
end

back.MouseButton1Down:Connect(function()
	if not debounce and not dispensing.Value and not body.OutOfRange.Playing and drinkChars[1] then
		drink = ''
		table.remove(drinkChars, #drinkChars)
		for _, char in pairs(drinkChars) do drink = drink..char end
		pad.SurfaceGui.Input.Text = string.upper(drink)
	end
end)

close.MouseButton1Click:Connect(closeGui)
humanoid.Died:Connect(closeGui)

resetter.Event:Connect(function()
	if not dispensing.Value and cup.Handle.Transparency >= 1 then
		if body.OutOfRange.Playing then body.OutOfRange.Ended:wait() end
		drink = ''
		drinkChars = {}
	end
end)