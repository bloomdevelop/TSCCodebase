--[[ Edited Version
====================================================================================================
Weapons and Tools Pack 2016's Gun by SuperEvilAzmil and edited by thienbao2109

Features:
- FilteringEnabled support
- Easy to edit with a bunch of settings
- No delays between Mouse Click and Gun Fire
====================================================================================================
]]

local Module = {
--	====================
--	BASIC
--	A basic settings for the gun
--	====================

		Auto = true;
		BaseDamage = 39;
		FireRate = 0.12; --In second
		ReloadTime = 3; --In second
		AmmoPerMag = 30; --Put "math.huge" to make this gun has infinite ammo and never reload
		Spread = 4; --In degree
		Range = 5000; --The furthest distance the bullet can travel
		HeadshotEnabled = true; --Enable the gun to do extra damage on headshot
		HeadshotDamageMultiplier = 2;
		EquipTime = 0.15; --In second
	IdleAnimationID = 7377154590; --Set to "nil" if you don't want to animate
	IdleAnimationSpeed = 1;
	FireAnimationID = 7377346341; --Set to "nil" if you don't want to animate
	FireAnimationSpeed = 1;
	ReloadAnimationID = 7377545814; --Set to "nil" if you don't want to animate
	ReloadAnimationSpeed = 0.8;
	EquippedAnimationID = nil; --Set to "nil" if you don't want to animate
	EquippedAnimationSpeed = 0.9;
		
	--Enable the user to play second animation. Useful for dual wield 
	SecondaryFireAnimationEnabled = false; --You need an animation ID in order to enable it
	SecondaryFireAnimationID = nil; --Set to "nil" if you don't want to animate
	SecondaryFireAnimationSpeed = 1;

	--Enable the user to play aim animations
	AimAnimationsEnabled = true;
	AimIdleAnimationID = 7377351057; --Set to "nil" if you don't want to animate
	AimIdleAnimationSpeed = 0.7;
	AimFireAnimationID = 7377341827; --Set to "nil" if you don't want to animate
	AimFireAnimationSpeed = 1;
	AimSecondaryFireAnimationID = nil; --Set to "nil" if you don't want to animate. NOTE: Make sure "SecondaryFireAnimation" setting is enabled
	AimSecondaryFireAnimationSpeed = 1;
		
		AutoReload = false; --Reload automatically when you run out of mag; disabling it will make you reload manually

-- ====================
-- SMOKE TRAIL
-- Emit smoke trail while firing. NOTE: This setting is only for client
-- ====================

		SmokeTrailEnabled = false;
		SmokeTrailRateIncrement = 1;
		MaximumRate = 4; --Beyond this will return "CurrentRate" to 0 and emit smoke trail. NOTE: Last smoke trail will be terminated after this
		MaximumTime = 1; --Maximum time that smoke trail won't be emitted
		
-- ====================
-- DAMAGE DROPOFF
-- Calculate how the damage of a single shot decreases when the target hit is at a distance away from the gun shot. NOTE: This setting won't apply with "ExplosiveEnabled"
-- ====================

		DamageDropOffEnabled = true;
		ZeroDamageDistance = 10000; --Anything hit at or beyond this distance will receive no damage; default is 10000
		FullDamageDistance = 10; --Maximum distance that shots will do full damage. Default is 1000 and anything hit beyond this distance will receive less and less damage as the distance nears "ZeroDamageDistance"
		
--	====================
--	GORE VISUALIZER
--	Create gore effect when humanoid died
--	====================

	GoreEffectEnabled = true;
	GoreSoundIDs = {3929462677,3739335394,3739335007,3929462189,3739364168,3737268126};
	GoreSoundPitchMin = 1; --Minimum pitch factor you will acquire
	GoreSoundPitchMax = 1.3; --Maximum pitch factor you will acquire
	GoreSoundVolume = 1.8;
		
--	====================
--	CRITICAL DAMAGE
--	Damage critically within its chance
--	====================

        CriticalDamageEnabled = false;
        CriticalBaseChance = 5; --In percent
        CriticalDamageMultiplier = 3;
		
--	====================
--	FIRE SOUND EFFECTS
--	Special effects for fire sound
--	====================
		
		SilenceEffect = false; --Lower volume
		EchoEffect = false; --Create echo effect from distance
		LowAmmo = true; --Play sound when low ammo
		RaisePitch = false; --"LowAmmo" only. The lower ammo is, the higher pitch will play
		
--	====================
--	WALK SPEED REDUTION
--	Nerf chraracter's walk speed when equip the gun
--	====================

        WalkSpeedRedutionEnabled = true;
        WalkSpeedRedution = 2;
	
--	====================
--	INSPECT ANIMATION
--	Inspect the gun just to see how it looks
--	====================

		InspectAnimationEnabled = false;
	InspectAnimationID = 7251289738; --Set to "nil" if you don't want to animate
		InspectAnimationSpeed = 1.1;
	
--	====================
--	TACTICAL RELOAD ANIMATION
--	Reload the gun that has only fired a few rounds out of its magazine
--	====================

		TacticalReloadAnimationEnabled = false;
		TacticalReloadAnimationID = nil; --Set to "nil" if you don't want to animate
		TacticalReloadAnimationSpeed = 1;
		TacticalReloadTime = 3;
		
--	====================
--	HOLD DOWN ANIMATION
--	Character won't fire if hold down the gun
--	====================

	HoldDownEnabled = true;
	HoldDownAnimationID = 6490166543;
	HoldDownAnimationSpeed = 0.5;
		
--	====================
--	BULLET HOLE VISUALIZER
--	Create a bullet hole when a bullet hit something but not character
--	====================

	BulletHoleEnabled = true;
	BulletHoleSize = 0.5;
	BulletHoleTexture = {3255253218, 3255254061, 3255254671, 3255255113, 3255255603}; --You can insert more IDs
	BulletHoleVisibleTime = 8; --In second
	BulletHoleFadeTime = 1; --In second
	PartColor = true; --Set to hit object color
		
--	====================
--	HIT VISUALIZER
--	Create hit effect when a bullet hit something but not character(And hit sound, too)
--	====================

	HitEffectEnabled = true;
	HitSoundIDs = {4791732980,4547754732,4791733290,3929444218,3929443580,3929443214,3929443996};
	HitSoundPitchMin = 0.9; --Minimum pitch factor you will acquire
	HitSoundPitchMax = 1.1; --Maximum pitch factor you will acquire
	HitSoundVolume = 1.2;
        CustomHitEffect = false; --Emits your custom hit effect. NOTE: If you this setting disabled, hit effect will set to default(material tracker included)

--	====================
--	BLOOD VISUALIZER
--	Create blood when a bullet hit character(And hit character sound, too)
--	====================

	BloodEnabled = true;
	HitCharSndIDs = {5764888727,5764887450,5764886834,3763650648,1255040462,3744371091,3744371584,3744371342,4086201632,4086202171,4086201929,3744371864,2640194863,2640195004,2640195159,2640195272,3932142219,3848986758,3848987400,4086190876};
	HitCharSndPitchMin = 0.9; --Minimum pitch factor you will acquire
	HitCharSndPitchMax = 1.1; --Maximum pitch factor you will acquire
	HitCharSndVolume = 1.4;
	
		--Blood wound
		BloodWoundEnabled = false;
		BloodWoundSize = 0.3;
	BloodWoundTexture = {3255253218, 3255254061, 3255254671, 3255255113, 3255255603}; --You can insert more IDs
		BloodWoundTextureColor = Color3.fromRGB(90, 0, 0);
		BloodWoundVisibleTime = 3; --In second
		BloodWoundFadeTime = 1; --In second
		BloodWoundPartColor = false; --Set to hit object color
	
--	====================
--	TWEEN SETTING
--	Part of ironsight and sniper aim
--	====================

        TweenLength = 0.8; --In second
        EasingStyle = Enum.EasingStyle.Quint; --Linear, Sine, Back, Quad, Quart, Quint, Bounce or Elastic?
        EasingDirection = Enum.EasingDirection.Out; --In, Out or InOut?

--	====================
--	TWEEN SETTING(NO AIM DOWN)
--	Part of ironsight and sniper aim
--	====================

        TweenLengthNAD = 0.8; --In second
        EasingStyleNAD = Enum.EasingStyle.Quint; --Linear, Sine, Back, Quad, Quart, Quint, Bounce or Elastic?
        EasingDirectionNAD = Enum.EasingDirection.Out; --In, Out or InOut?
		
--	====================
--	BULLET WHIZZING SOUND
--	Create a sound when a bullet travelling through character
--	====================

	WhizSoundEnabled = true;
	WhizSoundID = {3929412266,3929411554,3929410706};
	WhizSoundVolume = 1.4;
	WhizSoundPitchMin = 1; --Minimum pitch factor you will acquire
	WhizSoundPitchMax = 1.2; --Maximum pitch factor you will acquire
	WhizDistance = 25;
	
--		Make sure "CanMovePart" is enabled. Otherwise, it won't work
		
--	====================
--	HITMARKER
--	Mark on somewhere when a bullet hit character
--	====================

        HitmarkerEnabled = true;
	HitmarkerSoundID = {3748776946, 3748777642, 3748780065};
        --Normal
        HitmarkerColor = Color3.fromRGB(255, 255, 255);
        HitmarkerFadeTime = 0.4;
        HitmarkerSoundPitch = 1;
        --Headshot
        HitmarkerColorHS = Color3.fromRGB(255, 0, 0);
        HitmarkerFadeTimeHS = 0.4;
        HitmarkerSoundPitchHS = 1;

--	====================
--	CROSSHAIR
--	A gun cursor
--	====================

        CrossSize = 7;
        CrossExpansion = 100;
        CrossSpeed = 15;
        CrossDamper	= 0.8;
		
--	====================
--	MUZZLE
--	Create a muzzle flash when firing
--	====================
        
        MuzzleFlashEnabled = true;
        MuzzleLightEnabled = true;
        LightBrightness = 4;
        LightColor = Color3.new(255/255, 203/255, 0/255);
        LightRange = 15;
        LightShadows = true;
        VisibleTime = 0.01; --In second
		
--	====================
--	BULLET SHELL EJECTION
--	Eject bullet shells when firing
	--	====================
	
	BulletShellEnabled = true;
	BulletShellDelay = 0;
	BulletShellVelocity = 19;
	BulletShellRotVelocity = 40;
	ShellSize = Vector3.new(0.2, 0.2, 0.32); --Scale the part
	AllowCollide = true; --If false, a bullet shell will go through any parts
	ShellScale = Vector3.new(0.8, 0.8, 1.2); --Scale mesh
	ShellMeshID = 95392019;
	ShellTextureID = 95391833;
	DisappearTime = 5; --In second
		
--      You can edit velocity by go to GunScript_Local, and scroll down until you see "function EjectShell(ShootingHandle)"
		
--	====================
--	IRONSIGHT
--	Allow user to ironsighting
--	====================

		IronsightEnabled = true; --NOTE: If "SniperEnabled" is enabled, this setting is not work
		FieldOfViewIS = 50;
		MouseSensitiveIS = 0.5; --In percent
		SpreadRedutionIS = 0.6; --In percent. NOTE: Must be the same value as "SpreadRedutionS"
		CrossScaleIS = 0.6;
		
--	====================
--	LIMITED AMMO
--	Make a gun has a limit ammo
--	====================

		LimitedAmmoEnabled = true;
		Ammo = 210;
		MaxAmmo = 210; --Put "math.huge" to allow user to carry unlimited ammo
		
--	====================
--	SHOTGUN
--	Enable the gun to fire multiple bullet in one shot
--	====================

		ShotgunEnabled = false;
		BulletPerShot = 8;
		
		ShotgunPump = false; --Make user pumping like Shotgun after firing
		ShotgunPumpinAnimationID = nil; --Set to "nil" if you don't want to animate
		ShotgunPumpinAnimationSpeed = 1;
		ShotgunPumpinSpeed = 0.5; --In second
		SecondaryShotgunPump = false; --Only for dual wield
		SecondaryShotgunPumpinAnimationID = nil; --Set to "nil" if you don't want to animate
		SecondaryShotgunPumpinAnimationSpeed = 1;
		SecondaryShotgunPumpinSpeed = 0.5; --In second
		
		ShotgunReload = false; --Make user reloading like Shotgun, which user clipin shell one by one
		ShotgunClipinAnimationID = nil; --Set to "nil" if you don't want to animate
		ShotgunClipinAnimationSpeed = 1;
		ShellClipinSpeed = 0.5; --In second
		PreShotgunReload = false; --Make user pre-reloading before consecutive reload. NOTE: "ShotgunReload" must be enabled
		PreShotgunReloadAnimationID = nil; --Set to "nil" if you don't want to animate
		PreShotgunReloadAnimationSpeed = 1;
		PreShotgunReloadSpeed = 0.5; --In second
		
		ShotgunPattern = false;
		SpreadPattern = { --{x, y}. This should be the same as "BulletPerShot"
			-- inner 3
			{0, -0.4};
			{-0.35, 0.2};
			{0.35, 0.2};
		
			-- outer five
			{0, 1};
			{0.95, 0.31};
			{0.59, -0.81};
			{-0.59, -0.81};
			{-0.95, 0.31};
		};
		
--		How "ShotgunPump" works [Example 1]:

--      Fire a (shot)gun
--		>>>
--		After "FireRate", user will pump it, creates pumpin delay + "PumpSound"
		
--		How "ShotgunReload" works [Example 2]:

--		Play "ShotgunClipinAnimation" + Play "ShotgunClipin" Audio
--		>>>
--		Wait "ShellClipinSpeed" second(s)
--		>>>
--		Repeat "AmmoPerClip" - "Current Ammo" times
--		>>>
--		Play "ReloadAnimation" + Play "ReloadSound"
--		>>>
--		Wait "ReloadTime"
		
--	====================
--	BURST FIRE
--	Enable the gun to do burst firing like Assault Rifle
--	====================

		BurstFireEnabled = false;
		BulletPerBurst = 3;
		BurstRate = 0.075; --In second
		
--	====================
--	SNIPER
--	Enable user to use scope
--	====================

		SniperEnabled = false; --NOTE: If "IronsightEnabled" is enabled, this setting is not work
		FieldOfViewS = 12.5;
		MouseSensitiveS = 0.2; --In percent
		SpreadRedutionS = 0.6; --In percent. NOTE: Must be the same value as "SpreadRedutionOS"
		CrossScaleS = 0;
		ScopeSensitive = 0.25;
		ScopeDelay = 0;
		ScopeKnockbackSpeed = 7;
        ScopeKnockbackDamper = 0.65;
		ScopeSwaySpeed = 10;
        ScopeSwayDamper	= 0.4;

--      You can edit knockback offset by go to GunScript_Local, and scroll down until you reach line 421 and 486
		
--	====================
--	CAMERA RECOILING
--	Make user's camera recoiling when shooting
--	====================

		CameraRecoilingEnabled = true;
		Recoil = 95;
		AngleX_Min = 1; --In degree
		AngleX_Max = 1; --In degree
		AngleY_Min = -1; --In degree
		AngleY_Max = 1; --In degree
		AngleZ_Min = -1; --In degree
		AngleZ_Max = 1; --In degree
        Accuracy = 0.1; --In percent. For example: 0.5 is 50%
        RecoilSpeed = 38; 
        RecoilDamper = 0.5;
		RecoilRedution = 0.4; --In percent.
		
--	====================
--	EXPLOSIVE
--	Make a bullet explosive so user can deal a damage to multiple enemy in single shot. NOTE: Explosion won't break joints
--	====================

		ExplosiveEnabled = false;
		ExplosionSoundEnabled = true;
		ExplosionSoundIDs = {163064102};
		ExplosionSoundVolume = 1;
		ExplosionSoundPitchMin = 1; --Minimum pitch factor you will acquire
	    ExplosionSoundPitchMax = 1.5; --Maximum pitch factor you will acquire
		ExplosionRadius = 8;
		DamageBasedOnDistance = false;
		CustomExplosion = false;
		ExplosionKnockback = false; --Enable the explosion to knockback player. Useful for rocket jumping
		ExplosionKnockbackPower = 50;
		ExplosionKnockbackMultiplierOnPlayer = 2;
		ExplosionKnockbackMultiplierOnTarget = 2;
        ExplosionCraterEnabled = true;
      	ExplosionCraterSize = 3;
        ExplosionCraterTexture = {53875997}; --You can insert more IDs
        ExplosionCraterVisibleTime = 3; --In second
        ExplosionCraterFadeTime = 1; --In second
        ExplosionCraterPartColor = false; --Set to hit object color	

--	====================
--	PROJECTILE VISUALIZER
--	Display a travelling projectile
--	====================

		ProjectileType = "HeavyRifleBullet";
		BulletSpeed = 2600;
		Acceleration = Vector3.new(0,-20,0);
		CanSpinPart = false;
		SpinX = 3;
		SpinY = 0;
		SpinZ = 0;
		
--	====================
--	CHARGED SHOT
--	Make a gun charging before firing. Useful for a gun like "Railgun" or "Laser Cannon"
--	====================
		
		ChargedShotEnabled = false;
		ChargingTime = 1;
		
--	====================
--	MINIGUN
--	Make a gun delay before/after firing
--	====================

		MinigunEnabled = false;
		DelayBeforeFiring = 1;
		DelayAfterFiring = 1;
		MinigunRevUpAnimationID = nil;
		MinigunRevUpAnimationSpeed = 1;
		MinigunRevDownAnimationID = nil;
		MinigunRevDownAnimationSpeed = 1;
		
--	====================
--	MISCELLANEOUS
--	Etc. settings for the gun
--	====================

		Knockback = 0; --Setting above 0 will enabling the gun to push enemy back.
		Lifesteal = 0; --In percent - Setting above 0 will allow user to steal enemy's health by dealing a damage to them.

		FlamingBullet = false; --Enable the bullet to set enemy on fire. Its DPS and Duration can be edited inside "IgniteScript"
        IgniteChance = 100;

		FreezingBullet = false; --Enable the bullet to freeze enemy. Its Duration can be edited inside "IcifyScript"
        IcifyChance = 100;

		DualEnabled = false; --Enable the user to hold two guns instead one. In order to make this setting work, you must clone its Handle and name it to "Handle2". Enabling this setting will override Idle Animation ID.

		PenetrationType = "HumanoidPenetration"; --2 types: "WallPenetration" and "HumanoidPenetration"
		PenetrationDepth = 0; --"WallPenetraion" only. This is how many studs a bullet can penetrate into a wall. So if penetration is 0.5 and the wall is 1 studs thick, the bullet won't come out the other side. NOTE: It doesn't work with "ExplosiveEnabled"
		PenetrationAmount = 0; --"HumanoidPenetration" only. Setting above 0 will enabling the gun to penetrate up to XX victim(s). Cannot penetrate wall. NOTE: It doesn't work with "ExplosiveEnabled"
	
		SelfKnockback = false; --Enable the gun to knockback player. Useful for shotgun jumping
		SelfKnockbackPower = 50;
		SelfKnockbackMultiplier = 2;
		SelfKnockbackRedution = 0.8;

		ProjectileMotion = false; --Enable the gun to visible trajectory. Useful for projectile arc weapon
	
--	====================
--	CHARGED SHOT ADVANCE
--	Unlike "ChargedShot", this advanced version will allow gun to charge by holding down input. NOTE: This setting will disable some features such as "Auto", "ChargedShot", "MinigunEnabled"
--	====================

		ChargedShotAdvanceEnabled = false;
		AdvancedChargingTime = 5; --Known as Level3ChargingTime
		Level1ChargingTime = 1;
		Level2ChargingTime = 2;
		ChargingSoundIncreasePitch = true;
		ChargingSoundPitchRange = {1, 1.5};

		ChargingAnimationEnabled = false; --You need an animation ID in order to enable it
		ChargingAnimationID = nil; --Set to "nil" if you don't want to animate
		ChargingAnimationSpeed = 1;

		AimChargingAnimationID = nil; --Set to "nil" if you don't want to animate
		AimChargingAnimationSpeed = 1;

		ChargeAlterTable = {
		};
	
--	====================
--	END OF SETTING
--	====================
}

return Module