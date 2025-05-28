local ReplicatedStorage = game:GetService('ReplicatedStorage')

local discordWebHook = require(script.Webhook)
local hook = discordWebHook.new('[id]', '[token]')

local Remote: BindableFunction = ReplicatedStorage.Remotes.Logger

local avatarUrl = "https://cdn.discordapp.com/icons/859841688993529867/a_9f8163f5276ec3be6f4e8276e26c2fc2.gif?size=256"

Remote.OnInvoke = function(b)
	local msg = hook:NewMessage()
	msg:SetAvatarUrl(avatarUrl)
	msg.SetUsername("Logger")
	local embed = msg:NewEmbed()
	if b.title then
		embed:SetTitle(b.title)
	end
	if b.content then
		embed:AppendLine(b.content)
	end
	if b.thumbnail then
		embed:SetThumbnailIconURL(b.thumbnail)
	end
	embed:SetColor3(Color3.fromRGB(68, 86, 252))
	msg.SetTTS(false)
	msg:Send()
end
