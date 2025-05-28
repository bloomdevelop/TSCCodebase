local bloodsplats = {"408754747","408320359","408320438","508050982" } 

local human = script.Parent:WaitForChild("Humanoid")

human.Died:Connect(function()
	local headcf = script.Parent.Head.CFrame
	for i = 1,5 do
		local a = Instance.new("Part",nil)
		a.Size = Vector3.new(math.random(2,5),math.random(2,5),0.05)
		a.Transparency = 1
		a.CanCollide = false
		a.Anchored = true
		local decal = Instance.new("Decal",a)
		decal.Texture = "rbxassetid://"..bloodsplats[math.random(#bloodsplats)] 
		
		local dir = Vector3.new(math.random(-50,50),math.random(-50,50),math.random(-50,50)).Unit * 20
		local ray = Ray.new(headcf.Position,dir)
		local part,pos,normal = workspace:FindPartOnRay(ray,script.Parent,false,true)
		if part ~= nil then
			a.CFrame = CFrame.new(pos,pos + normal)
			a.Parent = workspace
		end
		
		game:GetService("Debris"):AddItem(a,10)
	end
end)