local mod = modApi:getCurrentMod()
local modApiExt = modapiext or require(mod.scriptPath.."modApiExt/modApiExt")
local boardEvents = require(mod.scriptPath .."libs/boardEvents")

local this = {}
local trackedPawns = {}

--The game should not save while the board is busy, so using a local table should be fine.
--However, we should probably reset it when the data don't make sense anymore.

----------------------------------------------------------------
--Reset functions
----------------------------------------------------------------
--Reset tracked points
local function MD_ResetTrackedPoints()
    trackedPawns = {}
end

--Reset everything
local function MD_ResetAll()
    MD_ResetTrackedPoints()
end

----------------------------------------------------------------
--Tracking functions
----------------------------------------------------------------

--Track a point
local function MD_TrackPawn(pawn)
    table.insert(trackedPawns, pawn:GetId())    --Track this pawn
end

----------------------------------------------------------------
--Validation functions
----------------------------------------------------------------
--Get tier of current passive
local function MD_CurrentPassiveTier()
    if IsPassiveSkill("md_Passive_FireAcidBoomh_2") then
        return 2
    elseif IsPassiveSkill("md_Passive_FireAcidBoom") then
        return 1
    end

    return 0
end

----------------------------------------------------------------
--Action functions
----------------------------------------------------------------
--Explode!!
local function MD_CheckDoExplosion()

    if #trackedPawns > 0 then

        local fx = SkillEffect()    --Create effect
        local isBoom = false        --If there is an earth-shattering kaboom!

        while true do

            local i, id = next(trackedPawns)            --Get next tracked pawn

            if i and id ~= nil then                     --If pawn exists, damage it

                local pawn = Board:GetPawn(id)

                if pawn then
                    local loc = pawn:GetSpace()
                    local damage = SpaceDamage(loc, DAMAGE_DEATH)   --Create damage
                    damage.sSound = "/props/exploding_mine"
                    damage.sAnimation = "ExploArt3"                 --Here's the kaboom!
                    damage.iFire = EFFECT_CREATE                    --Leave fire behind
	                damage.iAcid = EFFECT_REMOVE                    --Spend acid on explosion
                    fx:AddDamage(damage)                            --Add damage to effect
                    fx:AddBounce(loc, 3)                            --Impact

                    isBoom = true                                   --Confirm there is a kaboom!
                end
            else
                break
            end

            trackedPawns[i] = nil
        end

        if isBoom then
            Board:AddEffect(fx)                         --Add effect to board if there are any kabooms!
        end
    end

end

--Track changes
local function MD_UpdatePoints()
end

----------------------------------------------------------------
--Init
----------------------------------------------------------------
function this:init()
    sdlext.addGameExitedHook(MD_ResetAll)
end

----------------------------------------------------------------
--Load
----------------------------------------------------------------
function this:load()

    modApi:addPreLoadGameHook(MD_ResetAll)
    
    --Mission update, update points, or do explosions when ready
    modApi:addMissionUpdateHook(function()
        if Board:GetBusyState() == 0 then   --Wait for the board to unbusy
            MD_CheckDoExplosion()
        else
            MD_UpdatePoints()               --Update the tracked positions
        end
    end)

    modApiExt:addPawnIsAcidHook(
        function(mission, pawn, isAcid)
            if MD_CurrentPassiveTier() >= 1 and isAcid and pawn:IsFire() then
                MD_TrackPawn(pawn)
            end
        end)

    modApiExt:addPawnIsFireHook(
        function(mission, pawn, isFire)
            if MD_CurrentPassiveTier() >= 1 and isFire and pawn:IsAcid() then
                MD_TrackPawn(pawn)
            end
        end)
end

return this
