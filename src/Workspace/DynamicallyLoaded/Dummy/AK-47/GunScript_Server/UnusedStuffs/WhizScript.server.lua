repeat wait() until script.Parent~=nil

local creator = script:WaitForChild("creator").Value
HitPlayers = {}
local Radius = 30
local WhizSoundIDs = {269514869,269514887,269514807,269514817}
local WhizSoundPitch = 1
local WhizSoundVolume = 0.5

if creator == nil then
	script:Destroy()
	return
end
	
while true do	
    game:GetService("RunService").Stepped:wait()
    if creator==nil then
	    if script.Parent then
	        script.Parent:destroy()
	    end
	    script:Destroy()
	    return
    end
    local ray = Ray.new(script.Parent.Position, script.Parent.CFrame.lookVector*Radius)
    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {workspace:WaitForChild("Ignore"), creator})
    local players = game.Players:GetPlayers()
    for i = 1, #players do
        if players[i] and players[i].Name ~= creator.Name and players[i].Character and players[i].Character:FindFirstChild("HumanoidRootPart") then
            if script.Parent and (script.Parent.Position - players[i].Character.HumanoidRootPart.Position).magnitude <= Radius + (players[i].Character.HumanoidRootPart.Size.magnitude/2.5) and not HitPlayers[players[i]] then
                if hit and not hit:IsDescendantOf(players[i].Character) or hit == nil then
	                HitPlayers[players[i]] = true
		            local Sound = Instance.new("Sound", players[i])
		            Sound.SoundId = "rbxassetid://"..WhizSoundIDs[math.random(1, #WhizSoundIDs)]
		            Sound.PlaybackSpeed = WhizSoundPitch
		            Sound.Volume = WhizSoundVolume
		            Sound:Play()
                    game.Debris:AddItem(Sound, Sound.TimeLength)
                end
            end
        end
    end
    if hit then
        break
    end
end

script:Destroy()