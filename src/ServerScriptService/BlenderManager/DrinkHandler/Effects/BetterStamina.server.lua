local Character = script.Parent

Character:SetAttribute("StaminaBuff", 2)
task.wait(30)
Character:SetAttribute("StaminaBuff", nil)

script:Destroy()