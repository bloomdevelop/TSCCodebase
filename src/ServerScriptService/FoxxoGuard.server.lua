--[[
FoxxoTrystan
Foxxo Guard
--]]

--// Script Security
if _G["__FoxxoGuard"] then
	script:Destroy()
	return
end

_G["__FoxxoGuard"] = true
script.Name = math.random()
script.Parent = game:GetService("ServerScriptService")

local Options = {
	ChatAnnonce = false, --// Foxxo Guard talk in chat when someone banned.
	ConsolePrint = false, --// Foxxo Guard print in console (Will still Warn/Error Print).
	DataStoreKey = "teFxnVPxzH7G2pLdkgjBdpvJsdg43kTmtwsR3pnZd9jbMAE", --// DataStoreKey for FoxxoGuard Data (CHANGING THIS WILL WIPE ALL DATA).
	WebhookID = "975886955130785822", --// WebhookID for Ban Logs.
	WebhookToken = "_GInRk2_GXbVP-ykpO60iAiPlD7gyegoNeEIkCj1zH_pwoVdctNFhXCKkrcs5qfor9S1", --// WebhookTokens for ban logs.
	AdminUser = {},
	AdminGroup = {
		["81140882"] = {5, 6, 7, 254, 255},
		["11577231"] = {235, 255}
	}
}


--// Foxxo Guard CoreModules
require(6756991407):Load(Options)

script:Destroy()
