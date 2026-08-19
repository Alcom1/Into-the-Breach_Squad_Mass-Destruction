Weapon_MD_Prime_Buzzsaw = Skill:new{
    Name = "Giant Buzzsaw",
    Description = "Attack a unit and spread its A.C.I.D. or fire status ahead.",
    Class = "Prime",
	Icon = "advanced/weapons/Science_KO_Crack.png",
    Damage = 1,
    Vore = false,
    PowerCost = 0,
    Upgrades = 2,
    UpgradeCost = { 2, 2 },
    UpgradeList = { "Voracious", "+1 Damage" },
    DamageSound = "/mech/distance/artillery/death",
    TipImage = {
        Unit = Point(2, 3),
		Fire1 = Point(2, 2),
        Enemy = Point(2, 2),
        Enemy2 = Point(2, 1),
        Target = Point(2, 2)
    }
}

Weapon_MD_Prime_Buzzsaw_A = Weapon_MD_Prime_Buzzsaw:new{
    UpgradeDescription = "Target will be dragged under and behind this unit",
    Vore = true
}

Weapon_MD_Prime_Buzzsaw_B = Weapon_MD_Prime_Buzzsaw:new{
    UpgradeDescription = "Increases damage by 1.",
	Damage = 2
}

Weapon_MD_Prime_Buzzsaw_AB = Weapon_MD_Prime_Buzzsaw:new{
    Vore = true,
	Damage = 2
}	

function Weapon_MD_Prime_Buzzsaw:GetTargetArea(p1)
    local ret = PointList()
    for i = DIR_START, DIR_END do
        local point = p1 + DIR_VECTORS[i] * 1

        if Board:IsValid(point) then
            ret:push_back(point)
        end
    end

    return ret
end

local function MD_HiddenArtillery(effect, p)
	effect:AddScript([[
		local effect = SkillEffect()
        local damage = SpaceDamage(Point(]].. p.x ..",".. p.y ..[[), 0)
        effect:AddArtillery
		Board:AddEffect(effect)
	]])
end

function Weapon_MD_Prime_Buzzsaw:GetSkillEffect(p1, p2)
    local ret = SkillEffect()

    local p3 = p1 + DIR_VECTORS[GetDirection(p1 - p2)]

    local damage = SpaceDamage(p2, self.Damage)
    ret:AddMelee(p1, damage)
    ret:AddSound(self.DamageSound)

    local pawn2 = Board:GetPawn(p2)

    if self.Vore and pawn2 ~= nil and not Board:IsBlocked(p3, PATH_FLYER) then
        ret:AddDelay(0.05)
        ret:AddCharge(Board:GetPath(p2, p3, PATH_FLYER), NO_DELAY)
    end

    local isFire = Board:IsFire(p2) or (pawn2 ~= nil and pawn2:IsFire())
    local isAcid = Board:IsAcid(p2) or (pawn2 ~= nil and pawn2:IsAcid())

    local distance = 2
    while true do

        local p3 = p1 + DIR_VECTORS[GetDirection(p2 - p1)] * distance

        if not Board:IsValid(p3) then
            break
        end

        if isAcid then
            local damage2 = SpaceDamage(p3, 0)
            damage2.iAcid = 1
            damage2.sAnimation = "ExploAcid1"
            damage2.sSound = "/impact/generic/acid_canister"
            ret:AddSound("/enemy/beetle_1/attack_impact")
            ret:AddArtillery(p1, damage2, "effects/shotup_ant2.png", NO_DELAY)
        end

        if isFire then
            local damage2 = SpaceDamage(p3, 0)
            damage2.iFire = 1
            damage2.sAnimation = "ExploArt2"
            ret:AddSound("/weapons/fireball")
            ret:AddArtillery(p1, damage2, "effects/shotup_ignite_fireball.png", NO_DELAY)
        end

        ret:AddDelay(0.1)

        distance = distance + 1
    end

    return ret
end