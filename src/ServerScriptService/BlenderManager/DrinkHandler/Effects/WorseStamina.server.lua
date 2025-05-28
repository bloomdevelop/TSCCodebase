local Character = script.Parent

Character:SetAttribute("StaminaBuff", 0.5)
task.wait(30)
Character:SetAttribute("StaminaBuff", nil)

script:Destroy()