--If point's terrain is mountain
function MD_IsMountain(point)
	return	Board:GetTerrain(point) == TERRAIN_MOUNTAIN
end