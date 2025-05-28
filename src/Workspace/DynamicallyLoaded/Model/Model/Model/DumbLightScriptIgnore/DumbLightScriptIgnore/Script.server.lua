
local waitTable = {10,0.1,0.1,0.1,5,0.1,0.1,0.1,0.1,2,0.3,0.01,0.01,0.01,0.3,20}
while true do 
	for _,v in pairs(waitTable)do
		wait(v)
		script.Parent.Brightness = script.Parent.Brightness == 0.2 and 0.7 or 0.2
	end
end