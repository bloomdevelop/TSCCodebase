local Character = script.Parent

Character:SetAttribute("SpeedMultiplier", 1.3)
task.wait(30)
Character:SetAttribute("SpeedMultiplier", nil)

script:Destroy()