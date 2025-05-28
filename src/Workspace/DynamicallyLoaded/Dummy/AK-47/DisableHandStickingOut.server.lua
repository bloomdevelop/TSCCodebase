local NOHANDOUT_ID = 04602525186 


local function DisableHandOut(character)
	local Animator = character.Animate
	local Animation = Instance.new("Animation")
	Animation.AnimationId = "http://www.roblox.com/asset/?id="..NOHANDOUT_ID
	
	local ToolNone = Animator:FindFirstChild("toolnone")
	if ToolNone then
		local NewTool = Instance.new("StringValue")
		NewTool.Name = "toolnone"
		Animation.Name = "ToolNoneAnim"
		Animation.Parent = NewTool
		ToolNone:Destroy()
		NewTool.Parent = Animator
	end
end

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		DisableHandOut(character)
	end)
end)