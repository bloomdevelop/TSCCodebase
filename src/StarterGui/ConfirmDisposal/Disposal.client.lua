local rst = game:GetService("ReplicatedStorage")

local remotesFolder = rst.Remotes

local plr = game.Players.LocalPlayer

local ui = script.Parent
local main = ui.Main

local currentTool = nil
local currentBin = nil

remotesFolder.ToolDisposal.ConfirmDisposal.OnClientEvent:Connect(function(bin, tool)
	currentTool = tool
	currentBin = bin
	
	ui.Enabled = true
end)

main.Confirm.Activated:Connect(function()
	remotesFolder.ToolDisposal.ConfirmDisposal:FireServer(currentBin, currentTool)
	ui.Enabled = false
end)

main.Cancel.Activated:Connect(function()
	ui.Enabled = false
end)