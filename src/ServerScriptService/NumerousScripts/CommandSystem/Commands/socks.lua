
local match = string.match

return function()
	return {
		Command = "socks",
		Function = function(plr, args)
			local t = "default"
			local stripeColor = Color3.new(0, 0, 0)
			local mainColor = Color3.new(1, 1, 1)
			if args[1] ~= nil then
				if args[3] == nil then
					t = "hex"
				else
					t = "rgb"
				end
				if t == "hex" then
					if args[2] then
						mainColor = Color3.fromHex(args[2])
					end
					stripeColor = Color3.fromHex(args[1])
				elseif t == "rgb" then
					if args[4] then
						mainColor = Color3.fromRGB(args[4], args[5], args[6])
					end
					stripeColor = Color3.fromRGB(args[1], args[2], args[3])
				end
			end
			local Character = plr.Character
			if Character ~= nil then
				for _, v in next, Character:GetChildren() do
					if match(v.Name, "Left ") and not v:FindFirstChild('left') then
						local sock = game.ServerStorage.Socks.left:Clone()
						sock.stripes.Color = stripeColor
						sock.Color = mainColor
						sock.weld.Part1 = v
						sock.Parent = v
					elseif match(v.Name, "Right") and not v:FindFirstChild('right') then
						local sock = game.ServerStorage.Socks.right:Clone()
						sock.stripes.Color = stripeColor
						sock.Color = mainColor
						sock.weld.Part1 = v
						sock.Parent = v
					end
				end
			end
		end,
	}
end
