local WS = game:GetService('Workspace')
local PS = game:GetService('Players')

local users = {}
local obj = {}
obj.__index = obj

function obj.new(model)	
	local v1 = model:GetAttribute('Type')
	if v1 == nil then
		warn(model.Name .. ' attribute "Type" was not found.')
		return
	end
	
	local self = {}
	setmetatable(self, obj)
	
	self.model = model
	self.backup = model:Clone()
	self.speachChange = nil
	self.clothingType = v1
	self.hats = nil
	self.owner = nil
	self.cleaning = false
	self.c1 = {} --Hat touched connections
	self.c2 = {} --Hat removed connections
	self.c3 = {}
	--[[
	[1] = Humanoid Died
	[2] = Player Leaving
	]]
	
	local v2 = model:GetAttribute('SpeachChange')
	
	if v2 ~= nil then
		self.speachChange = v2
	end
	
	self:_setup()
	
	v1,v2 = nil
	return self
end

function obj:_setup()
	self.hats = self.model:GetChildren()
	
	for i = 1,#self.hats,1 do
		self.c1[i] = self.hats[i].Handle.Touched:Connect(function(hit)
			self:_onTouch(hit)
		end)
		self.c2[i] = self.hats[i].AncestryChanged:Connect(function()
			if self.hats[i].Parent == nil or self.model.Parent == nil then else return end
			if self.cleaning == false then
				self:_return()
			end
		end)
	end
end

function obj:_onTouch(hit)
	if self.owner then return end
	if hit and hit.Parent and hit.Parent:FindFirstChild('Humanoid') and hit.Parent.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then else return end
	local char = hit.Parent
	local plr = PS:GetPlayerFromCharacter(char)
	if plr then
		if users[plr] == nil then
			users[plr] = {
				['Arms'] = nil,
				['Legs'] = nil
			}
		end
		if users[plr][self.clothingType] ~= nil then return end
		users[plr][self.clothingType] = self.model
		self.owner = plr
		if self.speachChange then
			plr:SetAttribute(self.speachChange,true)
		end
		for _,v in pairs(self.hats) do
			v.Handle.Anchored = false
			v.Handle.CanCollide = false
			v.Parent = char
		end
		self.c3[1] = char.Humanoid.Died:Connect(function() --Dying connection
			self:_cleanUp()
		end)
		self.c3[2] = plr.CharacterRemoving:Connect(function() --Leaving Connection
			self:_cleanUp()
		end)
	end
	char,plr = nil
end

function obj:_cleanUp()
	
	for _,v in pairs(self.hats) do
		local v1 = v.Handle.CFrame
		v.Handle.CanCollide = true
		v.Parent = self.model
		v.Handle.CFrame = v1
		v1 = nil
	end
	
	for i = 1,#self.c3,1 do
		if self.c3[i] and self.c3[i].Connected == true then
			self.c3[i]:Disconnect()
		end
		self.c3[i] = nil
	end
	
	users[self.owner][self.clothingType] = nil
	if self.speachChange then
		local remove = true
		for _,v in pairs(users[self.owner]) do
			local v1 = v:GetAttribute('SpeachChange')
			if v1 and v1 == self.speachChange then
				remove = false
				break
			end
		end
		if remove == true then
			self.owner:SetAttribute(self.speachChange,nil)
		end
		remove = nil
	end
	
	self.owner = nil
	
	for _,v in pairs(self.hats) do
		coroutine.wrap(function()
			local model = self.model
			for i = 1,30,1 do
				task.wait(1)
				if v.Parent ~= model then
					model = nil
					return
				end
			end
			if v.Parent == model then
				v.Handle.Anchored = true
			end
			model = nil
		end)()
	end
	
	coroutine.wrap(function()
		local model = self.model
		for i = 1,30,1 do
			task.wait(30)
			for _,v in pairs(self.hats) do
				if v.Parent ~= model then
					model = nil
					return
				end
			end
		end
		self:_return()
		model = nil
	end)()
	
end

function obj:_return()
	self.cleaning = true
	
	for i = 1,#self.c1,1 do
		if self.c1[i] and self.c1[i].Connected == true then
			self.c1[i]:Disconnect()
		end
		self.c1[i] = nil
	end
	for i = 1,#self.c2,1 do
		if self.c2[i] and self.c2[i].Connected == true then
			self.c2[i]:Disconnect()
		end
		self.c2[i] = nil
	end
	for i = 1,#self.c3,1 do
		if self.c3[i] and self.c3[i].Connected == true then
			self.c3[i]:Disconnect()
		end
		self.c3[i] = nil
	end
	
	if self.model then
		self.model:Destroy()
	end
	
	if self.owner and PS[self.owner.Name] then
		
		users[self.owner][self.clothingType] = nil
		if self.speachChange then
			local remove = true
			for _,v in pairs(users[self.owner]) do
				local v1 = v:GetAttribute('SpeachChange')
				if v1 and v1 == self.speachChange then
					remove = false
					break
				end
			end
			if remove == true then
				self.owner:SetAttribute(self.speachChange,nil)
			end
			remove = nil
		end
		
	end
	
	self.owner = nil
	self.model = nil
	for _,v in pairs(self.hats) do
		if v then
			v:Destroy()
		end
		v = nil
	end
	self.model = self.backup:Clone()
	self.model.Parent = WS
	self.cleaning = false
	self:_setup()
end

return obj