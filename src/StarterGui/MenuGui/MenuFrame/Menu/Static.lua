-- // Steven_Scripts, 2022

local plr = game.Players.LocalPlayer

local menuFrame = script.Parent.Parent
local cameraEffects = menuFrame.Viewport.CameraEffects
local staticTransparency = menuFrame.StaticTransparency
local staticEffectFrame = cameraEffects.Static

local images = {}
for i,image in pairs(staticEffectFrame:GetChildren()) do
	if image:IsA("ImageLabel") then
		images[i] = image
	end
end
local lastImageIndex = 1

local rng = Random.new()

local function updateStaticTransparency()
	local transparency = staticTransparency.Value
	for i,image in pairs(images) do
		if transparency == 0 then
			staticEffectFrame.Grey.Visible = true
			image.ImageTransparency = 0.8
		else
			staticEffectFrame.Grey.Visible = false
			image.ImageTransparency = transparency
		end
	end
end

updateStaticTransparency()
staticTransparency:GetPropertyChangedSignal("Value"):Connect(updateStaticTransparency)

coroutine.wrap(function()
	while true do
		if staticTransparency.Value < 1 then
			local nextImageIndex = rng:NextInteger(1, #images)
			if nextImageIndex == lastImageIndex then
				nextImageIndex = nextImageIndex+1
				if nextImageIndex > #images then
					nextImageIndex = 1
				end
			end
			
			images[lastImageIndex].Visible = false
			
			local nextImage = images[nextImageIndex]
			nextImage.Rotation = nextImage.Rotation+180
			nextImage.Visible = true
			
			lastImageIndex = nextImageIndex
		end
		task.wait(.0333)
	end
end)()

return true