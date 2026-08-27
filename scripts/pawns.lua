local mod = mod_loader.mods[modApi.currentMod]
local imageOffset = modApi:getPaletteImageOffset(mod.id)

Pawn_MD_Mech_Buzzsaw = Pawn:new {
    Name = "Buzzsaw Mech",
    Class = "Brute",
    Health = 2,
    MoveSpeed = 4,
    Image = "md_mech_buzzsaw",
    ImageOffset = imageOffset,
	SkillList = { "Weapon_MD_Brute_Buzzsaw", "Pass_MD_Generic_Explode" },
	SoundLocation = "/mech/brute/tank/",
    DefaultTeam = TEAM_PLAYER,
    ImpactMaterial = IMPACT_METAL,
    Massive = true
}

Pawn_MD_Mech_Burner = Pawn:new {
    Name = "Burner Mech",
    Class = "Brute",
    Health = 3,
    MoveSpeed = 3,
    Image = "md_mech_burner",
    ImageOffset = imageOffset,
	SkillList = { "Weap_MD_Brute_Fire" },
	SoundLocation = "/mech/brute/tank/",
    DefaultTeam = TEAM_PLAYER,
    ImpactMaterial = IMPACT_METAL,
    Massive = true
}

Pawn_MD_Mech_Inkvine = Pawn:new {
    Name = "Inkvine Mech",
    Class = "Ranged",
    Health = 3,
    MoveSpeed = 3,
    Image = "md_mech_inkvine",
    ImageOffset = imageOffset,
	SkillList = { "Weap_MD_Ranged_Inkvine" },
	SoundLocation = "/mech/brute/tank/",
    DefaultTeam = TEAM_PLAYER,
    ImpactMaterial = IMPACT_METAL,
    Massive = true
}

-- lemon scented dummy wall
MD_Wall = Pawn:new{
	Health = 10,
	Flying = true,
	Neutral = true,
	DefaultTeam = TEAM_NONE,
}