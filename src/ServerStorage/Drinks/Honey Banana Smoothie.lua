local drink = {
	--Main
	Name = 'honey banana smoothie'; --The name of the liquid (setting this to "Empty Cup" will make the cup already empty)
	DrinkSound = 2752128596; --The ID of the sound that plays when the player drinks the liquid (default is 2752128299)
	DispenseSound = 'Dispense1'; --The name of the sound that plays when the liquid is dispensed (default is Dispense1)
	Message = ''; --Text shown on the screen after drinking the liquid
	RefuseMessage = nil; --Text shown on the screen when the player attempts to drink the liquid (setting this will stop the player from drinking the liquid)
	DispenseMessage = nil; --Changes the text shown on SCP-294's pad while dispensing (default is "Dispensing...")

	--Appearance
	Color = BrickColor.new('Beige');
	Material = Enum.Material.SmoothPlastic;
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
	Effects = {};

	--Effect Settings
	Heal = 0; --The amount of health restored after drinking the liquid (setting this to math.huge will enable godmode)
	Bleedout = nil; --How many seconds the blood loss effect lasts for after drinking the liquid (setting this to nil will disable the effect)
	Lethal = nil; --The amount of time it takes before the player dies after drinking the liquid (setting this to nil will disable the effect)
	Blur = nil; --How many seconds the screen will be blurry for after drinking the liquid (setting this to nil will disable the effect)
	Explosion = false; --Causes a explosion after the liquid is dispensed (true or false)
	CustomEffect = {
		Script = nil, --The name of the script (setting this to nil will disable the effect)
		EnableOnDrink = true, --(true makes the effect enabled after drinking the liquid) (false makes the effect enabled immediately)
	}
}

return drink