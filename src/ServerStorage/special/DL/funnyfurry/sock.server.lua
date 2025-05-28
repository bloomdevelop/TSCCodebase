plr = game:GetService("Players"):GetPlayerFromCharacter(script.Parent)
char =plr.Character
left = script.lmain
aleft = script.almain
right = script.rmain
aright = script.armain

left.Parent = char
left.weld.Part1 = char["Left Leg"]

right.Parent = char
right.weld.Part1 = char["Right Leg"]

aleft.Parent = char
aleft.weld.Part1 = char["Left Arm"]

aright.Parent = char
aright.weld.Part1 = char["Right Arm"]

script:Destroy()