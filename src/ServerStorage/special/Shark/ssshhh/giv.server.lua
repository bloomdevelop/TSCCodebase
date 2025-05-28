plr = game:GetService("Players"):GetPlayerFromCharacter(script.Parent)
char =plr.Character
s1 = script.Stripe1
s2 = script.Stripe2
s3 = script.Stripe3
s4 = script.Stripe4

s1.Parent = char
s1.w.Part1 = char["Left Leg"]
s1.w.Part0 = s1
s2.Parent = char
s2.w.Part1 = char["Right Leg"]
s2.w.Part0 = s2
s2.w.C1 = CFrame.Angles(0,math.rad(-0),0)
s3.Parent = char
s3.w.Part1 = char["Left Arm"]
s3.w.Part0 = s3
s4.Parent = char
s4.w.Part1 = char["Right Arm"]
s4.w.Part0 = s4



script:Destroy()