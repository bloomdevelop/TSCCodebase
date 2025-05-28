--!strict
-- haha i am brave -hayper

local HayperScript = script.Parent
local DiscordWebhook = require(HayperScript:WaitForChild("DiscordWebhook"))
local Discord = require(HayperScript:WaitForChild("DiscordWebhook"):WaitForChild("Typing"))

local webhook = DiscordWebhook.new()

local WebhookHandler = {}

local embedQueue: {[string]: {[number]: Discord.RESTPostAPIWebhookWithTokenJSONBody}} = {}
local messageQueue: {[string]: {[number]: string}} = {}

export type Channel = "Adonis" | "Nojustno" | "Button"

local webhookType: {[Channel]: string} = {
	Adonis = "https://hooks.hyra.io/api/webhooks/920229983253856272/lSoW7aCMjiCMwYoHoHz9xpd0CRVhEieY6lgxiaS-hoy4zP6UT4EIZj9I2YarxwzbWX7d?wait=true",
	Nojustno ="https://hooks.hyra.io/api/webhooks/914600834535411722/vG7ImaDrsSmGXr1MJD80o7I3QO47dBg_b7JnZo1j-FLpEbeQKzta2uySjPRRG_KwYQoA?wait=true",
	Button = "https://hooks.hyra.io/api/webhooks/913691320579682324/sphNJZnNQrTU6vb_KjkbPhaRRF9QIcZl9TXRR3RuyGqGba52sy_ZW5SksWUqZ_g9qiET?wait=true"
}

function WebhookHandler.queueRequest(request: Discord.RESTPostAPIWebhookWithTokenJSONBody, channel: Channel?)
	local channel: Channel = channel or ("Adonis" :: Channel)
	embedQueue[channel] = embedQueue[channel] or {}
	table.insert(embedQueue[channel], request)
end

function WebhookHandler.queueMessage(content: string, channel: Channel?)
	local channel: Channel = channel or ("Adonis" :: Channel)
	messageQueue[channel] = messageQueue[channel] or {}

	table.insert(messageQueue[channel], string.format("[%s] | %s", DateTime.now():FormatUniversalTime("HH:mm:ss", "en-us"), content))
end

task.spawn(function()
	while task.wait(30) do
		for channelName,url in next, webhookType do
			if #(embedQueue[channelName] or {}) == 0 and #(messageQueue[channelName] or {}) == 0 then continue end

			for i=1, #(embedQueue[channelName] or {}) do
				webhook:Post(embedQueue[channelName][1], url)
				table.remove(embedQueue[channelName], 1)
				task.wait(1)
			end

			while #(messageQueue[channelName] or {}) ~= 0 do
				local content = "```"
				for i=1, #messageQueue[channelName] do
					local queuedMessage = messageQueue[channelName][1]
					local newContent = content .. "\n" .. queuedMessage
					if #queuedMessage > 1990 then
						table.remove(messageQueue[channelName], 1)
						break
					elseif #newContent >= 1990 then
						break
					else
						content = newContent
						table.remove(messageQueue[channelName], 1)
					end
				end
				content = content .. "\n```"

				if 7 >= #content then continue end

				local isInDevelopment = (game.PlaceId == 9672334663) or (game.PlaceId == 7587222120)

				webhook:Post({
					['username'] = "Thunder Scientific Corporation",
					['avatar_url'] = "https://cdn.discordapp.com/icons/859841688993529867/a_9f8163f5276ec3be6f4e8276e26c2fc2.gif",
					['embeds'] = {{
						['author'] = {
							["name"] = (os.date('%x') :: string) .. (isInDevelopment and " | DEVELOPMENT BUILD" or "")
						},
						['description'] = content,
						['color'] = 8323327
					}}
				} :: Discord.RESTPostAPIWebhookWithTokenJSONBody, url)
				task.wait(1)
			end
		end
	end
end)

return WebhookHandler