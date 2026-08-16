Weapon_MD_Prime_Buzzsaw = Skill:new{
    Name = "Central Buzzsaw",
    Description = "Charge forward, dealing damage and spreading A.C.I.D. and fire.",
    Class = "Prime",
	Icon = "advanced/weapons/Science_KO_Crack.png",
    Damage = 1,
    Harvest = false,
    PowerCost = 0,
    Upgrades = 2,
    UpgradeCost = { 2, 2 },
    UpgradeList = { "Harvest", "+1 Damage" },
    DamageSound = "/mech/distance/artillery/death",
    TipImage = {
        Unit = Point(2, 4),
		Fire1 = Point(2, 3),
        Enemy = Point(2, 2),
        Enemy2 = Point(2, 1),
        Target = Point(2, 0)
    }
}

--Ally Immune upgrade
Weapon_MD_Prime_Buzzsaw_A = Weapon_MD_Prime_Buzzsaw:new{
    UpgradeDescription = "Gather A.C.I.D and fire from adjacent tiles before moving.",
    Harvest = true
}

--Damage ramp upgrade
Weapon_MD_Prime_Buzzsaw_B = Weapon_MD_Prime_Buzzsaw:new{
    UpgradeDescription = "Increases damage by 1.",
	Damage = 2
}

--Both upgrades combined
Weapon_MD_Prime_Buzzsaw_AB = Weapon_MD_Prime_Buzzsaw:new{
    Harvest = true,
	Damage = 2
}	

--Target Area for pass-through
function Weapon_MD_Prime_Buzzsaw:GetTargetArea(p1)
    local ret = PointList()
    for i = DIR_START, DIR_END do                           --For each direction
        for k = 1, INT_MAX do                               --For each tile in a line
            local point = p1 + DIR_VECTORS[i] * k
            if not Board:IsValid(point) then                --Break when we leave the board
                break
            end

            if not Board:IsBlocked(point, PATH_FLYER) then  --Point is valid if it can be flown to, if it is empty
                ret:push_back(point)
            end
        end
    end

    return ret
end

--Skill Effect for charge, damage, pull, and upgrades
function Weapon_MD_Prime_Buzzsaw:GetSkillEffect(p1, p2)
    local ret = SkillEffect()
    local damagePoints = p1:MD_Bresenham(p2, 1, 1)              --Points from here to there
    local selfPawn = Board:GetPawn(p1)

    local isFire = selfPawn:IsFire() or Board:IsFire(p1)
    local isAcid = selfPawn:IsAcid() or Board:IsAcid(p1)

    if self.Harvest then
        for dir = DIR_START, DIR_END do

            local harvestPoint = p1 + DIR_VECTORS[dir]

            if dir ~= GetDirection(p2 - p1) then

                if Board:IsFire(harvestPoint) then
                    isFire = true
                end

                if Board:IsAcid(harvestPoint) then
                    isAcid = true
                end
            end
        end
    end
    
    ret:AddSound(self.DamageSound)                              --Initial Saw Sound
    ret:AddCharge(Board:GetPath(p1, p2, PATH_FLYER), NO_DELAY)  --Charge!

    for i, point in ipairs(damagePoints) do

        local damage = SpaceDamage(point, self.Damage)          --Damage
        damage.sSound = self.DamageSound

        if Board:IsFire(point) then
            isFire = true
        end

        if Board:IsAcid(point) then
            isAcid = true
        end

        damage.iFire = isFire and 1 or 0
        damage.iAcid = isAcid and 1 or 0

        ret:AddDamage(damage)                                   --Damage
        ret:AddBounce(point, 1)                                 --Bounce
        
        ret:AddDelay(0.1)                                       --Delay effects as we travel
    end

    return ret
end