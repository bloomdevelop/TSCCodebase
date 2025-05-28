local PS = game:GetService("Players")
local SG = game:GetService("StarterGui")
local plr = PS.LocalPlayer

if script.Name == "1" then
	SG:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)
else
	SG:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,true)
end