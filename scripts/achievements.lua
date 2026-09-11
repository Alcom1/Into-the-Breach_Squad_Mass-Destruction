--Libraries
local mod = modApi:getCurrentMod()
local modApiExt = modapiext
local boardEvents = require(mod.scriptPath .."libs/boardEvents")

--Constants
local SQUAD_MASS_DESTRUCTION = "md_massdestruction"
local MD_SPLODE_TARGET = 8
local MD_TOWER_TARGET = 4

--Save data
local function achievementData()

	local game = GAME or {}	-- GAME may not be initialized in the hangar menu. Use a dummy

	--Establish achievement data
	if game.md_massdestruction == nil then
		game.md_massdestruction = {}
	end

	if game.md_massdestruction.achievementData == nil then
		game.md_massdestruction.achievementData = {}
	end

	--Establish achievement data values
	local gameData = game.md_massdestruction.achievementData

	--Per mission tracker - How many enemies exploded this battle
	if gameData.splode_count == nil then
		gameData.splode_count = 0
	end

	--Per mission tracker - If the corporate tower was burnt this battle
	if gameData.anticap_isburnt == nil then
		gameData.anticap_isburnt = false
	end

	--Per game tracker - How many corporate towers have been burnt
	if gameData.anticap_count == nil then
		gameData.anticap_count = 0
	end

	--Per game tracker - If burning a coporate tower was skipped
	if gameData.anticap_failed == nil then
		gameData.anticap_failed = false
	end

	return gameData
end

--If string indicates a corpo tower
local function isCorpoAsset(str)
	return string.lower(str):find("^str_tower") ~= nil
end

--If this is a real mission, and not a fake mission, because it's not a test mission or whatever
local function isRealMission(mission)
    local mission = mission or GetCurrentMission()

    return true
		and mission ~= nil
		and mission ~= Mission_Test
		and Board
		and Board:IsMissionBoard()
end

--If this mission has a corpo tower
local function isCorpoMission(mission)
	local mission = mission or GetCurrentMission()

	return true
		and mission ~= nil
		and isCorpoAsset(mission.AssetId)
end

--Achievement 1
local ach_md_spread = modApi.achievements:addExt{
	--Required
	id = "md_ach1",
	name = "Special Delivery",
	image = mod.resourcePath.."img/achievements/ach_1.png",

	--Optional
	tooltip = "Use the buzzsaw to spread both A.C.I.D. and fire to an enemy with neither.",
	squad = SQUAD_MASS_DESTRUCTION,
}

--Achievement 2
local ach_md_splode = modApi.achievements:addExt{
	--Required
	id = "md_ach2",
	name = "Chemical Warfare",
	image = mod.resourcePath.."img/achievements/ach_2.png",

	--Optional
	tooltip = "Use explosive A.C.I.D. to kill at least "..MD_SPLODE_TARGET.." enemies in a single battle.",
	squad = SQUAD_MASS_DESTRUCTION,
}

function ach_md_splode:getTextProgress()
	if isRealMission() then
		return achievementData().splode_count.." kills"
	end
end

--Achievement 3
local ach_md_anticap = modApi.achievements:addExt{
	--Required
	id = "md_ach3",
	name = "Anticapitalist",
	image = mod.resourcePath.."img/achievements/ach_3.png",

	--Optional
	tooltip = "Set "..MD_TOWER_TARGET.." corporate towers on fire in a single game.",
	squad = SQUAD_MASS_DESTRUCTION,
}

function ach_md_anticap:getTextProgress()
	local count = achievementData().anticap_count
	local plural = count > 1 and "s" or ""

	return count.." tower"..plural.." burned"
end

function ach_md_anticap:isFailed()
	return achievementData().anticap_failed
end

-- Hooks
--ACH 1 (Not a hook)
function MD_CheckAch1Trigger()
	if isRealMission() then
		ach_md_spread:completeProgress()
	end
end

--ACH 2 (Not a hook)
function MD_CheckAch2Trigger(count)
	if isRealMission() then
		achievementData().splode_count = achievementData().splode_count + count

		if achievementData().splode_count >= MD_SPLODE_TARGET then
			ach_md_splode:completeWithHighscore(achievementData().splode_count)
		end
	end
end

--ACH3 (a hook!!!)
local function ach_md_anticap_onFireCreated(point)
	if isRealMission() and isCorpoMission() and isCorpoAsset(Board:GetUniqueBuilding(point)) then

		--First time corpo building has been burnt this mission. Update the game counter
		if not achievementData().anticap_isburnt then
			achievementData().anticap_count = achievementData().anticap_count + 1
		end

		--Complete progress if all corpo buildings were burnt
		if achievementData().anticap_count >= MD_TOWER_TARGET then
			ach_md_anticap:completeProgress()
		end

		--Mark that corpo building was burnt
		achievementData().anticap_isburnt = true
	end
end

--ACH MISSION END (Also a hook!!!)
local function ach_md_anticap_onMissionEnded(mission)
	if isRealMission(mission) then

		--Corpo building was not burnt. Fail the mission
		if isCorpoMission(mission) and not achievementData().anticap_isburnt then
			achievementData().anticap_failed = true
		end

		--Reset end of mission stuff
		achievementData().splode_count = 0
		achievementData().anticap_isburnt = false
	end		
end

-- Subscribe to events
modApi.events.onSquadEnteredGame:subscribe(function(squadId)
	if squadId == SQUAD_MASS_DESTRUCTION then
		boardEvents.onFireCreated:subscribe(ach_md_anticap_onFireCreated)
		modApi.events.onMissionEnd:subscribe(ach_md_anticap_onMissionEnded)
	end
end)

-- Unsubscribe from events
modApi.events.onSquadExitedGame:subscribe(function(squadId)
	if squadId == SQUAD_MASS_DESTRUCTION then
		--boardEvents.onFireCreated:unsubscribe(ach_md_anticap_onFireCreated) --No unsubscribe? :(
		modApi.events.onMissionEnd:unsubscribe(ach_md_anticap_onMissionEnded)
	end
end)
