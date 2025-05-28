local drink = {
	name = 'Red Bull';
	dispenseSound = 'Dispense1';
	message = 'The drink tastes like an average energy drink.';
	
	--Appearance
	color = BrickColor.new('Bright yellow');
	material = 'SmoothPlastic';
	transparency = 0.25;
	lightColor = Color3.fromRGB(0, 0, 0);
	lightBrightness = 0;
	lightRange = 0;
	hasSparkles = false;
	hasSmoke = false;
	particleEmitter = nil; --Adds a particle when set to a ParticleEmitter, set to nil if you don't want a ParticleEmitter
	sparklesColor = Color3.fromRGB(0, 0, 0);
	smokeColor = Color3.fromRGB(0, 0, 0);
	
	--Effects
	heal = 0; --Amount of health restored when drank
	killEffect = false; --Kills the player, either instantly or within 'killTime'
	DPSEffect = false; --Damages the player over time, lasts for 'DPSTime'
	blurEffect = false; --Blurs the player for 'blurTime'
	speedReductionEffect = false; --Reduces the player by 'speedPenalty', lasts for 'speedReductionTime'
	explosionEffect = false; --Causes a nuclear explosion when dispensed
	refuseEffect = false; --Makes the player not drink it
	customEffect = nil; --Adds a effect when set to a script, set to nil if you don't want a custom effect
	
	--Effect options
	speedPenalty = 0;
	killTime = 0;
	DPSTime = 0;
	blurTime = 0;
	speedReductionTime = 0;
	enableCustomEffectNow = false; --Enables the custom effect when dispensed
}

return drink
