local CS = game:GetService('CollectionService')
local m = require(script.Setup)

for _,v in pairs(CS:GetTagged("CursedClothing")) do
	m.new(v)
end