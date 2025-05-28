local characterMap: {[string]: string} = {
	a = "Ꮧ",
	b = "Ᏸ",
	c = "ፈ",
	d = "Ꮄ",
	e = "Ꮛ",
	f = "Ꭶ",
	g = "Ꮆ",
	h = "Ꮒ",
	i = "Ꭵ",
	j = "Ꮰ",
	k = "Ꮶ",
	l = "Ꮭ",
	m = "Ꮇ",
	n = "Ꮑ",
	o = "Ꭷ",
	p = "Ꭾ",
	q = "Ꭴ",
	r = "Ꮢ",
	s = "Ꮥ",
	t = "Ꮦ",
	u = "Ꮼ",
	v = "Ꮙ",
	w = "Ꮗ",
	x = "ጀ",
	y = "Ꭹ",
	z = "ፚ"
}

function parseCharacter(char:string): string
	--return (characterMap[string.lower(char)] or char)
	return char
end

function randomCase(char: string): string
	return Random.new():NextInteger(1, 4) == 1 and string.upper(char) or string.lower(char)
end

function scrambleText(text: string): string
	local newText = ""

	local wordCount = 0

	for i = 1, #text do
		local currentCharacter = string.sub(text, i, i)
		local nextCharacter = string.sub(text, i + 1, i + 1)

		local newLetter = randomCase(parseCharacter(currentCharacter))

		local removeCharacter = #text < 4 and Random.new():NextInteger(1, 2) == 1
		--local repeatCharacter = Random.new():NextInteger(1, 4) == 1
		local swapCharacter = Random.new():NextInteger(1, 4) == 1
		local reverseOrder = Random.new():NextInteger(1, 6) == 1

		if removeCharacter then
			newLetter = ""
		else
			--if repeatCharacter then
			--	newLetter = newLetter .. newLetter
			--end

			if swapCharacter then
				i += 1
				newLetter = randomCase(parseCharacter(nextCharacter)) .. newLetter
			end
		end

		newText =
			not removeCharacter and (reverseOrder and (newLetter .. newText) or (newText .. newLetter)) or
			newText .. newLetter
	end

	return newText
end

return scrambleText