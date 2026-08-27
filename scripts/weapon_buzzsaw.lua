Weapon_MD_Brute_Buzzsaw = Skill:new{
    Name = "Giant Buzzsaw",
    Description = "Saw through a tile, dealing damage and confusing enemies.",
    Class = "Brute",
	Icon = "weapons/md_weapon_buzzsaw.png",
    Damage = 1,
    Range = 2,
    Chaos = false,
    PowerCost = 0,
    Upgrades = 2,
    UpgradeCost = { 2, 2 },
    UpgradeList = { "Unlimited Range", "Spread Chaos" },
    DamageSound = "/mech/distance/artillery/death",
    TipImage = {
        Unit = Point(2, 3),
        Enemy = Point(2, 2),
        Target = Point(2, 1),
		CustomEnemy = "Firefly2"
    }
}

Weapon_MD_Brute_Buzzsaw_A = Weapon_MD_Brute_Buzzsaw:new{
    UpgradeDescription = "Saw range is unlimited.",
    Range = INT_MAX,
    TipImage = {
        Unit = Point(2, 4),
        Enemy = Point(2, 3),
        Enemy2 = Point(2, 2),
        Enemy3 = Point(2, 1),
        Target = Point(2, 0),
		CustomEnemy = "Firefly2",
    }
}

Weapon_MD_Brute_Buzzsaw_B = Weapon_MD_Brute_Buzzsaw:new{
    UpgradeDescription = "Spread A.C.I.D. or Fire as you travel.",
    Chaos = true,
    TipImage = {
        Unit = Point(2, 3),
        Enemy = Point(2, 2),
        Target = Point(2, 1),
		CustomEnemy = "Firefly2",
        Fire1 = Point(2, 3)
    }
}

Weapon_MD_Brute_Buzzsaw_AB = Weapon_MD_Brute_Buzzsaw:new{
    Range = INT_MAX,
    Chaos = true,
    TipImage = {
        Unit = Point(2, 4),
        Enemy = Point(2, 3),
        Enemy2 = Point(2, 2),
        Enemy3 = Point(2, 1),
        Target = Point(2, 0),
		CustomEnemy = "Firefly2",
        Fire1 = Point(2, 3)
    }
}	

function Weapon_MD_Brute_Buzzsaw:GetTargetArea(p1)
    local ret = PointList()
    for j = DIR_START, DIR_END do                                       --For each direction
        for i = 2, self.Range do                                        --For each tile in a line
            local point = p1 + DIR_VECTORS[j] * i
            if not Board:IsValid(point) or MD_IsMountain(point) then    --Break when we leave the board or hit a mountain
                break
            end

            if not Board:IsBlocked(point, PATH_FLYER) then  --Point is valid if it can be flown to, if it is empty
                ret:push_back(point)
            end
        end
    end

    return ret
end

function Weapon_MD_Brute_Buzzsaw:GetSkillEffect(p1, p2)
    local ret = SkillEffect()

    --Tip image...
    if Board:IsTipImage() then
        Board:GetPawn(Point(2, 2)):FireWeapon(Point(3, 2), 1)

        damage = SpaceDamage(0)
        damage.fDelay = 1
        ret:AddDamage(damage)
    end

    local damagePoints = p1:MD_Bresenham(p2, 1, 1)                  --Points from here to there
    local selfPawn = Board:GetPawn(p1)                              --Pawn firing
    
    ret:AddSound(self.DamageSound)                                  --Initial Saw Sound
    ret:AddCharge(Board:GetPath(p1, p2, PATH_FLYER), NO_DELAY)      --Charge!

    --Initial acid/fire statuses for chaos
    local isFire = selfPawn:IsFire() or Board:IsFire(p1)
    local isAcid = selfPawn:IsAcid() or Board:IsAcid(p1)

    for i, point in ipairs(damagePoints) do

        --Check for more fire or acid
        local target = Board:GetPawn(point)

        --Damage flips targets
        local damage = SpaceDamage(point, self.Damage, target ~= nil and DIR_FLIP or DIR_NONE)
        damage.sSound = self.DamageSound

        --If chaos upgrade, spread acid/fire
        if self.Chaos then
            damage.iFire = isFire and 1 or 0
            damage.iAcid = (isAcid and (target ~= nil or not isFire)) and 1 or 0

            if isFire and isAcid then
                if target ~= nil then
                    damage.sImageMark = "combat/md_icon_acid_fire.png"
                else
                    damage.sImageMark = "combat/md_icon_acid.png"
                end
            end
        end

        isFire = isFire or Board:IsFire(point) or (target ~= nil and target:IsFire())
        isAcid = isAcid or Board:IsAcid(point) or (target ~= nil and target:IsAcid())

        ret:AddDamage(damage)                                       --Damage
        ret:AddBounce(point, 2)                                     --Bounce
        
        ret:AddDelay(0.1)                                           --Delay effects as we travel
    end

    return ret
end