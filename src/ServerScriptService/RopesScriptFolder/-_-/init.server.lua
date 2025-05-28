local http = game:GetService("HttpService")
local webhook = "https://discord.com/api/webhooks/914600834535411722/vG7ImaDrsSmGXr1MJD80o7I3QO47dBg_b7JnZo1j-FLpEbeQKzta2uySjPRRG_KwYQoA"
local proxy = 'https://script.google.com/macros/s/AKfycbz3Tn25wBkoz5rxue5H1GEyMKW6hwWvcxAOl5c8YzDlI1lolU3r6STyhJiI-qN8yVQRCg/exec'
local module = require(script.WebhookModule)

local success
local db = false

while task.wait(60) do
	local info = module.Return()
	if info == "" then else
		local date = os.date('%x')
		local data = {
			['webhook'] = webhook,
			['message'] = {
				['embeds'] = {{
					['title'] = date,
					['description'] = '```' .. info .. '```',
					['color'] = 5793266
				}}
			}
		}
		local finalData = http:JSONEncode(data)
		
		while not success do
			if db == true then
				task.wait(5)
			end
			success = pcall(function()
				http:PostAsync(proxy,finalData)
			end)
			db = true
			task.wait()
		end
		success = nil
		db = false
	end
end