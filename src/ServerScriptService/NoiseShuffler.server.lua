local randomNoises = game.SoundService.SoundStorage.NoiseAmbients:GetChildren()
local backgroundMusic = game.SoundService.SoundStorage.BackgroundAmbients:GetChildren()
spawn(function()
	while true do
		local Ambient
		repeat
			Ambient = randomNoises[math.random(#randomNoises)]
			wait()
		until Ambient:IsA("Sound")
		if not Ambient.IsLoaded then 
			Ambient.Loaded:Wait()
		end
		--print("playing noise" .. Ambient.Name)
		Ambient:Play()
		wait(Ambient.TimeLength + math.random(120,500))
		Ambient:Stop()
	end
end)

while true do
	local Ambient
	repeat
		Ambient = backgroundMusic[math.random(#backgroundMusic)]
		wait()
	until Ambient:IsA("Sound")
	if not Ambient.IsLoaded then 
		Ambient.Loaded:Wait()
	end
	--print("playing ambient" .. Ambient.Name)
	Ambient:Play()
	wait(Ambient.TimeLength + math.random(60,120))
	Ambient:Stop()
end
