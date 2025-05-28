plr = game:GetService("Players"):GetPlayerFromCharacter(script.Parent)
char =plr.Character
left = script.lmain
right = script.rmain

left.Parent = char
left.weld.Part1 = char["Left Leg"]

right.Parent = char
right.weld.Part1 = char["Right Leg"]

script:Destroy()