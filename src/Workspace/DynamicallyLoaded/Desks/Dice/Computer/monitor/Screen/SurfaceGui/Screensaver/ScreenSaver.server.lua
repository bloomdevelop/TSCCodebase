-- // Steven_Scripts, 2022
-- yes, I ripped this from warm isolation

local screensaverUI = script.Parent
local screensaverIcon = screensaverUI.Icon

local screensaverLowerBounds = Vector2.new(screensaverIcon.AbsoluteSize.X/2, screensaverIcon.AbsoluteSize.Y/2)
local screensaverUpperBounds = Vector2.new(screensaverUI.AbsoluteSize.X-screensaverIcon.AbsoluteSize.X/2, screensaverUI.AbsoluteSize.Y-screensaverIcon.AbsoluteSize.X/2)

local rng = Random.new()

local position = Vector2.new(
	rng:NextNumber(screensaverLowerBounds.X, screensaverUpperBounds.X),
	rng:NextNumber(screensaverLowerBounds.Y, screensaverUpperBounds.Y)
)
local direction = Vector2.new(1, 1)

while true do
	position = position + direction*20

	local flipX = position.X < screensaverLowerBounds.X or position.X > screensaverUpperBounds.X
	local flipY = position.Y < screensaverLowerBounds.Y or position.Y > screensaverUpperBounds.Y

	if flipX or flipY then
		local XMultiplier = (flipX and -1) or 1
		local YMultiplier = (flipY and -1) or 1

		direction = direction*Vector2.new(XMultiplier, YMultiplier)
	end

	screensaverIcon.Position = UDim2.new(0, position.X, 0, position.Y)

	task.wait(.1)
end