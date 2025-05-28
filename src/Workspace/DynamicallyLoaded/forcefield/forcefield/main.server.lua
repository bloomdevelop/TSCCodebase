door=script.Parent:findFirstChild("door")
function check()
	if script.Parent.danger.Value==true then
		
			door.Transparency=0.9
			door.CanCollide=false
		elseif script.Parent.danger.Value==false then
			door.Transparency=0.5
			door.CanCollide=true

			end
		end

script.Parent.danger.Changed:connect(check)
zz=true
function touch(hit)
	if zz==true then
	if hit.Parent:findFirstChild("Humanoid")~=nil then
		zz=false
		script.Parent.danger.Value=true
		wait(1)
		
		script.Parent.danger.Value=false
		zz=true
	end
		
	end
end
script.Parent.hitlaser.touched:connect(touch)