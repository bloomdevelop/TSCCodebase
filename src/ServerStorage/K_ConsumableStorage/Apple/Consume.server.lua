local Tool = script.Parent

local db, broken = false, false

local Chr

local function onActivated()
	if db or broken then return end
	db = true
	Animation:Play()
	task.wait(0.7)
	Chr.Humanoid.Health += 2
	broken = true; db = false
	Tool.Handle.Transparency = 1
	local HandleColor = Tool.Handle.Color
	Tool.Handle.ParticleEmitter.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,HandleColor),ColorSequenceKeypoint.new(1,HandleColor)})
	Tool.Handle.ParticleEmitter:Emit(50); 
	Tool.Handle.Sound:Play()
	task.wait(0.7)
	Tool:Destroy()
end

local function onEquipped()
	if Chr == Tool.Parent then return end
	Chr = Tool.Parent
	Animation = Chr.Humanoid.Animator:LoadAnimation(script.Animation)
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
