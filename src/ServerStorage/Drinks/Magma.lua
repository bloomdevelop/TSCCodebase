local drink = {
	--Main
	Name = 'lava'; --The name of the liquid (setting this to "Empty Cup" will make the cup already empty)
	DrinkSound = 364524666; --The ID of the sound that plays when the player drinks the liquid (default is 2752128299)
	DispenseSound = 'Dispense1'; --The name of the sound that plays when the liquid is dispensed (default is Dispense1)
	Message = 'The liquid disintegrates your insides almost instantly.'; --Text shown on the screen after drinking the liquid
	RefuseMessage = nil; --Text shown on the screen when the player attempts to drink the liquid (setting this will stop the player from drinking the liquid)
	DispenseMessage = nil; --Changes the text shown on SCP-294's pad while dispensing (default is "Dispensing...")

	--Appearance
	Color = BrickColor.new('Really red');
	Material = Enum.Material.Neon;
	Transparency = 0;
	Reflectance = 0;

	--[[ Effect Format
	{
		Type = 'PointLight/SpotLight/SurfaceLight/Fire/Smoke/Sparkles/Beam/Trail/ParticleEmitter';
		Properties = {
			InstanceProperty = Value
		}
	}
	--]]
	Effects = {
		{
			Type = 'ParticleEmitter';
			Properties = {
				Color = ColorSequence.new(Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 0, 0)),
				Texture = 'rbxassetid://301261210',
				Size = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.3, 0.075),
					NumberSequenceKeypoint.new(1, 0.025),
				},
				Transparency = NumberSequence.new{
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.125, 0),
					NumberSequenceKeypoint.new(0.75, 0),
					NumberSequenceKeypoint.new(1, 1),
				},
				LightEmission = 1,
				LightInfluence = 0,
				Speed = NumberRange.new(1.5, 3),
				Acceleration = Vector3.new(0, 1, 0),
				Rotation = NumberRange.new(-180, 180),
				SpreadAngle = Vector2.new(20, 20),
				Rate = 2.5,
				Lifetime = NumberRange.new(1),
				EmissionDirection = Enum.NormalId.Left
			}
		},
		{
			Type = 'PointLight';
			Properties = {
				Color = Color3.fromRGB(255, 0, 0),
				Range = 2,
				Brightness = 0.75,
				Shadows = true,
			}
		}
	};

	--Effect Settings
	Heal = 0; --The amount of health restored after drinking the liquid (setting this to math.huge will enable godmode)
	Bleedout = nil; --How many seconds the blood loss effect lasts for after drinking the liquid (setting this to nil will disable the effect)
	Lethal = 0; --The amount of time it takes before the player dies after drinking the liquid (setting this to nil will disable the effect)
	Blur = nil; --How many seconds the screen will be blurry for after drinking the liquid (setting this to nil will disable the effect)
	Explosion = false; --Causes a explosion after the liquid is dispensed (true or false)
	CustomEffect = {
		Script = nil, --The name of the script (setting this to nil will disable the effect)
		EnableOnDrink = true, --(true makes the effect enabled after drinking the liquid) (false makes the effect enabled immediately)
	}
}

return drink