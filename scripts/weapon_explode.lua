Pass_MD_Generic_Explode = PassiveSkill:new{
    Name = "Explosive A.C.I.D.",
    Description = "Units affected by both acid and fire will explode with instant death!",
	Icon = "weapons/brute_bombrun.png",
    Damage = 0,
    Passive = "md_Passive_FireAcidBoom",
    PowerCost = 0,
    Upgrades = 0,
    TipImage = {
        Unit = Point(2, 1),
        Enemy = Point(1, 2),
        Enemy2 = Point(2, 2),
        Enemy3 = Point(3, 2)
    }
}