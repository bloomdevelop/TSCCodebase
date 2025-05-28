local userInputService = game:GetService("UserInputService")
--local Players = game:GetService("Players")
--local Player = Players.LocalPlayer
--local TweenService = game:GetService("TweenService")
--local Transparency = script.Awooga.ImageLabel.BackgroundTransparency
--local time = 1 
--local FadeIn = TweenService:Create(Transparency, TweenInfo.new(time), {Transparency = 1})
--local FadeOut = TweenService:Create(Transparency, TweenInfo.new(time), {Transparency = 0})
Password = "ABCD"
PasswordTable = {
	"A",
	"B",
	"C",
	"D"
}

userInputService.InputBegan:connect(function(inputObject, gameProcessedEvent)
	 if table:(PasswordTable,Enum.KeyCode) and not gameProcessedEvent  then
		
		
		--print("Awooga")
		script.Awooga.Enabled = true
		--FadeIn:Play()
	
		script.Awooga.Sound:Play()
		wait(5)
		--FadeOut:Play()
		script.Awooga.Enabled = false
	end
end)