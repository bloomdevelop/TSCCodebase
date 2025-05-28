local PS = game:GetService('Players')
local DSS = game:GetService('DataStoreService')
local SSS = game:GetService("ServerScriptService")
local Regions = SSS.AntiAfk.Regions

local CashDataStore = DSS:GetDataStore('SaveCash')

PS.PlayerAdded:Connect(function(plr)
	local leaderstats = Instance.new('Folder')
	leaderstats.Name = 'leaderstats'
	leaderstats.Parent = plr
	
	local cash = Instance.new('IntValue')
	cash.Name = 'Cash'
	cash.Parent = leaderstats
	cash.Value = 0
	
	local data
	local success, errormessage = pcall(function()
		data = CashDataStore:GetAsync(plr.UserId)
	end)
	
	if success then
		cash.Value = data
		local cor = coroutine.wrap(function()
			while plr.Parent do
				wait(40)
				if plr and plr.Parent and leaderstats and cash and Regions:FindFirstChild(plr.Name) and Regions[plr.Name]:FindFirstChild("Time") and Regions[plr.Name].Time.Value < 60 then
					cash.Value += 10
					
				end
			end
		end)
		cor()
	else
		--print('There was an error getting '.. plr.Name .."'s Cash.")
		warn(errormessage)
	end
end)

PS.PlayerRemoving:Connect(function(plr)
	if plr and plr:FindFirstChild('leaderstats') and plr.leaderstats:FindFirstChild('Cash') and plr.leaderstats.Cash.Value ~= 0 then
		local success, errormessage = pcall(function()
			CashDataStore:SetAsync(plr.UserId,plr.leaderstats.Cash.Value)
		end)
		
		if success then else
			--print('There was an error saving '.. plr.Name .."'s Cash.")
			warn(errormessage)
		end
	end
end)