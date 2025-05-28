local http = game:GetService("HttpService")
local url = "https://script.google.com/macros/s/AKfycbw7F4pMEnUDtCOou-twPZy0EHne4yusUGLglUWCJgEwsrEyEGKuv9P3nuBEuPnkEqtwqw/exec"
local module = require(script.WebhookModule)
local guid = http:GenerateGUID(false)
game.Workspace:SetAttribute("guid",guid)

local success
local db = false

while true do
	task.wait(60)
	local info = module.Return()
	if info == {} then else
		while not success do
			if db == true then
				task.wait(5)
			end
			success = pcall(function()
				http:PostAsync(url,http:JSONEncode(info))
			end)
			db = true
			task.wait()
		end
		success = nil
		db = false
	end
end

game:BindToClose(function()
	local info = module.Return()
	if info == {} then else
		while not success do
			if db == true then
				task.wait(5)
			end
			success = pcall(function()
				http:PostAsync(url,http:JSONEncode(info))
			end)
			db = true
			task.wait()
		end
		success = nil
		db = false
	end
end)