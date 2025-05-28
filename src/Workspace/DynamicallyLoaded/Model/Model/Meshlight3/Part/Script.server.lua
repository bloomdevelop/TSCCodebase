local waitTable = {10,0.1,0.1,0.1,5,0.1,0.1,0.1,0.1,2,0.3,0.01,0.01,0.01,0.3,20}
local materials = {"Neon","Plastic","SmoothPlastic"}
while true do 
	for _,v in pairs(waitTable)do
		wait(v)
		local r = math.random(1,3)
		script.Parent.Material = Enum.Material[materials[r]]
	end
end