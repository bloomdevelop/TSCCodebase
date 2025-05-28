-- // Steven_Scripts, 2022 (And Starfall for recent security patches!)

-- // ApplyCollision Group to all tools.
local PhysicsService = game:GetService("PhysicsService")
local Exception = {"Heavy Shield", "Centurion Shield"}
for i,v in ipairs(game:GetDescendants()) do
	if v:IsA("Tool") and not table.find(Exception, v.Name) then
		for _,Part in pairs(v:GetDescendants()) do
			if Part:IsA("BasePart") then
				PhysicsService:SetPartCollisionGroup(Part, "Tools")
			end
		end
	end
end
Exception = nil

local cs = game:GetService("CollectionService")
local rst = game:GetService("ReplicatedStorage")

local rng = Random.new()

local droppedToolList: {[number]: Tool} = {}

script:WaitForChild("ClearAllDroppedTool").Event:Connect(function()
	for _,t in ipairs(droppedToolList) do
		t:Destroy()
	end
end)

local function totallyDisableCollisions(tool)
	for i,v in pairs(tool:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
end

local function getBoundingBox(instance: Instance, orientation: CFrame?): (CFrame,Vector3) -- Big thanks to Arseny Kapoulkine, XAXA, PysephDEV, and BuilderBob25620 for this code!
	local isPart: boolean = instance:IsA("BasePart")
	local descendants: {Instance} = instance:GetDescendants()
	if isPart then table.insert(descendants, instance) end

	local orientation: CFrame = if orientation then orientation.Rotation elseif isPart and instance:FindFirstChildWhichIsA("BasePart", true) then (instance:: BasePart).CFrame.Rotation else CFrame.identity

	local inf: number = math.huge
	local negInf: number = -inf

	local minx, miny, minz = inf, inf, inf
	local maxx, maxy, maxz = negInf, negInf, negInf

	local function adjust(part: BasePart): ()
		local size: Vector3 = part.Size
		local sx, sy, sz = size.X, size.Y, size.Z

		local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = orientation:ToObjectSpace(part.CFrame):GetComponents()
		local wsx = 0.5 * (math.abs(R00) * sx + math.abs(R01) * sy + math.abs(R02) * sz)
		local wsy = 0.5 * (math.abs(R10) * sx + math.abs(R11) * sy + math.abs(R12) * sz)
		local wsz = 0.5 * (math.abs(R20) * sx + math.abs(R21) * sy + math.abs(R22) * sz)

		minx = if minx > (x - wsx) then x - wsx else minx
		miny = if miny > (y - wsy) then y - wsy else miny
		minz = if minz > (z - wsz) then z - wsz else minz

		maxx = if maxx < (x + wsx) then x + wsx else maxx
		maxy = if maxy < (y + wsy) then y + wsy else maxy
		maxz = if maxz < (z + wsz) then z + wsz else maxz
	end

	for _, descendant: Instance in pairs(descendants) do
		if descendant:IsA("BasePart") then adjust(descendant) end
	end

	local omin, omax = Vector3.new(minx, miny, minz), Vector3.new(maxx, maxy, maxz)
	return orientation + orientation:PointToWorldSpace((omax + omin) * 0.5), (omax - omin)
end

local tossAnim = script.TossAnim:Clone()
tossAnim.Parent = rst

local passAnim = script.PassAnim:Clone()
passAnim.Parent = rst

local toolEntry = {}
toolEntry.__index = toolEntry

function toolEntry.new(tool)
	local self = setmetatable({}, toolEntry)

	local setUpTag = Instance.new("StringValue")
	setUpTag.Name = "SetUp"
	setUpTag.Parent = tool

	local collisionParts = {}
	for i,v in pairs(tool:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
			if v.Transparency < 1 then
				table.insert(collisionParts, v)
			end
		end
	end

	if tool.CanBeDropped == false then
		-- Oh. Well, I guess we're done then.
		return
	end

	self.Tool = tool
	self.Parent = tool.Parent
	self.Character = nil
	self.CanTouch = true
	self.CanCollide = false

	self.CollisionParts = collisionParts

	self:SetCollision(false)
	self:SetTouch(true)

	tool:GetPropertyChangedSignal("Parent"):Connect(function()
		self:OnParentChanged()
	end)

	return self
end

function toolEntry:Destroy()
	if not self.Tool then return end

	-- Oh, we're nuking ourselves. Fun!
	if self.Tool then
		local setUp = self.Tool:FindFirstChild("SetUp")
		if setUp then setUp:Destroy() end
	end
	for i,v in pairs(self) do
		self[i] = nil
	end
end

function toolEntry:SetCollision(CanCollide)
	if self.CanCollide == CanCollide then return end
	for i,part in pairs(self.CollisionParts or {}) do
		part.CanCollide = CanCollide
	end
	self.CanCollide = CanCollide
end

function toolEntry:SetTouch(CanTouch)
	if self.CanTouch == CanTouch then return end
	for i,part in pairs(self.CollisionParts or {}) do
		part.CanTouch = CanTouch
	end
	self.CanTouch = CanTouch
end

function toolEntry:OnToolDropped()
	self:SetTouch(false)

	local tool = self.Tool :: Tool
	local handle = tool:FindFirstChild("Handle",true) -- Switched to 'FindFirstChild' by hayper (Made it so it looks through all descendants in the event it's buried somewhere else! - Starfall)
	local character = self.Character

	local plr = game.Players:GetPlayerFromCharacter(character)

	if not plr.Character:FindFirstChild("Humanoid") then
		tool:Destroy()
		return
	end

	if not handle then
		task.wait(0.5)
		self:SetTouch(true)
		return 
	end
	
	for _,Part: Part in pairs(tool:GetDescendants()) do
		if Part:IsA("BasePart") and Part:CanSetNetworkOwnership() then
			Part:SetNetworkOwner(nil)
		end
	end

	if table.find(cs:GetTags(tool.Parent.Parent.Parent), "BlenderObject") ~= nil then return end

	local originPart = character:FindFirstChild("HumanoidRootPart")
	if not originPart then
		originPart = character:FindFirstChildOfClass("BasePart")
		if not originPart then return end
	end

	self.Character = nil

	local animation = nil

	local passedTool = false
	
	local movementState = plr:GetAttribute("State")
	local crouching = movementState == "Crouching" or movementState == "Crawling"

	if crouching == true then
		animation = passAnim

		-- Check to see if this item can be passed to a nearby player
		local closestDistance = 8
		local closestCharacter = nil
		local closestPlr = nil

		for i,checkPlr in pairs(game.Players:GetPlayers()) do
			if checkPlr ~= plr then
				local checkCharacter = checkPlr.Character
				if checkCharacter then
					local checkRoot = checkCharacter:FindFirstChild("HumanoidRootPart")
					if checkRoot then
						local distance = (checkRoot.Position - handle.Position).Magnitude
						if distance < closestDistance then
							closestDistance = distance
							closestCharacter = checkCharacter
							closestPlr = checkPlr
						end
					end
				end
			end
		end

		if closestCharacter then
			-- Character is within range, but make sure the item isn't being passed through a wall
			local origin = handle.Position
			local direction = (closestCharacter.HumanoidRootPart.Position - origin)

			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = {tool, character}

			local result = workspace:Raycast(origin, direction, raycastParams)

			if result ~= nil and result.Instance.Parent == closestCharacter or result.Instance.Parent.Parent == closestCharacter then
				-- Good, it doesn't go through a wall. Pass the tool into their inventory as soon as possible.
				passedTool = true

				-- Wait until it's officailly dropped so we don't cause the "something tried to set parent unexpectedly" warning.
				repeat task.wait() until tool.Parent == workspace
				tool.Parent = closestPlr.Backpack
			end
		end
	else
		animation = tossAnim
	end

	if passedTool == false then
		-- Drop tool
		local dropPos = originPart.CFrame*CFrame.new(1, 0, -3).Position

		-- Make sure this tool doesn't go through a wall
		local origin = originPart.Position
		local direction = (dropPos - origin)

		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {tool, character}

		local result = workspace:Raycast(origin, direction, raycastParams)
		if result then
			-- Move it back
			dropPos = result.Position
		end

		-- Apply orientation
		local dropCF = CFrame.new(dropPos.X, dropPos.Y, dropPos.Z,
			tool.GripRight.X, tool.GripUp.X, -tool.GripForward.X,
			tool.GripRight.Y, tool.GripUp.Y, -tool.GripForward.Y,
			tool.GripRight.Z, tool.GripUp.Z, -tool.GripForward.Z
		)

		-- Set CFrame
		handle.CFrame = dropCF

		local adjustedMass
		if handle.Mass < 0.4 then
			-- No way we're touching the mass here unless we want this tool to fly out of the map.
			adjustedMass = handle.Mass
		else
			adjustedMass = ((4+handle.Mass)/2)
			adjustedMass = math.max(adjustedMass, handle.Mass)
		end

		local canDamage = false
		if crouching == false then
			-- Toss it forwards
			handle:ApplyImpulse((originPart.CFrame.LookVector*20 + originPart.CFrame.UpVector*10) * adjustedMass)

			-- Add trail
			local att0 = Instance.new("Attachment")
			local att1 = Instance.new("Attachment")

			att0.Position = Vector3.new(0, 0.1, 0)
			att1.Position = Vector3.new(0, -0.1, 0)

			local trail = script.Trail:Clone()

			att0.Parent = handle
			att1.Parent = handle

			trail.Parent = handle
			trail.Attachment0 = att0
			trail.Attachment1 = att1

			if tool:GetAttribute("SharpObject") == true then
				canDamage = true
				trail.Color = ColorSequence.new(Color3.new(1, 0, 0))
			end

			game.Debris:AddItem(trail, 0.6)
			game.Debris:AddItem(att0, 0.7)
			game.Debris:AddItem(att1, 0.7)
		end

		if canDamage == false then
			coroutine.wrap(function()
				-- This is to prevent the tool being immediately picked up again
				-- by the player that dropped it.
				task.wait(0.5)
				self:SetTouch(true)
			end)()
		else
			local hitbox = script.SharpObjectHitbox:Clone()

			local boundingBoxCF, hitboxSize = getBoundingBox(handle)

			hitbox.CFrame = boundingBoxCF
			hitbox.Size = hitboxSize

			hitbox.Color = Color3.new(1, 0, 0)
			hitbox.Transparency = 1

			hitbox.Name = "ToolHitbox"
			hitbox.CanCollide = false
			hitbox.Archivable = false
			hitbox.Massless = true

			hitbox.Parent = workspace

			local weld = Instance.new("Weld")
			weld.Part0 = handle
			weld.Part1 = hitbox
			weld.C0 = handle.CFrame:Inverse()
			weld.C1 = hitbox.CFrame:Inverse()

			weld.Parent = hitbox

			coroutine.wrap(function()
				local velocity = handle.AssemblyLinearVelocity
				repeat task.wait() velocity = handle.AssemblyLinearVelocity until velocity.Magnitude > 0 -- wait for physics engine to kick in

				-- wait a liiittle more just to be sure
				task.wait(.1)

				local stabCooldown = false
				local touchedEvent = hitbox.Touched:Connect(function(hitPart)
					if stabCooldown == true then return end

					local char = hitPart.Parent
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum then
						local damage = math.min(velocity.Magnitude/12, 90)
						if hitPart.Name == "Head" then
							damage = damage*1.5
						end

						hum:TakeDamage(damage)

						local hitSound = hitbox.HitSound:Clone()
						hitSound.PlaybackSpeed = rng:NextNumber(1.1, 1.3)
						hitSound.Parent = hitPart
						hitSound:Play()

						local impactParticles = hitbox.Impact:Clone()
						impactParticles.Parent = hitPart
						impactParticles:Emit(50)

						game.Debris:AddItem(impactParticles, 2)
						game.Debris:AddItem(hitSound)

						hitbox.Attachment.Trail.Enabled = true

						stabCooldown = true

						task.wait(.2)

						if hitbox.Parent ~= nil then
							hitbox.Attachment.Trail.Enabled = false

							task.wait(.2)

							stabCooldown = false
						end
					end
				end)

				while velocity.Magnitude > 1 and tool.Parent ~= nil do
					task.wait(.1)
					velocity = handle.AssemblyLinearVelocity
				end

				touchedEvent:Disconnect()
				hitbox:Destroy()
			end)()
		end
	end

	-- Animation
	local track = character:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(animation)
	track:Play()
	game.Debris:AddItem(track, 4)
end

function toolEntry:OnParentChanged()
	local tool = self.Tool
	local oldParent = self.Parent
	local newParent = tool and tool.Parent or nil

	if newParent == nil then
		if table.find(droppedToolList, tool) then table.remove(droppedToolList, table.find(droppedToolList, tool)) end

		-- Yep, it's probably gone.
		self:Destroy()
	elseif newParent:IsA("Model") and newParent:FindFirstChildOfClass("Humanoid") then
		if table.find(droppedToolList, tool) then table.remove(droppedToolList, table.find(droppedToolList, tool)) end

		-- Tool is being held by someone.
		self:SetCollision(false)
		if self.Character == nil then
			self.Character = newParent
		end
	elseif newParent == workspace or newParent:IsDescendantOf(workspace) then
		if #droppedToolList >= 10 then
			droppedToolList[1]:Destroy()
		end
		-- Tool was dropped somewhere in the workspace.
		self:SetCollision(true)
		if self.Character ~= nil then
			-- It was dropped by someone.
			self:OnToolDropped()
		end
		table.insert(droppedToolList, tool)
	else
		if table.find(droppedToolList, tool) then table.remove(droppedToolList, table.find(droppedToolList, tool)) end

		-- Tool's being stored somewhere else.
		self:SetCollision(false)
		if newParent:IsA("Backpack") then
			-- It was either unequipped by a player or given to that player just now.
			if self.Character == nil then
				self.Character = newParent.Parent.Character
			end
		end
	end
end

local function handlePotentialTool(tool)
	if tool:IsA("Tool") and tool:FindFirstChild("SetUp") == nil and tool:FindFirstChild("Handle") ~= nil then
		toolEntry.new(tool)
	end
end

local function ItemHoldCheck(Char: Model, Tool: Tool)
	if Tool:IsA("Tool") then
		local ToolinChar = 0
		for _,CharTool: Instance in pairs(Char:GetChildren()) do
			if CharTool:IsA("Tool") then
				ToolinChar += 1
			end
		end
		if ToolinChar > 1 then
			local Hum: Humanoid = Char:FindFirstChildWhichIsA("Humanoid")
			if (Hum) then
				Hum:UnequipTools()
			end
		end
		ToolinChar = nil
	end
end

game:GetService("Players").PlayerAdded:Connect(function(plr)
	plr.ChildAdded:Connect(function(backpack)
		if backpack:IsA("Backpack") then
			backpack.ChildAdded:Connect(handlePotentialTool)
		end
	end)
	plr.CharacterAdded:Connect(function(char)
		char.ChildAdded:Connect(function(T: Tool)
			handlePotentialTool(T)
			ItemHoldCheck(char, T)
		end)
	end)
end)