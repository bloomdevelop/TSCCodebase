local plr = game.Players.LocalPlayer

local tool = script.Parent

local storage = tool.Stored

local ui = script:WaitForChild("ContrabandBagGUI")
local main = ui:WaitForChild("Main")
local scrollingFrame = main:WaitForChild("ScrollingFrame")

local scanned = false

tool.Equipped:Connect(function()
	if scanned == false then
		scanned = true
		
		-- Clear frame
		for i,v in pairs(scrollingFrame:GetChildren()) do
			if v:IsA("Frame") then
				v:Destroy()
			end
		end
		
		-- Fill frame
		if storage:FindFirstChildOfClass("ObjectValue") == nil then
			repeat wait() until storage:FindFirstChildOfClass("ObjectValue") ~= nil
		end
		
		for i,pointer in pairs(storage:GetChildren()) do
			local itemFrame = scrollingFrame:FindFirstChild(pointer.Name)
			
			if not itemFrame then
				itemFrame = script.ItemFrame:Clone()
				itemFrame.ItemName.Text = pointer.Name
				itemFrame.Count.Text = "1"
				
				itemFrame.Name = pointer.Name
				itemFrame.Parent = scrollingFrame
			else
				itemFrame.Count.Text = tostring(tonumber(itemFrame.Count.Text)+1)
			end
		end
		
		main:WaitForChild("Take").Activated:Connect(function()
			ui:Destroy()
			tool.Take:FireServer()
		end)
		
		main:WaitForChild("Delete").Activated:Connect(function()
			ui:Destroy()
			tool.Delete:FireServer()
		end)
	end
end)

tool.Unequipped:Connect(function()
	ui.Parent = script
end)

tool.Activated:Connect(function()
	if ui.Parent == script then
		ui.Parent = plr.PlayerGui
	else
		ui.Parent = script
	end
	script.Open:Play()
end)