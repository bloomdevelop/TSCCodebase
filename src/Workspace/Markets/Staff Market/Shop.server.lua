local rst = game:GetService("ReplicatedStorage")

local remotesFolder
local clientAssetsFolder

local shop = script.Parent
local primaryPart = shop.PrimaryPart

local clickDetector = Instance.new("ClickDetector")
clickDetector.MaxActivationDistance = 10
clickDetector.Parent = primaryPart

function onClick(plr)
	if plr then
		if plr:DistanceFromCharacter(clickDetector.Parent.Position) <= clickDetector.MaxActivationDistance+1.1 then
			remotesFolder.Shop.ShopChanged:FireClient(plr, shop)
		end
	end
end

remotesFolder = rst:WaitForChild("Remotes")
clientAssetsFolder = rst:WaitForChild("Assets")

clientAssetsFolder.UI.DistanceUI:Clone().Parent = primaryPart

clickDetector.MouseClick:connect(onClick)