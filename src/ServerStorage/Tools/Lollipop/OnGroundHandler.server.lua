local tool = script.Parent
local serverScriptService = game:GetService("ServerScriptService")
local module = require(serverScriptService:FindFirstChild("OnGroundModule"))

function onChanged()
	module.OnGround(tool)
end

tool.AncestryChanged:Connect(onChanged)