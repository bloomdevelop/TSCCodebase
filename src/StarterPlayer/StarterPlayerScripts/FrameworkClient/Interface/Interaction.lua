local Typing = require(game:GetService('ReplicatedStorage').Typing)

return function(Framework: Typing.FrameworkType, Interface: Typing.InterfaceType)
	
	Interface.Interaction = {}
	Interface.Interaction.UI = {}
	
	Interface.Interaction.UI.Select = Interface.UI.SELECT
	Interface.Interaction.UI.CurrentAlert = (nil :: TextLabel);
	Interface.Interaction.UI.Label = script.Interaction:Clone()
	
	Interface.Interaction.UI.Label.Parent = Interface.UI

	function Interface.Interaction:ShowAlert(text)
		if Interface.Interaction.UI.CurrentAlert then
			Framework.Services.TweenService:Create(Interface.Interaction.UI.CurrentAlert, TweenInfo.new(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Position = Interface.Interaction.UI.CurrentAlert.Position + UDim2.new(0, 0, 0, 10),
				TextStrokeTransparency = 1,
				TextTransparency = 1
			}):Play()
		end
		local f = script.InteractionAlert:Clone()
		Interface.Interaction.UI.CurrentAlert = f
		f.Parent = Interface.UI
		f.Text = text or "Something happened, and we don't know what..."
		f.Visible = true
		Framework.Services.TweenService:Create(f, TweenInfo.new(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Position = f.Position + UDim2.new(0, 0, 0, -10),
			TextStrokeTransparency = 0.8,
			TextTransparency = 0
		}):Play()
		task.wait(0.5)
		Framework.Services.TweenService:Create(f, TweenInfo.new(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 4), {
			Position = f.Position + UDim2.new(0, 0, 0, 10),
			TextStrokeTransparency = 1,
			TextTransparency = 1
		}):Play()
		;(Framework.Services.Debris :: Debris):AddItem(f, 5)
	end

	function Interface.Interaction:ShowInteraction(text)
		if text == Interface.Interaction.UI.Label.Text then
			return -- lol
		end
		if Interface.Interaction.UI.Label.TextTransparency ~= 1 then
			Framework.Services.TweenService:Create(Interface.Interaction.UI.Label, TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				TextStrokeTransparency = 1,
				TextTransparency = 1
			}):Play()
			task.wait(0.1)
		end
		Interface.Interaction.UI.Label.Text = text
		Framework.Services.TweenService:Create(Interface.Interaction.UI.Label, TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			TextStrokeTransparency = 0.8,
			TextTransparency = 0
		}):Play()
	end

	function Interface.Interaction:HideInteraction()
		if Interface.Interaction.UI.Label.TextTransparency ~= 1 then
			Framework.Services.TweenService:Create(Interface.Interaction.UI.Label, TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				TextStrokeTransparency = 1,
				TextTransparency = 1
			}):Play()
			task.wait(0.1)
			Interface.Interaction.UI.Label.Text = ""
		end
	end
	
	function Interface.Interaction:UpdatePos(vec3: Vector3, update: number)
		if vec3 and type(vec3) then
			local pos, bounds = Interface.Camera:WorldToScreenPoint(vec3)
			Interface.Interaction.UI.Select.Position = Interface.Interaction.UI.Select.Position:Lerp(UDim2.new(0, pos.X, 0, pos.Y), update)
			return bounds
		else
			Interface.Interaction.UI.Select.Position = Interface.Interaction.UI.Select.Position:Lerp(UDim2.new(0.5, 0, 0.5, 0), update)
		end
		return false
	end
end