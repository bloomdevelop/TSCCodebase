-- // Steven_Scripts, 2022

local tws = game:GetService("TweenService")

local bag = script.Parent
local comboUI = bag.ComboIndicator

local rng = Random.new()

local lastDamagedTimestamp = os.clock()
local cumulativeDamage = 0

local damageIndicatorTweenInfo = TweenInfo.new(.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

local function getDamageColor(damage)
	if damage > 200 then
		return Color3.fromHSV(0.764056, 1, 1)
	elseif damage > 100 then
		return Color3.fromHSV(1, 1, 1)
	elseif damage > 75 then
		return Color3.fromHSV(0.0666667, 1, 1)
	elseif damage > 50 then
		return Color3.fromHSV(0.155556, 1, 1)
	elseif damage > 20 then
		return Color3.fromHSV(0.333333, 1, 1)
	elseif damage > 10 then
		return Color3.fromHSV(0.564056, 1, 1)
	else
		return Color3.new(1, 1, 1)
	end
end

local function showDamageIndicator(damage)
	local ui = script.DamageIndicator:Clone()

	ui.TextLabel.Text = tostring(damage)
	ui.TextLabel.TextColor3 = getDamageColor(damage)

	local offset = Vector3.new(rng:NextNumber(-.3, .3), rng:NextNumber(-.3, .3), rng:NextNumber(-.3, .3))

	local startPosition = offset
	local endPosition = ui.ExtentsOffsetWorldSpace + offset

	ui.ExtentsOffsetWorldSpace = startPosition
	ui.Parent = bag

	local tween = tws:Create(ui, damageIndicatorTweenInfo, {ExtentsOffsetWorldSpace = endPosition})
	tween:Play()

	game.Debris:AddItem(ui, 2)

	cumulativeDamage = cumulativeDamage+damage
	comboUI.TextLabel.Text = tostring(cumulativeDamage)
	comboUI.TextLabel.TextColor3 = getDamageColor(cumulativeDamage)

	task.delay(2.1, function()
		if os.clock() - lastDamagedTimestamp > 2 then
			cumulativeDamage = 0
			comboUI.TextLabel.Text = ""
		end
	end)
end

local module = function(playerWhoShot, damage, gun, gunData)	
	local char = playerWhoShot.Character
	local root = char.HumanoidRootPart

	local impulseDirection = (bag.Position - root.Position).Unit
	bag:ApplyImpulseAtPosition(impulseDirection*damage*5, bag.Position+Vector3.new(0, 1.8, 0))

	showDamageIndicator(damage)
	lastDamagedTimestamp = os.clock()
end

return module