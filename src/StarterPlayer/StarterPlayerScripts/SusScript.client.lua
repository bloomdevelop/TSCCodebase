local userInputService = game:GetService("UserInputService")

game.ContextActionService:BindAction("sus", function(actionName, userInputState, inputObject: InputObject)
	if inputObject.UserInputState ~= Enum.UserInputState.Begin then return end
	game.SoundService.SoundStorage.Misc.DeadBodyReported:Play()
end, false, Enum.KeyCode.H)