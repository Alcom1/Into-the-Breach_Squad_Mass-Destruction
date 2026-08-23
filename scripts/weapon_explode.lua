Pass_MD_Generic_Explode = PassiveSkill:new{
    Name = "Explosive A.C.I.D.",
    Description = "Units affected by both acid and fire will explode with instant death!",
	Icon = "weapons/md_weapon_explode.png",
    Damage = 0,
    Passive = "md_Passive_FireAcidBoom",
    PowerCost = 0,
    Upgrades = 0,
    TipImage = {
        Unit =      Point(2, 1),
        Enemy =     Point(1, 2),
        Enemy2 =    Point(2, 2),
        Enemy3 =    Point(3, 2),	
        Fire1 =     Point(1, 2),
		Fire2 =     Point(2, 2),
		Fire3 =     Point(3, 2),
    }
}

--Hidden explosion so no skull in preview (ironically)
function MD_Hidden_Explosion(effect, p)
	effect:AddScript([[
		local effect = SkillEffect()
        local damage = SpaceDamage(Point(]].. p.x ..",".. p.y ..[[), DAMAGE_DEATH)        
        damage.sAnimation = "ExploArt3"
        damage.iFire = EFFECT_CREATE
        damage.iAcid = EFFECT_REMOVE
        effect:AddDamage(damage)
		Board:AddEffect(effect)
	]])
end

--Skill Effect for mouseover preview
function Pass_MD_Generic_Explode:GetSkillEffect(p1, p2)
    local ret = SkillEffect()

    local acidPoints = {
        Point(1, 2),
        Point(2, 2),
        Point(3, 2)
    }

    for _, point in ipairs(acidPoints) do
        local damage = SpaceDamage(point, 0)
        damage.iAcid = 1
        ret:AddDamage(damage)
    end

    ret:AddDelay(0.5)

    for _, point in ipairs(acidPoints) do
        MD_Hidden_Explosion(ret, point)
    end

    return ret
end