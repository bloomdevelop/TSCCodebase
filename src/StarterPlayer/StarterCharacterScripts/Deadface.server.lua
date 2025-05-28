local Head = script.Parent:WaitForChild("Head")
local face = Head:WaitForChild("face") or Head:WaitForChild("Face") or Head:WaitForChild("Decal")
local MyHuman = script.Parent.Humanoid
local DeathFace = {"5065838007","2540090139","476060645","145854465","530893454","1002429805","1078549100","434152481"} --change asset ID textures you want!

(MyHuman :: Humanoid).Died:Connect(function()
	face.Texture = "http://www.roblox.com/asset/?id="..DeathFace[math.random(1,#DeathFace)] --change number on how many DeathFace on the table. Ex: If there two change [math.random(1,8)] to [math.random(1,2)], if there nine change [math.random(1,8)] to [math.random(1,9)]
	script.Disabled = true	
end)