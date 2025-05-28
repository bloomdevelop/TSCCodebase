local remote = script.Parent.RemoteEvent

remote.OnServerEvent:Connect(function(plr, child)
	if not child then return end

	local parent = child.Parent
	if not parent then return end
	if parent ~= plr.Backpack and parent ~= plr.Character then return end

	child.Parent = workspace
	child.Handle.CFrame = child.Handle.CFrame + plr.Character.HumanoidRootPart.CFrame.LookVector * 3
end)