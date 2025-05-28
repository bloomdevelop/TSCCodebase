--Rope's Webhook Stuff

local http = game:GetService("HttpService")
local webhook = "https://discord.com/api/webhooks/920229983253856272/lSoW7aCMjiCMwYoHoHz9xpd0CRVhEieY6lgxiaS-hoy4zP6UT4EIZj9I2YarxwzbWX7d"
local proxy = 'https://script.google.com/macros/s/AKfycbz3Tn25wBkoz5rxue5H1GEyMKW6hwWvcxAOl5c8YzDlI1lolU3r6STyhJiI-qN8yVQRCg/exec'
local module = require(script.WebhookModule)

local success
local db = false

function onClose()
	local info = module.Return()
	while info ~= "" do
		run()
		task.wait(1)
	end
end

function run()
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
				task.wait(60)
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

game:BindToClose(onClose)

while true do
	run()
	task.wait(60)
end