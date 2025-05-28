bin = script.Parent

function onTouched(part)
	part.Color = script.Parent.Color
	wait(.3)
end

connection = bin.Touched:connect(onTouched)

--edited by vcids to work properly, idk who made this originally.