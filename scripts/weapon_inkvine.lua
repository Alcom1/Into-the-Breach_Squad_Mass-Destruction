Weap_MD_Ranged_Inkvine = LineArtillery:new{
    Name = "Inkvine Catapult",
    Description = "Apply A.C.I.D. and push adjacent tiles",
    Class = "Ranged",
	Icon = "weapons/vek_scarab.png",	
    PowerCost = 0,
	Damage = 0,
	Vent = false,
    BigSplash = false,
	Upgrades = 2,
	UpgradeList = { "Vent Excess", "Big Splash" },
	UpgradeCost = { 2 , 2 },
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
    UpgradeDescription = "Apply A.C.I.D. to the left and right before firing.",
	Vent = true
}

Weap_MD_Ranged_Inkvine_B = Weap_MD_Ranged_Inkvine:new{
    UpgradeDescription = "Adjacent tiles also receive A.C.I.D.",
    BigSplash = true
}

Weap_MD_Ranged_Inkvine_AB = Weap_MD_Ranged_Inkvine:new{
	Vent = true,
    BigSplash = true
}

function Weap_MD_Ranged_Inkvine:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	
	if self.Vent then
		for j = -1, 1, 2 do
			local curr = p1 + DIR_VECTORS[(GetDirection((p2 - p1) * j) + 1) % 4]

			local damageVent = SpaceDamage(curr, 0)
			damageVent.iAcid = 1
			damageVent.sAnimation = "ExploAcid1"
			ret:AddDamage(damageVent)
		end   
	end

	ret:AddBounce(p1, 1)
	local damageMain = SpaceDamage(p2, self.Damage)
	damageMain.sAnimation = "ExploArt1"
	damageMain.iAcid = 1
	damageMain.sAnimation = "ExploAcid1"
	ret:AddArtillery(damageMain, self.UpShot)
	
	for dir = DIR_START, DIR_END do

		local damagePush = SpaceDamage(p2 + DIR_VECTORS[dir], 0)
		damagePush.iPush = dir

        if self.BigSplash then
            damagePush.iAcid = 1
        end

		damagePush.sAnimation = "airpush_"..dir
		ret:AddDamage(damagePush)

	end

	ret:AddBounce(p2, 1)
	
	return ret
end