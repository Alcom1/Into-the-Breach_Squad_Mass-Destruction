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
local function MD_IsPassiveActive()
    return IsPassiveSkill("md_Passive_FireAcidBoom")
end

----------------------------------------------------------------
--Action functions
----------------------------------------------------------------
--Explode!!
local function MD_CheckDoExplosion()

    if #trackedPawns > 0 then

        local fx1 = SkillEffect()   --Effect for death-explosion
        local fx2 = SkillEffect()   --Effect for fire after explosion
        fx2:AddDelay(0.1)           
        local isBoom = false        --If there is an earth-shattering kaboom!

        while true do

            local i, id = next(trackedPawns)            --Get next tracked pawn

            if i and id ~= nil then                     --If pawn exists, damage it

                local pawn = Board:GetPawn(id)

                if pawn then
                    --Kaboom!
                    local loc = pawn:GetSpace()
                    local damage1 = SpaceDamage(loc, DAMAGE_DEATH)
                    damage1.sSound = "/props/exploding_mine"
                    damage1.sAnimation = "ExploArt3"    --Here's the kaboom!
                    fx1:AddDamage(damage1)
                    fx1:AddBounce(loc, 3)               --Impact

                    --Post kaboom-fire!
                    local damage2 = SpaceDamage(loc, 0)
                    damage2.iFire = EFFECT_CREATE
                    fx2:AddDamage(damage2)

                    isBoom = true                       --Confirm there is a kaboom!
                end
            else
                break
            end

            trackedPawns[i] = nil
        end

        --Add effect to board if there are any kabooms!
        if isBoom then
            fx1:AddBoardShake(0.2)  --more impact!
            Board:AddEffect(fx1)    --kaboom!
            Board:AddEffect(fx2)    --fire!
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
            if MD_IsPassiveActive() and isAcid and pawn:IsFire() then
                MD_TrackPawn(pawn)
            end
        end)

    modApiExt:addPawnIsFireHook(
        function(mission, pawn, isFire)
            if MD_IsPassiveActive() and isFire and pawn:IsAcid() then
                MD_TrackPawn(pawn)
            end
        end)
end

return this
