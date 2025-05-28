--[[
	
	TODO: Develop a working system
	
]]


return function(Framework: FrameworkType)
	local Interaction = {}
	Interaction.__index = Interaction
	
	function Interaction.Interact(p: Player, node: BasePart)
		if p then
			if not p.Character or not p.Character:FindFirstChild('HumanoidRootPart') or not p.Character:FindFirstChild('Humanoid') then
				p:Kick("\n\nUnexpected Server Request [2024]\n\nInvalid character model")
				return
			end
			if not node or typeof(node) ~= 'Instance' or not ((typeof(node) == 'Instance') and node:IsA('BasePart')) then
				p:Kick("\n\nUnexpected Server Request [2025]\n\nInvalid node argument")
				return
			end
			if (node.Position - p.Character.HumanoidRootPart.Position).Magnitude > (node:GetAttribute('MaxDistance') * 2) then
				if (node.Position - p.Character.HumanoidRootPart.Position).Magnitude > (node:GetAttribute('MaxDistance') * 50) then
					p:Kick("\n\nUnexpected Server Request [2026]\n\nToo far of an interaction")
				end
				return
			end
		end
		if not node:IsDescendantOf(Framework.Services.Workspace.Map.Interactables) then
			if p then
				p:Kick("\n\nUnexpected Server Request [2027]\n\nInvalid node")
			end
			return
		end
		local interact = node:FindFirstAncestorOfClass('Model')
		if interact and interact:GetAttribute('InteractType') then
			local f = Framework("I_" .. interact:GetAttribute('InteractType'), true)
			if f then
				return f.Execute(node, interact, p)
			else
				return false, "Invalid interact model"
			end
		end
	end
	
	require(script.Details)(Framework, Interaction)
	
	Framework.Network:Add("interact", Interaction.Interact)
	
	return Interaction
end