Weapon_MD_Prime_Buzzsaw = Skill:new{
    Name = "Central Buzzsaw",
    Description = "Pass through a tile, dealing 1 damage to it and spreading its A.C.I.D. or fire status ahead.",
    Class = "Prime",
	Icon = "advanced/weapons/Science_KO_Crack.png",
    Damage = 1,
    Backdraft = false,
    PowerCost = 0,
    Upgrades = 2,
    UpgradeCost = { 2, 2 },
    UpgradeList = { "Backdraft", "+1 Damage" },
    DamageSound = "/mech/distance/artillery/death",
    TipImage = {
        Unit = Point(2, 4),
		Fire1 = Point(2, 3),
        Enemy = Point(2, 2),
        Enemy2 = Point(2, 1),
        Target = Point(2, 0)
    }
}

Weapon_MD_Prime_Buzzsaw_A = Weapon_MD_Prime_Buzzsaw:new{
    UpgradeDescription = "Spread A.C.I.D and fire backwards as well as forwards.",
    Backdraft = true
}

Weapon_MD_Prime_Buzzsaw_B = Weapon_MD_Prime_Buzzsaw:new{
    UpgradeDescription = "Increases damage by 1.",
	Damage = 2
}

Weapon_MD_Prime_Buzzsaw_AB = Weapon_MD_Prime_Buzzsaw:new{
    Backdraft = true,
	Damage = 2
}	

function Weapon_MD_Prime_Buzzsaw:GetTargetArea(p1)
    local ret = PointList()
    for i = DIR_START, DIR_END do
        local point = p1 + DIR_VECTORS[i] * 2

        if Board:IsValid(point) and not Board:IsBlocked(point, PATH_FLYER) then
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

    ret:AddSound(self.DamageSound)                              --Initial Saw Sound
    ret:AddCharge(Board:GetPath(p1, p2, PATH_FLYER), NO_DELAY)  --Charge!

    ret:AddDelay(0.1)

    local pMid = p1 + DIR_VECTORS[GetDirection(p2 - p1)]

    local pawnMid = Board:GetPawn(pMid)
    local isFire = Board:IsFire(pMid) or (pawnMid ~= nil and pawnMid:IsFire())
    local isAcid = Board:IsAcid(pMid) or (pawnMid ~= nil and pawnMid:IsAcid())

    local damage = SpaceDamage(pMid, self.Damage)
    --damage.iAcid = 1
    damage.sSound = self.DamageSound

    ret:AddDamage(damage)
    ret:AddBounce(pMid, 1)

    local distance = 3
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
            ret:AddArtillery(p2, damage2, "effects/shotup_ant2.png", NO_DELAY)
        end

        if isFire then
            local damage2 = SpaceDamage(p3, 0)
            damage2.iFire = 1
            damage2.sAnimation = "ExploArt2"
            ret:AddSound("/weapons/fireball")
            ret:AddArtillery(p2, damage2, "effects/shotup_ignite_fireball.png", NO_DELAY)
        end

        ret:AddDelay(0.1)

        distance = distance + 1
    end

    return ret
end