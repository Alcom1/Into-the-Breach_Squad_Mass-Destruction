Weap_MD_Ranged_Inkvine = LineArtillery:new{
    Name = "Inkvine Catapult",
    Description = "Apply A.C.I.D. and push adjacent tiles",
    Class = "Ranged",
	Icon = "weapons/vek_scarab.png",	
    PowerCost = 0,
	Damage = 0,
    BigSplash = false,
	Upgrades = 2,
	UpgradeList = { "Big Splash",  "+2 Damage"  },
	UpgradeCost = { 2 , 3 },
	UpShot = "effects/shotup_ant1.png",
	LaunchSound = "/enemy/scarab_1/attack",
	ImpactSound = "/impact/generic/explosion",
	TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,2),
		Enemy2 = Point(3,2),
		Enemy3 = Point(2,1),
		Target = Point(2,2),
		Mountain = Point(2,3)
	}
}

Weap_MD_Ranged_Inkvine_A = Weap_MD_Ranged_Inkvine:new{
    UpgradeDescription = "Adjacent tiles also receive A.C.I.D.",
    BigSplash = true
}

Weap_MD_Ranged_Inkvine_B = Weap_MD_Ranged_Inkvine:new{
    UpgradeDescription = "Increases center hit damage by 2.",
	Damage = 2
}

Weap_MD_Ranged_Inkvine_AB = Weap_MD_Ranged_Inkvine:new{
    BigSplash = true,
	Damage = 2,
}

function Weap_MD_Ranged_Inkvine:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p1 - p2)
	
	ret:AddBounce(p1, 1)
	
	local damage = SpaceDamage(p2, self.Damage)
	damage.sAnimation = "ExploArt1"
	damage.iAcid = 1
	ret:AddArtillery(damage, self.UpShot)
	
	for dir = DIR_START, DIR_END do

		damage = SpaceDamage(p2 + DIR_VECTORS[dir], 0)
		damage.iPush = dir

        if BigSplash then
            damage.iAcid = 1
        end

		damage.sAnimation = "airpush_"..dir
		ret:AddDamage(damage)

	end

	ret:AddBounce(p2, 1)
	
	return ret
end