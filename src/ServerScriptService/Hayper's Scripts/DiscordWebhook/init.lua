--!strict
local HttpService = game:GetService("HttpService")

local Discord = require(script:WaitForChild("Typing"))

export type Response = {
	Body: string,
	Headers: {[string]: string},
	StatusCode: number,
	StatusMessage: string,
	Success: boolean
}

export type EmbedResponse = {
	Body: Discord.APIMessage,
	Headers: {[string]: string},
	StatusCode: number,
	StatusMessage: string,
	Success: boolean
}

local DiscordWebhook = {}
DiscordWebhook.__index = DiscordWebhook

function DiscordWebhook.new(id: string?, token: string?, version: number?)
	local self = setmetatable({
		id = id,
		token = token,
		version = version or 9
	}, DiscordWebhook)
	return self
end

function DiscordWebhook:Post(data: Discord.RESTPostAPIWebhookWithTokenJSONBody, url: string?): EmbedResponse?
	url = url or "https://discordapp.com/api/v" .. (self.version :: string) .. "/webhooks/" .. (self.id :: string) .. "/" .. (self.token :: string) .. "?wait=true"

	local success : boolean, response : Response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
				["Accept"] = "application/json"
			},
			Body = HttpService:JSONEncode(data)
		})
	end)
	
	local message: Discord.APIMessage
	pcall(function()
		message = HttpService:JSONDecode(response.Body) :: Discord.APIMessage
	end)
	
	return {
		Body = message,
		Headers = response.Headers,
		StatusCode = response.StatusCode,
		StatusMessage = response.StatusMessage,
		Success = response.Success
	}
end

return DiscordWebhook