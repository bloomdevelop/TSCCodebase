Typing = require(script.Parent.Parent.Typing)
return function(Framework: Typing.FrameworkType, Interface: Typing.InterfaceType)
	-- INITILAIZATION
	
	local Buttons = {
		UI = Interface.UI.Container,
		GraphicsEditor = require(Framework.Services.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GraphicsEditor")).new(),
		boomboxMuted = false,
		ambienceMute = false,
		lowgfx = false,
		StoredSignals = {},
		StoredParts = {},
		StoredTextures = {},
		PlayersChar = {},
		Buttons = {}
	}
	
	for _, key: ImageButton | TextButton in pairs(Buttons.UI:GetChildren()) do
		if key:IsA("ImageButton") or key:IsA("TextButton") then
			Buttons.Buttons[key.Name] = key
		end
	end
	
	-- STRUCTURE
	
	local ButtonInput = {
		["boombox"] = {
			UI = Buttons.UI.BoomboxMute,
			Func = function(): boolean
				Buttons.boomboxMuted = not Buttons.boomboxMuted
				Buttons.UI.BoomboxMute.Image = Buttons.boomboxMuted and "rbxassetid://7123489762" or "rbxassetid://7123478949"
				Framework.Services.SoundService.Boombox.Volume = Buttons.boomboxMuted and 0 or 0.5
				return true
			end,
			Hover = function(Input: boolean): boolean
				if (Input) then
					Buttons.UI.BoomboxMute.TextLabel.Visible = true
				else
					Buttons.UI.BoomboxMute.TextLabel.Visible = false
				end
				return true
			end,
		},
		["ambience"] = {
			UI = Buttons.UI.AmbienceMute,
			Func = function(): boolean
				Buttons.ambienceMute = not Buttons.ambienceMute
				Buttons.UI.AmbienceMute.Image = Buttons.ambienceMute and "rbxassetid://7123489762" or "rbxassetid://7123478949"
				Framework.Services.SoundService.Ambience.Volume = Buttons.ambienceMute and 0 or 0.5
				return true
			end,
			Hover = function(Input: boolean): boolean
				if (Input) then
					Buttons.UI.AmbienceMute.TextLabel.Visible = true
				else
					Buttons.UI.AmbienceMute.TextLabel.Visible = false
				end
				return true
			end,
		},
		["lowgfx"] = {
			UI = Buttons.UI.LG,
			Func = function(): boolean
				Buttons.lowgfx = not Buttons.lowgfx
				Framework.Services.StarterGui:SetCore("SendNotification", {
					Title = "Low Graphic",
					Text = Buttons.lowgfx and "Enabled" or "Disabled",
				})
				Buttons.GraphicsEditor:SetGraphic("Lighting", not Buttons.lowgfx)
				Buttons.GraphicsEditor:SetGraphic("CastShadow", not Buttons.lowgfx)
				Buttons.GraphicsEditor:SetGraphic("TextureAppearance", not Buttons.lowgfx)
			end,
			Hover = function(Input: boolean): boolean
				if (Input) then
					Buttons.UI.LG.TextLabel.Visible = true
				else
					Buttons.UI.LG.TextLabel.Visible = false
				end
			end,
		},
		["faction"] = {
			UI = Buttons.UI.Faction,
			Func = function(): boolean
				Framework.Services.StarterGui:SetCore("SendNotification", {
					Title = "Factions",
					Text = "This feature is not ready yet!",
				})
			end,
			Hover = function(Input: boolean): boolean
				if (Input) then
					Buttons.UI.Faction.TextLabel.Visible = true
				else
					Buttons.UI.Faction.TextLabel.Visible = false
				end
			end,
		}
	}
	
	function Buttons:HandleInput(Button: ImageButton | TextButton, Hover: boolean, Input: boolean): nil
		for InputKey, key in next, ButtonInput do
			if Button == key.UI then
				if (Hover) then
					key.Func()
				else
					key.Hover(Input)
				end
				Framework.Logger.debug('[ BUTTONS / DEBUG ]', 'Input Detected, Input: '..InputKey)
			end
		end
	end

	for _, key: ImageButton | TextButton in next, Buttons.Buttons do
		key.MouseButton1Click:Connect(function() Buttons:HandleInput(key, true) end)
		key.MouseEnter:Connect(function() Buttons:HandleInput(key, false, true) end)
		key.MouseLeave:Connect(function() Buttons:HandleInput(key, false, false) end)
	end

	-- FINALIZE

	Interface.Buttons = Buttons
end