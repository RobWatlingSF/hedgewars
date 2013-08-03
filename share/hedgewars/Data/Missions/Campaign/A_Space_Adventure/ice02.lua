------------------- ABOUT ----------------------
--
-- Hero has to pass as fast as possible inside the
-- rings as in the racer mode

HedgewarsScriptLoad("/Scripts/Locale.lua")
HedgewarsScriptLoad("/Scripts/Animate.lua")

----------------- VARIABLES --------------------
-- globals
local campaignName = loc("A Space Adventure")
local missionName = loc("Ice planet, A Saucer Race!")
local challengeStarted = false
local currentWaypoint = 1
local radius = 75
-- dialogs
local dialog01 = {}
-- mission objectives
local goals = {
	[dialog01] = {missionName, loc("Getting ready"), loc("Use your saucer and pass from the rings!"), 1, 4500},
}
-- hogs
local hero = {}
local ally = {}
-- teams
local teamA = {}
local teamB = {}
-- hedgehogs values
hero.name = "Hog Solo"
hero.x = 750
hero.y = 130
hero.dead = false
ally.name = "Paul McHoggy"
ally.x = 860
ally.y = 130
teamA.name = loc("Hog Solo")
teamA.color = tonumber("38D61C",16) -- green
teamB.name = loc("Allies")
teamB.color = tonumber("FF0000",16) -- red
-- way points
local current waypoint = 1
local waypoints = { 
	[1] = {x=1450, y=140},
	[2] = {x=990, y=580},
	[3] = {x=1650, y=950},
	[4] = {x=620, y=630},
	[5] = {x=1470, y=540},
	[6] = {x=1960, y=60},
	[7] = {x=1600, y=400},
	[8] = {x=240, y=940},
	[9] = {x=200, y=530},
	[10] = {x=1180, y=120},
	[11] = {x=1950, y=660},
	[12] = {x=1280, y=980},
	[13] = {x=590, y=1100},
	[14] = {x=20, y=620},
	[15] = {x=hero.x, y=hero.y}
}

-------------- LuaAPI EVENT HANDLERS ------------------

function onGameInit()
	GameFlags = gfInvulnerable
	Seed = 1
	TurnTime = 15000
	CaseFreq = 0
	MinesNum = 0
	MinesTime = 1
	Explosives = 0
	Map = "ice02_map"
	Theme = "Snow"
	
	-- Hog Solo
	AddTeam(teamA.name, teamA.color, "Bone", "Island", "HillBilly", "cm_birdy")
	hero.gear = AddHog(hero.name, 0, 100, "war_desertgrenadier1")
	AnimSetGearPosition(hero.gear, hero.x, hero.y)
	-- Ally
	AddTeam(teamB.name, teamB.color, "Bone", "Island", "HillBilly", "cm_birdy")
	ally.gear = AddHog(ally.name, 0, 100, "tophats")
	AnimSetGearPosition(ally.gear, ally.x, ally.y)
	HogTurnLeft(ally.gear, true)
	
	AnimInit()
	AnimationSetup()	
end

function onGameStart()
	AnimWait(hero.gear, 3000)
	FollowGear(hero.gear)
	
	AddEvent(onHeroDeath, {hero.gear}, heroDeath, {hero.gear}, 0)
	
	AddAmmo(hero.gear, amJetpack, 2)
	
	-- place a waypoint
	placeNextWaypoint()
	
	SendHealthStatsOff()
	AddAnim(dialog01)
end

function onNewTurn()
	if not hero.dead and CurrentHedgehog == ally.gear and challengeStarted then
		heroLost()
	end
end

function onGameTick()
	AnimUnWait()
	if ShowAnimation() == false then
		return
	end
	ExecuteAfterAnimations()
	CheckEvents()
end

function onGameTick20()
	if checkIfHeroInWaypoint() then
		if not placeNextWaypoint() then
			-- GAME OVER, WIN!
			EndGame()
		end
	end
end

function onGearDelete(gear)
	if gear == hero.gear then
		hero.dead = true
	end
end

function onPrecise()
	if GameTime > 3000 then
		SetAnimSkip(true)   
	end
end

-------------- EVENTS ------------------

function onHeroDeath(gear)
	if hero.dead then
		return true
	end
	return false
end

-------------- OUTCOMES ------------------

function heroDeath(gear)
	heroLost()
end

-------------- ANIMATIONS ------------------

function Skipanim(anim)
	if goals[anim] ~= nil then
		ShowMission(unpack(goals[anim]))
    end
    startFlying()
end

function AnimationSetup()
	-- DIALOG 01 - Start, some story telling
	AddSkipFunction(dialog01, Skipanim, {dialog01})
	table.insert(dialog01, {func = AnimWait, args = {hero.gear, 3000}})
	table.insert(dialog01, {func = AnimCaption, args = {hero.gear, loc("In the ice planet flying saucer stadium..."), 5000}})
	table.insert(dialog01, {func = AnimSay, args = {ally.gear, loc("This is the olympic stadium of saucer flying..."), SAY_SAY, 4000}})
	table.insert(dialog01, {func = AnimSay, args = {ally.gear, loc("All the saucer pilots dream one day to come here and compete with the best!"), SAY_SAY, 5000}})
	table.insert(dialog01, {func = AnimSay, args = {ally.gear, loc("Now you have the chance to try and get the place that you deserve between the best..."), SAY_SAY, 6000}})
	table.insert(dialog01, {func = AnimCaption, args = {hero.gear, loc("Use the saucer and pass from the rings..."), 5000}})
	table.insert(dialog01, {func = AnimSay, args = {ally.gear, loc("... can you do it?"), SAY_SAY, 2000}})
	table.insert(dialog01, {func = AnimWait, args = {hero.gear, 500}})
	table.insert(dialog01, {func = startFlying, args = {hero.gear}})	
end

------------------ Other Functions -------------------

function startFlying()
	AnimSwitchHog(ally.gear)
	TurnTimeLeft = 0
	challengeStarted = true
end

function placeNextWaypoint()
	if currentWaypoint > 1 then
		local wp = waypoints[currentWaypoint-1]
		DeleteVisualGear(wp.gear)
	end
	if currentWaypoint < 16 then
		local wp = waypoints[currentWaypoint]
		wp.gear = AddVisualGear(1,1,vgtCircle,1,true)
		SetVisualGearValues(wp.gear, wp.x,wp.y, 20, 200, 0, 0, 100, radius, 3, 0xff0000ff)
		-- add bonus time and "fuel"
		if currentWaypoint % 2 == 0 then
			AddAmmo(hero.gear, amJetpack, GetAmmoCount(hero.gear, amJetpack)+1)
			if TurnTimeLeft <= 20000 then
				TurnTimeLeft = TurnTimeLeft + 8000
			end		
		else
			if TurnTimeLeft <= 14000 then
				TurnTimeLeft = TurnTimeLeft + 6000
			end
		end	
		radius = radius - 4
		currentWaypoint = currentWaypoint + 1
		return true
	end
	return false
end

function checkIfHeroInWaypoint()
	if not hero.dead then
		local wp = waypoints[currentWaypoint-1]
		local distance = math.sqrt((GetX(hero.gear)-wp.x)^2 + (GetY(hero.gear)-wp.y)^2)
		if distance <= radius+4 then
			SetWind(math.random(-100,100))
			return true
		end
	end
	return false
end

function heroLost()
	SendStat('siGameResult', loc("Oh man! Learn how to fly!")) --1
	SendStat('siCustomAchievement', loc("To win the game you have to pass into the rings in time")) --11
	SendStat('siCustomAchievement', loc("You'll get extra time in case you need it when you pass a ring")) --11
	SendStat('siCustomAchievement', loc("Every 2 rings you'll get extra flying saucers")) --11
	SendStat('siCustomAchievement', loc("Use space button twice to change flying saucer while being on air")) --11
	SendStat('siCustomAchievement', loc("Pause the game to have a look where is the next ring")) --11
	SendStat('siPlayerKills','0',teamA.name)
	EndGame()
end