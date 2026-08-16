Weap_MD_Brute_Fire = Skill:new{
    Name = "Side Burners",
    Description = "Deal 1 damage to opposite tiles, igniting and pushing them.",
    Class = "Brute",
	Icon = "weapons/prime_flamethrower.png",
    Damage = 0,
    Range = 1,
	PathSize = 1,
    PowerCost = 0,
	Upgrades = 2,
	UpgradeList = { "+1 Range",  "+1 Damage"  },
	UpgradeCost = { 2 , 2 },
	LaunchSound = "/weapons/flamethrower",
	TipImage = {
        Unit = Point(2,2),
        Enemy = Point(2,1),
        Enemy2 = Point(2,3),
        Target = Point(2,1)
    }
}

Weap_MD_Brute_Fire_A = Weap_MD_Brute_Fire:new{
    UpgradeDescription = "Increases range by 1.",
	PathSize = 2, 
	Range = 2,
	TipImage = {
        Unit = Point(2,3),
        Enemy = Point(2,1),
        Enemy2 = Point(2,2),
        Enemy3 = Point(2,4),
        Target = Point(2,1)
    }
}

Weap_MD_Brute_Fire_B = Weap_MD_Brute_Fire:new{
    UpgradeDescription = "Increases damage by 1.",
	Damage = 1
}

Weap_MD_Brute_Fire_AB = Weap_MD_Brute_Fire:new{
	PathSize = 2, 
	Range = 2,
	Damage = 1,
	TipImage = {
        Unit = Point(2,3),
        Enemy = Point(2,1),
        Enemy2 = Point(2,2),
        Enemy3 = Point(2,4),
        Target = Point(2,1)
    }
}

function Weap_MD_Brute_Fire:GetTargetArea(point)
	local ret = PointList()
    
	for i = DIR_START, DIR_END do

		for k = 1, self.PathSize do
            
			local curr = DIR_VECTORS[i]*k + point

			if not Board:IsValid(curr) then
				break
			end

			ret:push_back(curr)
		end
	end
	
	return ret
end

function Weap_MD_Brute_Fire:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local distance = p1:Manhattan(p2)
    
    for j = -1, 1, 2 do

	    local direction = GetDirection((p2 - p1) * j)
	
        for i = 1, distance do
            local curr = p1 + DIR_VECTORS[direction] * i
            local damage = SpaceDamage(curr, self.Damage, i == distance and direction or DIR_NONE)
            
            damage.iFire = EFFECT_CREATE
            
            if i == distance then 	
                damage.sAnimation = "flamethrower"..distance.."_"..direction 
            end
            ret:AddDamage(damage)
        end
    end    

	return ret
end	