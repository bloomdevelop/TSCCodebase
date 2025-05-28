-- Services
local Players = game:GetService("Players")

-- Directory Stuff
local StoredDir = script.Stored
local EffectsDir = script.Effects
local DrinkInfo = script.DrinkInfo

local function CreateSound(Name,Part)
	local Sound = StoredDir:FindFirstChild(Name) and StoredDir[Name]:Clone()
	if not Sound or not Sound:IsA("Sound") then if Sound then Sound:Destroy() end return end
	if not Part or not Part:IsA("BasePart") then return end
	coroutine.resume(coroutine.create(function()
		Sound.Parent = Part
		Sound:Play()
		Sound.Ended:Wait()
		Sound:Destroy()
	end))
end

-- Drink Handler
local Drink = {}
Drink.__index = Drink

function Drink:GetDrinkInfo(Name)
	if not Name then return end
	local Module = DrinkInfo:FindFirstChild(Name) and require(DrinkInfo[Name])
	if not Module then warn("DRINK NOT FOUND") Module = require(DrinkInfo["Junk"]) end
	return(Module)
end

function Drink.new(Chr,Name)
	assert(Chr:IsA("Model") and Chr:FindFirstChild("Humanoid"),"Must be a character.")
	assert(type(Name) == "string","Must have a name.")
	local self = {}
	setmetatable(self,Drink)

	--// Setup //--

	local LDrinkInfo = Drink:GetDrinkInfo(Name)

	self.UseSound = LDrinkInfo.UseSound or "DrinkGeneric"

	self.DrinkInfo = LDrinkInfo
	self.DrinkTool = StoredDir.Cup:Clone()
	self.DB, self.Empty = false, false

	local Player = Players:GetPlayerFromCharacter(Chr)
	self.DrinkTool.Parent = Player and Player.Backpack or Chr 

	--// Initialize Drink //--
	self.DrinkTool.Name = LDrinkInfo["Name"] or "Generic Drink"
	self.DrinkTool.ToolTip = LDrinkInfo["ToolTip"] or ""
	self.DrinkTool.Fluid.Transparency = LDrinkInfo["DrinkTransparency"] or 0
	self.DrinkTool.Fluid.Color = LDrinkInfo["DrinkColor"] or Color3.fromRGB(255,255,255)
	self.DrinkTool.Fluid.Material = LDrinkInfo["DrinkMaterial"] or Enum.Material.Plastic

	self.DrinkTool.Activated:Connect(function() self:Activated() end)

	--print("Stuff made")

	return self
end

function Drink:DrinkContents(Target)
	self.DrinkTool.Name = "Cup"
	self.DrinkTool.ToolTip = "An empty cup."
	self.DrinkTool.Fluid.Transparency = 1
	if not self.DrinkInfo.Effects then return end
	for _,EffectName in pairs(self.DrinkInfo.Effects) do
		local NewScript = EffectsDir[EffectName]:Clone()
		NewScript.Parent = Target
		NewScript.Disabled = false
	end
end

function Drink:Activated() -- DRINK HANDLER
	if self.DB or self.Empty then return end
	CreateSound(self.UseSound,self.DrinkTool.Handle)
	self.DB = true

	self.DrinkTool.Parent.Humanoid.Animator:LoadAnimation(self.DrinkTool.Drink):Play()

	task.wait(1)

	if self.DrinkTool.Parent:IsA("Model") and self.DrinkTool.Parent:FindFirstChild("Humanoid") then
		self:DrinkContents(self.DrinkTool.Parent)
		self.Empty = true
	end

	self.DB = false
end


return Drink