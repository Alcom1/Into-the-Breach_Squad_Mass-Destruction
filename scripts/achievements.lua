local MD_TOWER_TARGET = 4
local MD_SPLODE_TARGET = 4

local mod = modApi:getCurrentMod()
local modApiExt = modapiext

local SQUAD_MASS_DESTRUCTION = "md_massdestruction"

--If this is a real mission, and not a fake mission, because it's not a test mission or whatever
local function isRealMission()
    local mission = GetCurrentMission()

    return true
		and mission ~= nil
		and mission ~= Mission_Test
		and Board
		and Board:IsMissionBoard()
end

--Achievement 1
local ach_md_spread = modApi.achievements:addExt{
	--Required
	id = "md_ach1",
	name = "Special Delivery",
	image = mod.resourcePath.."img/achievements/ach_1.png",

	--Optional
	tooltip = "Use the buzzsaw to spread both A.C.I.D. and fire to the same enemy.",
	squad = SQUAD_MASS_DESTRUCTION,
}

--Achievement 2
local ach_md_splode = modApi.achievements:addExt{
	--Required
	id = "md_ach2",
	name = "Chemical Warfare",
	image = mod.resourcePath.."img/achievements/ach_2.png",

	--Optional
	tooltip = "Use explosive A.C.I.D. to kill at least 4 enemies in a single turn.",
	squad = SQUAD_MASS_DESTRUCTION,
}

--Achievement 3
local ach_md_anticap = modApi.achievements:addExt{
	--Required
	id = "md_ach3",
	name = "Anticapitalist",
	image = mod.resourcePath.."img/achievements/ach_3.png",

	--Optional
	tooltip = "Set 4 corporate towers on fire in a single game.",
	squad = SQUAD_MASS_DESTRUCTION,
}
