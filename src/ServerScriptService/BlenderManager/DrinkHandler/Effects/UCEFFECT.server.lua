local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid")

Humanoid.Health = 1
Character:SetAttribute("SpeedMultiplier", 1.4)
Character:SetAttribute("StaminaBuff", 100)

task.wait(50)
Humanoid.Health = 0

script:Destroy()