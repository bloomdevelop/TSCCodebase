b = script.Parent
x = 0

while true do

    b.Color = Color3.fromHSV(x,1,1)
    x = x + 1/255
    if x >= 1 then
        x = 0
    end
    wait()
end
