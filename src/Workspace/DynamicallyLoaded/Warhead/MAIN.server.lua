-- // Juustopaketti
-- // The most catastrophic code you'll ever see, hopefully better than the original warhead script though


-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////// VARIABLES //////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- // SERVICES
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

-- // GLOBAL
local SystemOnline = false

-- // INTERACTS
local MainPower			= script.Parent.ActivationSystem.INTERACTS.MainPower
local Keycard			= script.Parent.ActivationSystem.INTERACTS.KeycardReader
local PrimeBtn			= script.Parent.ActivationSystem.INTERACTS.Prime
local EngageBtn			= script.Parent.ActivationSystem.INTERACTS.Engage

local DetonationKey1	= script.Parent.ActivationSystem.INTERACTS["_PRIMARYPANEL"].Key1
local DetonationKey2	= script.Parent.ActivationSystem.INTERACTS["_PRIMARYPANEL"].Key2
local DetonationButton	= script.Parent.ActivationSystem.INTERACTS["_PRIMARYPANEL"].DetonationButton

-- // SCREENS
local PrimaryScreen		= script.Parent.ActivationSystem.Screens.PrimaryScreen
local SecondaryScreen1	= script.Parent.ActivationSystem.Screens.SecondaryScreen1
local SecondaryScreen2	= script.Parent.ActivationSystem.Screens.SecondaryScreen2

-- // OTHER
local Sounds 			= script.Parent.ActivationSystem.Sounds


-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////// ACTIVATION /////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function MainLever()
	
end
MainPower.Hitbox.ClickDetector.MouseClick:Connect(MainLever)

function KeycardReader()
	
end
Keycard.PromptPart.ProximityPrompt.Triggered:Connect(KeycardReader)

function Prime()
	
end
PrimeBtn.Hitbox.ClickDetector.MouseClick:Connect(MainLever)

function Engage()
	
end
EngageBtn.Hitbox.ClickDetector.MouseClick:Connect(MainLever)

function DtnKey1()
	
end

function DtnKey2()

end

function DtnBtuton()

end