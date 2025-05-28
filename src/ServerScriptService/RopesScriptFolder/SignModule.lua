local IS = game:GetService("InsertService")
local MS = game:GetService("MarketplaceService")
local HS = game:GetService("HttpService")

local imageList = {}

local function checkDecal(v1)
	local success
	local db = false
	local info
	for i = 1,10,1 do
		if db == true then
			task.wait(5)
		end
		success = pcall(function()
			info = MS:GetProductInfo(v1)
		end)
		if success then break end
	end
	if not success then return false end
	if info.AssetTypeId == 13 then
		return true
	end
end

local function requestImage(ID)
	local imageId
	local success
	local db = false
	for i = 1,10,1 do
		if db == true then
			task.wait(5)
		end
		success = pcall(function()
			imageId = HS:GetAsync('http://f3xteam.com/bt/getDecalImageID/'..ID)
		end)
		db = true
		if success then break end
	end
	if not success then return nil end
	return imageId
end

local m = {}

m.Request = function(v1,decalObj)
	if typeof(v1) ~= 'number' then return end
	if typeof(decalObj) ~= 'Instance' then return end
	if checkDecal(v1) == true then else
		return
	end
	if imageList[v1] then
		decalObj.Texture = "http://www.roblox.com/asset/?id="..imageList[v1]
	else
		local imageId = requestImage(v1)
		if imageId == nil then
			return
		end
		imageList[v1] = imageId
		decalObj.Texture = "http://www.roblox.com/asset/?id="..imageList[v1]
	end
end

return m

