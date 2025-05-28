-- Services
local TweenService = game:GetService("TweenService")

-- Drink Handler
local StoredDir = script.Stored
local DrinkHandler = require(script.Parent.DrinkHandler)
local Recipes = require(script.Recipes)
local ItemTypes = require(script.ItemTypes)
local RecipePriorities = require(script.RecipePriorities)

local MaxIngredients = 3
local ActivationDistance = 10

local BlacklistedTools = {
	["Fists"] = true,
	["Hug"] = true,
	["Infect"] = true
}

local function CreateSound(Name,Part,CutoffTime)
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

local function GetRecipe(itemlist)
	local ValidRecipes = {}

	for RecipeName,Recipe in pairs(Recipes) do
		local ItemsMissing = {}
		for i,v in pairs(Recipe) do
			ItemsMissing[i] = v
		end

		for ItemIndex, Item in pairs(itemlist) do
			if table.find(ItemTypes.Explosive, Item) ~= nil then
				-- >:)
				return "Explosive"
			end

			for MissingItemIndex, MissingItem in pairs(ItemsMissing) do
				local UseType = string.sub(MissingItem, 1, 5) == "TYPE:"
				if UseType then
					local Type = string.sub(MissingItem, 6)
					local ValidItems = ItemTypes[Type]
					if table.find(ValidItems, Item) ~= nil then
						-- Valid item due to matching item type
						table.remove(ItemsMissing, MissingItemIndex)
						break
					end
				else
					if MissingItem == Item then
						-- Valid item due to matching item name
						table.remove(ItemsMissing, MissingItemIndex)
						break
					end
				end
			end
		end

		if #ItemsMissing == 0 then
			table.insert(ValidRecipes, RecipeName)
		end
	end

	local ValidRecipeCount = #ValidRecipes
	if ValidRecipeCount == 1 then
		return ValidRecipes[1]
	elseif ValidRecipeCount > 1 then
		-- Prioritize the valid recipe with the highest priority
		local ChosenRecipe = nil
		local HighestPriority = 0
		for RecipeIndex,RecipeName in pairs(ValidRecipes) do
			local Priority = RecipePriorities[RecipeName] or 1
			if Priority > HighestPriority then
				ChosenRecipe = RecipeName
				HighestPriority = Priority
			end
		end

		return ChosenRecipe
	else
		return("Junk")
	end
end

-- Blender Handler
local Blender = {}
Blender.__index = Blender

function Blender.new(model)
	assert(model:IsA("Model"),"Must be a model.")
	local self = {}
	setmetatable(self,Blender)

	self.Model = model

	if not model.PrimaryPart then model.PrimaryPart = model:FindFirstChild("Basepart",true) end
	assert(model.PrimaryPart,"THERE MUST BE A PART IN THE MODEL!")

	self.PrimaryPart = model.PrimaryPart
	self.Full, self.DB = false, false
	self.StoredItems = {}
	self.Fluid = model:FindFirstChild("Fluid",true)

	-- // Initialize Proximity Prompt // --
	self.ProximityPrompt = model:FindFirstChildWhichIsA("ProximityPrompt",true) or Instance.new("ProximityPrompt",self.PrimaryPart)
	self.ProximityPrompt.ObjectText = "Blender"
	self.ProximityPrompt.RequiresLineOfSight = false
	self.ProximityPrompt.MaxActivationDistance = ActivationDistance
	self.ProximityPrompt.HoldDuration = .5 -- Added by hayper, used to avoid accidently adding item
	self.ProximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	self.ProximityPrompt.Triggered:Connect(function(plr)
		if self.DB then return end
		if self.Full then
			-- Give drink
			self:GetItem(plr.Character,GetRecipe(self.StoredItems))
		elseif #self.StoredItems == MaxIngredients then
			-- Blend drink
			self:Blend()
		else
			-- Add ingredient
			self:AddItem(plr.Character)
		end

		self:UpdatePrompt()
	end)

	self:UpdatePrompt()

	return self
end

function Blender:UpdatePrompt()
	local StoredItemsAmount = #self.StoredItems

	if self.Full then
		self.ProximityPrompt.ActionText = "Take"
	elseif StoredItemsAmount == MaxIngredients then
		self.ProximityPrompt.ActionText = "Blend"
	else
		local Ordinal = ""
		if StoredItemsAmount == 0 then
			Ordinal = "first"
		elseif StoredItemsAmount == 1 then
			Ordinal = "second"
		else
			Ordinal = "third"
		end

		self.ProximityPrompt.ActionText = "Add "..Ordinal.." ingredient"
	end
end

function Blender:UpdateFluid(DrinkName)
	if not self.Fluid then return end
	coroutine.resume(coroutine.create(function()
		local Drink = DrinkHandler:GetDrinkInfo(DrinkName)
		self.Fluid.Material = Drink.DrinkMaterial
		TweenService:Create(self.Fluid,TweenInfo.new(0.01,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out),{
			Color = Drink.DrinkColor or Color3.fromRGB(255,255,255),
			Transparency = Drink.DrinkTransparency or 0
		}):Play()
	end))
end

function Blender:GetItem(Chr,DrinkName)
	if #self.StoredItems <= 0 or not self.Full then return end
	self.StoredItems = {}; self.Full = false
	self.Fluid.Transparency = 1
	--print(DrinkName)
	DrinkHandler.new(Chr,DrinkName)
end

function Blender:AddItem(Chr)
	if self.DB or self.Full then return end
	local Tool = Chr:FindFirstChildWhichIsA("Tool")
	if not Tool then return end
	local Hum = Chr:FindFirstChildOfClass("Humanoid")
	if not Hum then return end
	if Tool:FindFirstChild("Handle") ~= nil and BlacklistedTools[Tool.Name] == nil then
		table.insert(self.StoredItems,Tool)
		Hum:UnequipTools()
		Tool.Parent = self.Fluid
		for _,v in pairs(Tool:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then 
				v.Anchored = true 
				v.CanCollide = false 
				v.CanTouch = false 
				v.CanQuery = false 
				v.Position = self.Fluid.Position
			elseif v:IsA("Mesh") or v:IsA("SpecialMesh") then continue
			else v:Destroy()
			end
		end
		--print(self.StoredItems)
	end
end

function Blender:Blend()
	if self.Full or self.DB or #self.StoredItems <= 0 then return end
	self.DB = true
	self.ProximityPrompt.MaxActivationDistance = 0
	CreateSound("Activated",self.Fluid)
	local tempTable = {}
	for i,v in pairs(self.StoredItems) do
		table.insert(tempTable,v.Name)
		v:Destroy()
	end
	self.StoredItems = tempTable
	local RecipeName = GetRecipe(self.StoredItems)
	if RecipeName == "Explosive" then
		local Effect = StoredDir.ExplodeScript:Clone()
		Effect.Parent = self.PrimaryPart
		Effect.Disabled = false
		self.StoredItems = {}
	else
		self:UpdateFluid(RecipeName)
		task.wait(4.6)
		self.Full = true
	end
	self.DB = false
	self.ProximityPrompt.MaxActivationDistance = 10
end

function Blender:Destroy()
	self = nil
end


return Blender
