--Mod
local mod = {
    id = "squad_mass_destruction",
    name = "Mass Destruction",
    version = "0.10",
    icon = "img/units/player/mech_tank_ns.png",
    icon_squad = "img/units/player/mech_tank_ns.png",
    requirements = {},
	dependencies = {
        memedit = "1.0.4",
        modApiExt = "1.2"
    }
}

--Initialize mod
function mod:init()

    modApi:appendMechAssets("img/units/player", "md_")
    modApi:appendWeaponAssets("img/weapons",    "md_")
    modApi:appendCombatAssets("img/combat",     "md_")

    --mech sprites
    local mechSprites = {
        md_mech_buzzsaw =           { PosX = -17, PosY =  0 },
        md_mech_buzzsaw_ns =        { },
        md_mech_buzzsaw_a =         { PosX = -17, PosY =  0, NumFrames = 8, Time = 0.20  },
        md_mech_buzzsaw_broken =    { PosX = -17, PosY =  0 },
        md_mech_buzzsaw_w =         { PosX = -20, PosY =  9 },
        md_mech_buzzsaw_w_broken =  { PosX = -17, PosY =  0 },

        md_mech_burner =            { PosX = -18, PosY =  3 },
        md_mech_burner_ns =         { },
        md_mech_burner_a =          { PosX = -18, PosY =  3, NumFrames = 4 },
        md_mech_burner_broken =     { PosX = -18, PosY =  3 },
        md_mech_burner_w =          { PosX = -18, PosY = 11 },
        md_mech_burner_w_broken =   { PosX = -18, PosY =  3 },

        md_mech_inkvine =           { PosX = -18, PosY = -2 },
        md_mech_inkvine_ns =        { },
        md_mech_inkvine_a =         { PosX = -18, PosY = -2, NumFrames = 8 },
        md_mech_inkvine_broken =    { PosX = -18, PosY = -2 },
        md_mech_inkvine_w =         { PosX = -21, PosY =  8 },
        md_mech_inkvine_w_broken =  { PosX = -18, PosY = -2 },
    }

    --Mapping file names for mech sprites
    local tagmaps = {
        {"_ns",         "_ns"},
        {"_a",          "a"},
        {"_broken",     "_broken"},
        {"_w",          "w"},
        {"_w_broken",   "w_broken"},
        {"_death",      "d"}
    }

    local animDefs = {}

    for id, mechSprite in pairs(mechSprites) do
        mechSprite.Image = "units/player/"..id..".png"

        for _, map in ipairs(tagmaps) do
            id = id:gsub(map[1].."$", map[2])
        end
        
        animDefs[id] = mechSprite
    end

    modApi:createMechAnimations(animDefs)

    --Color palette
    modApi:addPalette{
        id = mod.id,
        name = "Harkonnen Metal",
        image = "img/units/player/mech_tank_ns.png",
        colorMap = {
            
            lights =         { 241, 240, 240 },

            main_highlight = { 120,  24,  36 },
            main_light =     {  74,  15,  22 },
            main_mid =       {  38,  18,  11 },
            main_dark =      {  22,   4,   6 },

            metal_light =    { 122, 136, 146 },
            metal_mid =      {  55,  60,  61 },
            metal_dark =     {  37,  29,  21 },
        },
    }

    --Misc sprite assets
    local generalSprites = {
        {"img/weapons/md_weapon_buzzsaw.png",   "img/weapons/weapon_buzzsaw.png"},
        {"img/weapons/md_weapon_explode.png",   "img/weapons/weapon_explode.png"},
        {"img/weapons/md_weapon_fire.png",      "img/weapons/weapon_fire.png"},
        {"img/weapons/md_weapon_inkvine.png",   "img/weapons/weapon_inkvine.png"},

        --Icons for when a tile will be damaged with both fire and acid simultaneously
        {"img/combat/md_icon_acid.png",         "img/combat/icon_acid_copy.png"},
        {"img/combat/md_icon_acid_fire.png",    "img/combat/icon_acid_fire.png"},

        --Icons for when a tile will be flipped, but also get either acid or fire
        {"img/combat/md_icon_acid_flip.png",         "img/combat/icon_acid_flip.png"},
        {"img/combat/md_icon_fire_flip.png",         "img/combat/icon_fire_flip.png"},

        --Inkvine has an edgecase where two vek can collide in one of four cardinal directions
        {"img/combat/md_collision_hit_0.png",   "img/combat/collision_hit_new.png"},
        {"img/combat/md_collision_hit_1.png",   "img/combat/collision_hit_new.png"},
        {"img/combat/md_collision_hit_2.png",   "img/combat/collision_hit_new.png"},
        {"img/combat/md_collision_hit_3.png",   "img/combat/collision_hit_new.png"},
    }

    for _, generalSprite in ipairs(generalSprites) do
        modApi:appendAsset(generalSprite[1], self.resourcePath..generalSprite[2])
    end

    Location["combat/md_icon_acid.png"] =       Point(-13, -2)
    Location["combat/md_icon_acid_fire.png"] =  Point(-27,  9)
    
    Location["combat/md_icon_acid_flip.png"] =  Point(-22, 9)
    Location["combat/md_icon_fire_flip.png"] =  Point(-22, 9)

    local col_offset = Point(-17, 6)

    --Using DIR_VECTORS for cardinal directions
    for i = DIR_START, DIR_END do

        --North and West : Place sprite at p1 and offset it based on DIR.
        if i == 0 or i == 3 then
            Location["combat/md_collision_hit_"..i..".png"] = 
                col_offset + 
                Point(
                    28 * 4 * DIR_VECTORS[i].x,
                    21 * 4 * DIR_VECTORS[i].y)
        end
        --East : Place sprite south-east of P1 and offset it north
        if i == 1 then
            Location["combat/md_collision_hit_"..i..".png"] = col_offset + Point(56, -42)
        end
        --South : Place sprite south of P1 and do not offset it
        if i == 2 then
            Location["combat/md_collision_hit_"..i..".png"] = col_offset
        end
    end

    --Scripts
    local scripts = {
        "pawns",
        "point",
        "terrain",
        "weapon_buzzsaw",
        "weapon_explode",
        "weapon_fire",
        "weapon_inkvine"
    }
    
    self.passive = require(self.scriptPath.."passive")
    self.passive:init()

    for _, script in ipairs(scripts) do
        require(self.scriptPath..script)
    end

end

--Load mod
function mod:load(options, version)

    --Load initialized scripts
    self.passive:load()

    --Squad
    local squadMechs = {
        "Mass Destruction",
        "Pawn_MD_Mech_Buzzsaw",
        "Pawn_MD_Mech_Burner",
        "Pawn_MD_Mech_Inkvine",
    }

    squadMechs.id = "md_massdestruction"
    modApi:addSquadTrue(
        squadMechs, 
        "Mass Destruction",
        "Ruthless mechs that combine A.C.I.D. and fire into a deadly explosive combination.",
        self.resourcePath..self.icon_squad)

end

return mod