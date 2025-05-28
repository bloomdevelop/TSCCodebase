local MessNodeList = workspace:WaitForChild("Messes"):GetChildren()
local ActiveMess = workspace:WaitForChild("Messes"):WaitForChild("ActiveMesses")

for _,node in next, MessNodeList do
	if not node:IsA("BasePart") then continue end
	
	local ObjectValue = Instance.new("ObjectValue")
	ObjectValue.Name = "ActiveMess"
	ObjectValue.Parent = node
end

local RNG = Random.new()

repeat
	local selectedNode
	local tries = 0
	
	repeat
		tries += 1
		local randomNode = MessNodeList[RNG:NextInteger(1, #MessNodeList)]
		
		if not randomNode:IsA("BasePart") or not randomNode:FindFirstChild("ActiveMess") then continue end
		if (randomNode.ActiveMess :: ObjectValue).Value ~= nil then continue end
		
		selectedNode = randomNode
	until selectedNode or tries >= #MessNodeList
	
	if not selectedNode then task.wait(RNG:NextInteger(1, 40)); continue end
	
	local mess
	
	local AllowsLatex = selectedNode:FindFirstChild("AllowsLatex") :: BoolValue
	
	if AllowsLatex and AllowsLatex.Value and RNG:NextInteger(1,250) == 250 then
		mess = RNG:NextInteger(1, 2) == 1 and script:WaitForChild("DarkLatex"):Clone() or script:WaitForChild("WhiteLatex"):Clone()
	else
		mess = RNG:NextInteger(1, 2) == 1 and script:WaitForChild("BloodOne"):Clone() or script:WaitForChild("BloodTwo"):Clone()
	end
	
	mess.CFrame = selectedNode.CFrame
	mess.Orientation = Vector3.new(0, RNG:NextInteger(0, 360), (mess.Name == "DarkLatex" or mess.Name == "WhiteLatex") and -90 or 0)
	
	selectedNode.ActiveMess.Value = mess
	
	mess.Parent = ActiveMess
	
	task.wait(RNG:NextInteger(1, 40))
until false