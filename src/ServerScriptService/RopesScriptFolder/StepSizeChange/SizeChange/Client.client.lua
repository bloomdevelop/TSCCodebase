local gui = script.Parent
local TB = gui:WaitForChild('TextBox')
local remote = gui:WaitForChild('RemoteEvent')

local db = false

TB.FocusLost:Connect(function()
	if not db then
		db = true
		
		if not tonumber(TB.Text) then return end
		local num = math.clamp(tonumber(TB.Text),1,2)
		TB.Text = num
		remote:FireServer(num)
		
		task.wait(0.5)
		
		db = false
	end
end)