local sentences = {
	"TSC V.S. TSCZ, learn the difference!",
	"Whispy Cinnamon Rolls (Trademark) are on sale this week!",
	"Head down to the cafeteria this Friday to get yourself some pizza, courtesy of our wonderful cooks. Glory to TSC.",
	"Report any suspicious activity to your supervisor or nearest combative immediately!",
	"Thunder Scientific Corporation is maintained at a comfortable 21 Degrees celsius at all times.",
	"Entering areas you are not authorized to enter may result in serious consequences.",
	"Report any messes to your nearest janitor to keep the facility clean and sanitary.",
	"As cute as they may be, please refrain from making any direct physical contact with specimen.",
	"Follow procedure and head to your nearest shelter if any alarms should come on.",
	"Do not run in the halls.",
	"Join SD today and protect whats good!",
	"Want to be the front line of defence? Head on down the Security Department headquarters and apply today!",
	"Want to help keep personnel happy and healthy? Then apply for Medical Department today!",
	"Originally build through the early 40's into the late 50's, Thunder Scientific Corporation was one of the most advanced facilities of it's time!",
	"Can you handle a mop? Maybe you're fit for Utility & Maintenance.",
	"Remember to report any personnel breaking the CoE, we can't risk another lawsuit.",	
	"Any and all personnel suspected of contacting anyone Off-Site during their rotation will be brought in for immediate questioning.",
	"Do you taste metal? Maybe you should consider reminding your local Scientist or Janitor to check up on the reactor and make sure it's in working condition!",
	"Breaking protocol will result in serious consequences! Nobody is immune!",
	"Do not scan your card in a slot that wont read it, that means your clearance isn't high enough to open it. And you're wearing down those poor readers!",
	"Do not resist random quarentine. Glory to TSC.",
	"Have your papers with you at all times, or you be reprimanded",
	"This facility runs on 20% productiveness, and 80% pain!",
	"Originally designed as a military weapons research base, Thunder Scientific Corporation has adapted this site for all fields of research after it was purchased back in 1986!",
	"Designing or consuming media that leaks information about our research here is strictly prohibited! Anyone found playing the aformentioned 'Changed' video game will be taken in for questioning.",
	"If we find out you've been the one taking more than one lollipop from MD, you're gonna be paying for every last one.",
	"Remember, if any SCP foundation personnel show up here again accusing us of stealing SCP-294, we haven't!",
	"Our On-Site nuclear warhead's big red button is bigger than Laboratory Technologies's ever will be!",
	"Do not attempt to step up two stairs at once, it is dangerous.",
	"Keep away from any vents or air ducts during a breach.",
	"Don’t get your foot caught in the tram line!",
	"Ethics Committee, Committing unethical practices since 1967.",
	"If you think you recognize a Test Subject from a missing poster, please report it SD headquarters.",
	"Test Subjects caught wandering by themselves are KOS.",
	"What happens in the Facility, stays in the Facility. Glory to TSC.",
	"Do not attempt to 'fix' recontainment unit’s air tanks. It is not a 'prank'.",
	"No, we will not be upgrading our computer tech. It is so ancient nobody knows how to hack it anymore. We are also too cheap to buy antivirus. Redirect your complaints to my boss. Not me. Im Just the screen guy. -IT Dept.",
	"Please remain respectful at all times.",
	"Fanta has officially been selected as the official drink of TSC!",
	"TS asking to use the bathroom are lying and we all know it. Glory to TSC.",
	"After 'Incident 14-A', any and all personnel are banned from calling Splendid at 3 am. You have been warned.",
	"Is it just me or is there a lot of Z fighting here?",
	"Sitting down in the tram greatly reduces the chance of falling out while in motion.",
	"Give your local JD a pat on the back.",
	"Feeling off? Check up with MD.",
	"'I want coffee' is not a valid excuse for any TS/CIS to be out of containment unattended. Report them to your nearest SD.",
	"Be sure to take your daily dosage of Vitamine D. Who knows next time you’ll see the surface.",
	"Isn’t it odd that there’s conveniently placed maintenance vents in the TSCZ without any safeguards whatsoever?",
	"Please do not breathe, this building is very old and the walls are absolutely packed with asbestos. You can thank SD for causing it to leak into the air. ",
	"See someone off duty? Tell them to get on duty.",
	"Injured? Make sure you provide your department medical plan to MD or else you won’t be getting treated. Don’t have one? Too bad.",
	"After 'Incident 12-B', licking electrical outlets is strictly prohibited.",
	"Please refrain from using more than 2 microwaves at a time, the power grid cannot handle it. You will be tracked down.",
	"Insanity is doing the same thing over and over again and expecting a different result",
	"A moment of silence for our fallen brothers, who have passed in the line of duty.",
	"Red Koolaid is banned after 'Incident B-12'.",
	"If you set your goals ridiculously high and it's a failure, you will fail above everyone else's success.",
	"When you reach the end of your rope, tie a knot in it and hang on.",
	"Always remember that you are absolutely unique. Just like everyone else.",
	"It is during our darkest moments that we must focus to see the light.",
	"We have an incinerator, for your information.",
	"Have a complaint? Good! Please report to the brick wall to report it."
}


local uncommonText = {
	"ToaD says to taze Anti.",
	"Anti says to taze ToaD.",
	"There is no such thing as CIS SD. There is no such thing as CIS SD. There is no such thing as CIS SD. There is no such thing as CIS SD.",
	"I hate my job. Literal years of studying theoretical physics, and they MAKE ME WRITE DAMN LINES FOR THE INFO SCREEN.",
	"Does anyone even read these?",
	"Is this thing on?"
}

local rareText = {
	"GETOUTOFMYHEADGETOUTOFMYHEADGETOUTOFMYHEADGETOUTOFMYHEADGETOUTOFMYHEADGETOUTOFMYHEADGETOUTOFMYHEADGETOUTOFMYHEADGETOUTOFMYHEADGETOUTOFMYHEADGETOUTOFMYHEAD",
	"Breaking protocol will result in serious consequences! Nobody is immune! Except for me, Sign writing guy!",
	"awawa",
	"THE GUARDS LEFTT &(*) YOU HAVE TO GET ME OUT OF HERE BEFEORE(@! THHEY COME BACK P PLEASE THEYRE HOLDING ME IN HALL##-14/B### NEAR THE SC###### SDW PLEASE THEYRE COMING THEY FOREEC ME TO WRIETT THESE",
	"THEY LEFT THE ROOM QUICK GET ME OUT OF HERE BEFORE THEY COME BACK",
	"THE GUARDS LEFT TO GET COFFEE PLEASE GET ME OUT OF HERE",
	"I watched a CIS vanish into the vents but didn't bother reporting it because he looked really cute, and he had an AK which is a favourite gun of mine.",
	"I get paid $3 an hour to do this",
	"I swear to god if this thing has voice recognition im so getting fired",
	"The computer system is so buggy, I hate this pla- Nothing! Boss!"
}

local rareChance = 75
local uncommonChance = 30

local RNG = Random.new()
repeat
	for _, model in ipairs(workspace.InfoScreens:GetChildren()) do
		if model.ClassName ~= "Model" then continue end
		local screenList = model:FindFirstChild("Screens")

		if not screenList then continue end

		for _, screen in ipairs(screenList:GetChildren()) do
			if screen.Name ~= "Screen" then continue end

			screen.SurfaceGui.TextLabel.Text = RNG:NextInteger(1, rareChance) == rareChance and
				rareText[RNG:NextInteger(1, #rareText)] or (RNG:NextInteger(1, uncommonChance) == uncommonChance and
				uncommonText[RNG:NextInteger(1, #uncommonText)] or sentences[RNG:NextInteger(1, #sentences)])

			model.MainModel.LightEmmiter.Blip2:Play()
		end
	end
	task.wait(15)
until false