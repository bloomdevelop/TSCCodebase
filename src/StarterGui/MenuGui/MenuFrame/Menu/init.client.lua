script.Parent.Parent.Enabled = true

local stg = game:GetService("StarterGui")
local ss = game:GetService("SoundService")

local plr = game.Players.LocalPlayer

local plrGui

local menuFrame = script.Parent

local refreshGui = menuFrame.RefreshGui

local function charAdded(char)
	local humanoid = char:WaitForChild("Humanoid")
	if refreshGui.Value == true then
		stg:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		stg:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
		plrGui:WaitForChild("InterfaceUI").Enabled = false
		-- ss.AmbientReverb = ("NoReverb")
		menuFrame.Visible = true
	end

	humanoid.Died:Connect(function()
		refreshGui.Value = true
	end)
end

for i,module in pairs(script:GetChildren()) do
	require(module)
end

plrGui = plr:WaitForChild("PlayerGui")

if plr.Character ~= nil then
	charAdded(plr.Character)
end
plr.CharacterAdded:Connect(charAdded)