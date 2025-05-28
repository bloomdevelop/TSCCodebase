--Rope's Webhook Stuff

local SSS = game:GetService("ServerScriptService")
local http = game:GetService("HttpService")
local webhook = 'https://discord.com/api/webhooks/913691320579682324/sphNJZnNQrTU6vb_KjkbPhaRRF9QIcZl9TXRR3RuyGqGba52sy_ZW5SksWUqZ_g9qiET'
local proxy = 'https://script.google.com/macros/s/AKfycbz3Tn25wBkoz5rxue5H1GEyMKW6hwWvcxAOl5c8YzDlI1lolU3r6STyhJiI-qN8yVQRCg/exec'
local module = require(script.Parent.WebhookModule)

local success
local db = false

while true do
	local info = module.Return()
	if info == "" then else
		
		local date = os.date('%x')
		local data = {
			['webhook'] = webhook,
			['message'] = {
				['embeds'] = {{
					['title'] = date,
					['description'] = '```' .. info .. '```',
					['color'] = 8323327
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
	task.wait(30)
end