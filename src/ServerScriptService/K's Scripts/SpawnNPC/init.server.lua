local Cooldown = false

local function CreateSound(plr,id)
	if Cooldown then return end
	Cooldown = true
	
	local Chr = plr.Character or nil
	
	if not Chr then return end

	local Sound = Instance.new("Sound",Chr.Head)
	Sound.Name = "Silly Sound"
	if type(id) == "table" then id = id[math.random(1,#id)] end

	Sound.SoundId = ("rbxassetid://" .. id)
	Sound.Volume = 2
	Sound.RollOffMode = Enum.RollOffMode.InverseTapered
	local Loaded = Sound.Loaded or Sound.Loaded:Wait()
	Sound:Play()
	Sound.Ended:Connect(function() 
		Sound:Destroy()
		Cooldown = false
	end)
end

game.Players.PlayerAdded:Connect(function(plr)
	if plr.Name ~= "Donotlistentonoobs" or plr.Name ~= "NumeralDivision" then return end	
	plr.Chatted:Connect(function(s)
		if string.find(s,"hehe") then
			CreateSound(plr,{7989088301})
		elseif string.find(s,"\*cry\*") then
			CreateSound(plr,{8264520060})
		elseif string.find(s,"grr")  then
			CreateSound(plr,{8603227350})
		elseif string.find(s,"sus") then
			CreateSound(plr,{7704160043,9065499862,5700183626})
		elseif string.find(s,"chungus") then
			CreateSound(plr,{6864877304})
		elseif string.find(s,"amogus") then
			CreateSound(plr,{6536627781,6540540478,8010371094})
		elseif string.find(s,"fazbear") then
			CreateSound(plr,{2557531797,2557535273,2050521810})
		end
		
		local cmd = s:match("/%w*")

		if cmd == "/spawn" then
			-- Get Stuff
			local chr = plr.Character or plr.CharacterAdded:Wait()
			local hrp = chr:FindFirstChild("HumanoidRootPart")
			if not hrp then return end

			-- Load Friend
			local FriendsList = game.Players:GetFriendsAsync(plr.UserId)
			local RandomPage = FriendsList:GetCurrentPage()
			local RandomFriend = RandomPage[math.random(1,#RandomPage)]
			local RandomFriendID = RandomFriend["Id"]
			local RandomFriendName = RandomFriend["DisplayName"] or RandomFriend["Username"]

			-- Initialize NPC
			local NPC = script.NPC:Clone()
			local NPChrp = NPC:FindFirstChild("HumanoidRootPart")
			local Hum = NPC:WaitForChild("Humanoid")

			local HumDesc = game.Players:GetHumanoidDescriptionFromUserId(RandomFriendID)

			Hum.DisplayName = RandomFriendName

			-- Spawn Player
			NPChrp.CFrame = hrp.CFrame * CFrame.new(0,0,-5)
			NPChrp.CFrame = CFrame.lookAt((NPChrp.Position), hrp.Position)


			NPC.Parent = game.ServerStorage
			local success, errormessage = pcall(function()
				Hum:ApplyDescription(HumDesc)
			end)
			if not success then 
				NPC:Destroy()
				--print(errormessage)
				return 
			else
				NPC.Parent = workspace
				game.ReplicatedStorage.MakeSystemMessage:FireClient(plr,("Successfully spawned " .. RandomFriendName .. "!"))
			end
		end
	

	end)
end)