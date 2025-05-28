local Bomber = script.Parent.Parent.Parent

local phrases = {"HAHAHA","B-BOMB THEM","HAHA","b-b-b-bom-bombb themm","k-kill all s-s-security","m-make THEM PAY","b-bombbs..","DOWN WITH TSC","I-I-I'LL SHOW THEM","I-ILL MAKE THEM P-PAY","Y-Y-YOU DON'T KNOW WHAT T-THIS PLACE IS R-REALLY ABOUT, D-DO YOU..","I-I'll s-show them..."}
local talkcooldown = math.random(5,10)
while wait(talkcooldown) do
	local phrase = phrases[math.random(1,#phrases)]
	game:GetService("Chat"):Chat(Bomber.Head.TalkingPart,phrase,Enum.ChatColor.White)
end