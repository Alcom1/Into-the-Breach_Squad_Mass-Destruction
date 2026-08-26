local mod = modApi:getCurrentMod()
local globals = require(mod.scriptPath .."libs/globals")
local weaponPreview = require(mod.scriptPath .."libs/weaponPreview")
local globalPawnIndex = globals:new()

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
    UpgradeDescription = "Apply A.C.I.D. to the tile behind the mech.",
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
	local pre_event_index
	local pre_event = SpaceDamage()
	local post_event = SpaceDamage()

	ret:AddDamage(pre_event)
	pre_event_index = ret.effect:size()

	MD_ArtilleryVent(self, ret, p1, p2)
	MD_ArtilleryVent(self, ret, p1, p3)

	ret:AddBounce(p1, 1)

	MD_ArtilleryAcid(self, ret, p1, p2, NO_DELAY)
	MD_ArtilleryAcid(self, ret, p1, p3)

	MD_ArtilleryPush(self, ret, p1, p2)
	MD_ArtilleryPush(self, ret, p1, p3)

	--Fun fun fun edgecase handling for two artillery shots causing targets to collide at a corner
	--If the edgecase occurs : 
	-- * place a dummy in the middle so enemies collide properly
	-- * manually show collision damage
	-- * manually place colliusion icon
	if 	p1:Manhattan(p2) == 2 and 							--If Hit 1 is 2-away
	   	p1:Manhattan(p3) == 2 and							--If Hit 2 is 2-away
		not Board:IsBlocked(p2 + p3 - p1, PATH_FLYER) then	--If "corner" is empty

		--Cross product to determine angle between hits
		local points = {}
		local cross = (p2 - p1):MD_Cross(p3 - p1)

		--If Hits 1 and 2 are at right angles, store them in order
		if cross > 0 then
			points = { p2, p3 }
		end
		if cross < 0 then
			points = { p3, p2 }
		end

		--If points was populated because hits are at right angles
		if #points > 0 then

			local markDir = (GetDirection(points[1] - p1) + 1) % 4

			--Move points towards the corner, from which pawns may be pushed
			points = {
				points[1] + DIR_VECTORS[(GetDirection(points[1] - p1) + 1) % 4],
				points[2] + DIR_VECTORS[(GetDirection(points[2] - p1) - 1) % 4]
			}

			--Pawns
			local pawn1 = Board:GetPawn(points[1])
			local pawn2 = Board:GetPawn(points[2])

			--If there are two pawns and they are pushable
			if	pawn1 ~= nil and pawn1.IsPushable and
				pawn2 ~= nil and pawn2.IsPushable then

				--False collision marker for collision
				local collideDamage = SpaceDamage(0)

				--North and West mark
				if markDir == 0 or markDir == 3 then
					collideDamage.loc = p1
				end
				--East mark
				if markDir == 1 then
					collideDamage.loc = Point(p1.x + 2, p1.y + 0)
				end
				--South mark
				if markDir == 2 then
					collideDamage.loc = Point(p1.x + 2, p1.y + 2)
				end

				collideDamage.sImageMark = "combat/md_collision_hit_"..markDir..".png"
				ret:AddDamage(collideDamage)

				--Show collision damage
				for _, point in ipairs(points) do
					local pushDamage = SpaceDamage(point, 0)
					pushDamage.iPush = 20
					WeaponPreview:AddDamage(pushDamage)
				end

				--Event to pre-add collision dummy unit
				pre_event = ret.effect:index(pre_event_index)

				--Add collision dummy unit
				pre_event.sScript = string.format([[
					local pawn = PAWN_FACTORY:CreatePawn("MD_Wall") 
					globals[%s] = pawn:GetId() 
					pawn:SetInvisible(true) 
					Board:AddPawn(pawn, %s) 
				]], globalPawnIndex, (p2 + p3 - p1):GetString())

				--Remove collision dummy unit
				post_event.sScript = string.format([[
					local pawnId = globals[%s] 
					local pawn = Board:GetPawn(pawnId) 
					if pawn then 
						Board:RemovePawn(pawn) 
					end
				]], globalPawnIndex)

				ret:AddDelay(0.4)
				ret:AddDamage(post_event)
			end
		end
	end
	
	return ret
end