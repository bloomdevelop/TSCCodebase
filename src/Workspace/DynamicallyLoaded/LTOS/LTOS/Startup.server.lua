local DB = false
local Enabled = false

local LTOS = script.Parent
local Display = LTOS.Display
local PowerOn = Display.PowerOn
local Screen = Display.Screen

local function OnClick(player) 
	if DB then return end
	DB = true
	PowerOn.ClickDetector.MaxActivationDistance = 0
	Screen.Click1:Play()
	wait(0.5)
	Screen.ComputerBeep:Play()
	Display.Keyboard.ComputerLoop.Playing = true
	wait(2)
	Screen.BrickColor = BrickColor.new('Smoky grey')
	LTOS.Text.PoweringOn.SurfaceGui.Enabled = true
	Screen.Bootup:Play()
	Screen.Startup:Play()
	wait(5)
	Screen.BrickColor = BrickColor.new('Bright blue')
	Screen.AccessGranted2:Play()
	LTOS.Text.PoweringOn.SurfaceGui.Enabled = false
	LTOS.Text.LTOS.SurfaceGui.SIGN.Visible = true
	wait(0.5)
	LTOS.Text.LoginText.SurfaceGui.SIGN.Visible = true
	wait(0.5)
	LTOS.Text.InfoBox.SurfaceGui.SIGN.Visible = true
	LTOS.Keyboard.ClickDetector.MaxActivationDistance = 5
	DB = false
end

	                           
script.Parent.ClickDetector.MouseClick:connect(OnClick) 