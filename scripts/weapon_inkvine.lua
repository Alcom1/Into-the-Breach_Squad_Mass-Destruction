Weap_MD_Ranged_Inkvine = LineArtillery:new{
    Name = "Inkvine Catapult",
    Description = "Apply A.C.I.D. and push adjacent tiles",
    Class = "Ranged",
	Icon = "weapons/md_weapon_inkvine.png",	
    PowerCost = 0,
	Damage = 0,
	Vent = false,
	Upgrades = 2,
	UpgradeList = { "Vent Excess", "Double Shot" },
	UpgradeCost = { 1 , 3 },
	UpShot = "effects/shotup_ant2.png",
	LaunchSound = "/weapons/acid_shot",
	ImpactSound = "/impact/generic/acid_canister",
	TipImage = {
		Unit = 		Point(2,4),
		Enemy = 	Point(2,2),
		Enemy2 = 	Point(3,2),
		Enemy3 = 	Point(2,1),
		Target = 	Point(2,2),
		Mountain = 	Point(2,3)
	}
}

Weap_MD_Ranged_Inkvine_A = Weap_MD_Ranged_Inkvine:new{
    UpgradeDescription = "Apply A.C.I.D. to the left and right before firing.",
	Vent = true,
	TipImage = {
		Unit = 		Point(2,3),
		Enemy = 	Point(2,1),
		Target = 	Point(2,1),
		Mountain =	Point(2,2)
	}
}

Weap_MD_Ranged_Inkvine_B = Weap_MD_Ranged_Inkvine:new{
    UpgradeDescription = "Fire up to two shots in one direction.",
    TwoClick = true,
	TipImage = {
        Unit = 			Point(1, 1),

        Enemy = 		Point(3, 1),
        Enemy2 = 		Point(1, 3),

        Enemy3 = 		Point(3, 2),
        Enemy4 = 		Point(2, 3),
		
        Target = 		Point(3, 1),
        Second_Click = 	Point(1, 3)
    }
}

Weap_MD_Ranged_Inkvine_AB = Weap_MD_Ranged_Inkvine:new{
	Vent = true,
    TwoClick = true,
	TipImage = {
        Unit = 			Point(1, 1),

        Enemy = 		Point(3, 1),
        Enemy2 = 		Point(1, 3),

        Enemy3 = 		Point(3, 2),
        Enemy4 = 		Point(2, 3),
		
        Target = 		Point(3, 1),
        Second_Click = 	Point(1, 3)
    }
}

function Weap_MD_Ranged_Inkvine:GetSecondTargetArea(p1, p2)

    local ret = PointList()
	local prevDir = GetDirection(p2 - p1)

    for j = DIR_START, DIR_END do                           --For each direction

		if prevDir ~= j then
			for i = 2, INT_MAX do                            	--For each tile in a line
				local point = p1 + DIR_VECTORS[j] * i
				if not Board:IsValid(point) then                --Break when we leave the board
					break
				end

				ret:push_back(point)
			end
		end
    end

    return ret
end

function MD_ArtilleryVent(self, skill, p1, p2)

	if self.Vent then
		local damage = SpaceDamage(p1 + DIR_VECTORS[GetDirection(p1 - p2)])
		damage.iAcid = 1
		damage.sAnimation = "ExploAcid1"
		skill:AddDamage(damage)
	end
end

function MD_ArtilleryAcid(self, skill, p1, p2, delay)

	local damage = SpaceDamage(p2, self.Damage)
	damage.iAcid = 1
	damage.sAnimation = "ExploAcid1"
	if delay ~= nil then
		skill:AddArtillery(damage, self.UpShot, delay)
	else
		skill:AddArtillery(damage, self.UpShot)
	end
end

function MD_ArtilleryPush(self, skill, p1, p2)

	skill:AddBounce(p2, 1)
	
	for dir = DIR_START, DIR_END do
		local damagePush = SpaceDamage(p2 + DIR_VECTORS[dir], 0)
		damagePush.iPush = dir
		damagePush.sAnimation = "airpush_"..dir
		skill:AddDamage(damagePush)
	end
end

function Weap_MD_Ranged_Inkvine:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	MD_ArtilleryVent(self, ret, p1, p2)
	ret:AddBounce(p1, 1)
	MD_ArtilleryAcid(self, ret, p1, p2)
	MD_ArtilleryPush(self, ret, p1, p2)
	
	return ret
end

function Weap_MD_Ranged_Inkvine:GetFinalEffect(p1, p2, p3)
	local ret = SkillEffect()

	MD_ArtilleryVent(self, ret, p1, p2)
	MD_ArtilleryVent(self, ret, p1, p3)

	ret:AddBounce(p1, 1)

	MD_ArtilleryAcid(self, ret, p1, p2, NO_DELAY)
	MD_ArtilleryAcid(self, ret, p1, p3)

	MD_ArtilleryPush(self, ret, p1, p2)
	MD_ArtilleryPush(self, ret, p1, p3)
	
	return ret
end