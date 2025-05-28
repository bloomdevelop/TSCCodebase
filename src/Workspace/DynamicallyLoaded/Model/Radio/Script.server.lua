local music = script.Parent.music:GetChildren()
local sounds = {}

function startmusic()
	for i,v in ipairs(music) do
		
		if  v:IsA("Sound") then
			v:Play()
			wait()
			v.Ended:Wait()
			if i == #music then
			startmusic()
		end
	end
	end
	
end

startmusic()