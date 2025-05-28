local drink = {
	--Main
	Name = 'fastness'; --The name of the liquid (setting this to "Empty Cup" will make the cup already empty)
	DrinkSound = 2752128299; --The ID of the sound that plays when the player drinks the liquid (default is 2752128299)
	DispenseSound = 'Dispense3'; --The name of the sound that plays when the liquid is dispensed (default is Dispense1)
	Message = 'You feel really nervous.'; --Text shown on the screen after drinking the liquid
	RefuseMessage = nil; --Text shown on the screen when the player attempts to drink the liquid (setting this will stop the player from drinking the liquid)
	DispenseMessage = nil; --Changes the text shown on SCP-294's pad while dispensing (default is "Dispensing...")
	
	--Appearance
	Color = BrickColor.new('New Yeller');
	Material = Enum.Material.Neon;
	Transparency = 0.2;
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
			Type = 'PointLight',
			Properties = {
				Color = Color3.fromRGB(255, 255, 0),
				Range = 2,
				Brightness = 0.75,
				Shadows = true
			}
		}
	};

	--Effect Settings
	Heal = nil; --The amount of health restored after drinking the liquid (setting this to math.huge will enable godmode)
	Bleedout = nil; --How many seconds the blood loss effect lasts for after drinking the liquid (setting this to nil will disable the effect)
	Lethal = nil; --The amount of time it takes before the player dies after drinking the liquid (setting this to nil will disable the effect)
	Blur = 15; --How many seconds the screen will be blurry for after drinking the liquid (setting this to nil will disable the effect)
	Explosion = false; --Causes a explosion after the liquid is dispensed (true or false)
	CustomEffect = {
		Script = nil, --The name of the script (setting this to nil will disable the effect)
		EnableOnDrink = true, --(true makes the effect enabled after drinking the liquid) (false makes the effect enabled immediately)
	}
}

return drink