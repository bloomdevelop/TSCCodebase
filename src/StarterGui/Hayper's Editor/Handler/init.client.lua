local Highlighter = require(script:WaitForChild("Highlighter"))

local TextBox = script.Parent.ScrollingFrame.TextBox

Highlighter.UpdateColors({
	background = Color3.fromHex("222222"),
	iden = Color3.fromHex("948ae3"),
	keyword = Color3.fromHex("5ad4e6"),
	builtin = Color3.fromHex("5ad4e6"),
	string = Color3.fromHex("fce566"),
	number = Color3.fromHex("948ae3"),
	comment = Color3.fromHex("69676c"),
	operator = Color3.fromHex("fc618d")
})

local function update()
	Highlighter.Highlight(TextBox)
end

TextBox:GetPropertyChangedSignal("Text"):Connect(update)
update()