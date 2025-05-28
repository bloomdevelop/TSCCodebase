for i,v: Instance in pairs(game:GetDescendants()) do
	if v:IsA("RemoteEvent") then
		v.OnClientEvent:Connect(function()
			print("REMOTE CALLED: "..v.Name)
		end)
	end
end