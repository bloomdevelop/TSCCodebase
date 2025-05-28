local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local DataRemote = Tool:WaitForChild("Data")
local GUI = Tool:WaitForChild("BoomboxGUI")

local Main = GUI:WaitForChild("Main")
local Sound = Handle:WaitForChild("Sound")

-- Cached Method
local min, max = math.min, math.max

-- Variables
local Ended = false
local IsMounting = false
local IsLooping = false
local IsPlaying = false
local BackWeld = nil

local Owner = nil
local LastOwner = nil

local function weldBetween(a: BasePart, b: BasePart)
	local weld = Instance.new("Weld")
	weld.Name = "RadioWeld"
	weld.Part0 = a
	weld.Part1 = b
	weld.C0 = CFrame.new()
	weld.C1 = b.CFrame:Inverse() * a.CFrame
	weld.Parent = a
	return weld
end

local function HasBoombox(char: Model)
	local A = char:FindFirstChild("Boombox")
	A = A and A:IsA("Tool") and A or nil

	local B = char:FindFirstChild("Handle")
	B = B and B:FindFirstChild(Tool.Name) and B[Tool.Name]:IsA("Tool") and B[Tool.Name] or nil
	return A or B
end

local function OwnBoombox(char: Model)
	return Tool.Parent == char or (Tool.Parent ~= nil and Tool.Parent.Parent == char) 
end

local function handleMount(player: Player)
	local char = player.Character 

	if HasBoombox(char) ~= Tool then
		Tool:Destroy()
		GUI:Destroy()
		return
	end

	if not OwnBoombox(char) then return end

	if not IsMounting then
		Handle.Parent = char
		Handle.CFrame = (char:WaitForChild("Torso").CFrame * CFrame.new(Vector3.new(0, 0, 1)) * CFrame.Angles(0, 0, math.rad(45)))
		BackWeld = weldBetween(char:WaitForChild("Torso"), Handle)
		GUI.Parent = player:WaitForChild("PlayerGui")
		Tool.Parent = Handle
		IsMounting = true
	else
		assert(BackWeld, "Weld Does Not Exist")
		BackWeld:Destroy()
		Tool.Parent = char
		Handle.Parent = Tool
		IsMounting = false
	end
end

local function UpdateParticles()
	Handle.ParticleEmitter.Enabled = not Ended and Sound.IsLoaded and Sound.IsPlaying and Sound.TimeLength > 0
end

DataRemote.OnServerInvoke = function(player: Player, data)
	if typeof(data) ~= "table" or not data.Action then return end

	if data.Action == "Volume" then
		Sound.Volume = max(min(1.5, tonumber(data.Value) or 0.1), 0.1)
	elseif data.Action == "AudioId" then
		local id = data.Value:sub(1,13) == "rbxassetid://" and data.Value or "rbxassetid://" .. (tonumber(data.Value) or 0)
		local oldId = Sound.SoundId
		pcall(function()
			Sound.SoundId = id
			if not Sound.IsLoaded then Sound.Loaded:Wait() end
			Sound.Playing = IsPlaying

			if oldId ~= Sound.SoundId then
				Sound.TimePosition = 0
			end

			UpdateParticles()
		end)
	elseif data.Action == "Toggle" then
		IsPlaying = not IsPlaying
		Sound.Playing = IsPlaying
		if not IsPlaying then
			Sound.TimePosition = 0
		else
			Ended = false
		end
		UpdateParticles()
		return {IsPlaying = IsPlaying}
	elseif data.Action == "Loop" then
		IsLooping = not IsLooping
		Sound.Looped = IsLooping
		return {IsLooping = IsLooping}
	elseif data.Action == "Mount" then
		handleMount(player)
		return {IsMounting = IsMounting}
	end
end

Tool.Equipped:Connect(function()
	local player = Players:GetPlayerFromCharacter(Tool.Parent) 
	if player then
		GUI.Parent = player:WaitForChild("PlayerGui")
		if Owner ~= player then
			DataRemote:InvokeClient(player, {
				IsMounting = IsMounting,
				IsLooping = IsLooping,
				IsPlaying = IsPlaying,
				SoundId = Sound.SoundId,
				Volume = Sound.Volume,
				LastOwner = LastOwner and player ~= LastOwner and LastOwner.Name or nil
			})
			Owner = player
		end
	end
	Sound.Playing = IsPlaying
	UpdateParticles()
end)

Tool.AncestryChanged:Connect(function(_, parent)
	if parent ~= nil and not parent:IsA("Backpack") and (Players:GetPlayerFromCharacter(parent) or (parent.Parent ~= nil and Players:GetPlayerFromCharacter(parent.Parent))) then return end

	GUI.Parent = Tool
	IsMounting = false
	if BackWeld then
		BackWeld:Destroy()
		BackWeld = nil
	end

	LastOwner = Owner

	if not Tool:IsDescendantOf(workspace) then
		Sound.Playing = false
	else
		Sound.Playing = IsPlaying
	end
	
	UpdateParticles()
end)

Sound.Ended:Connect(function()
	Ended = not Sound.Looped
	IsPlaying = Sound.Looped
	
	DataRemote:InvokeClient(Owner, {
		IsPlaying = IsPlaying
	})
	
	UpdateParticles()
end)