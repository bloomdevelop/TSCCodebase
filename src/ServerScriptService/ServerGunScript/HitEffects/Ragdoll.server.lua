local character = script.Parent
character:SetAttribute('Ragdoll', true)
wait(script.Duration.Value)
character:SetAttribute('Ragdoll', false)
script:Destroy()