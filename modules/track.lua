-- pseudo 3d road example - track.lua
-- 2021 Foppygames

--[[
	Track.lua defines a single track. In a full game, there could be several such modules and one
	tracks.lua module to manage them and to select one of the tracks to be used. The segments table
	holds the segment data for the full track. Each sub table is one segment, defining its length
	and curve value.
]]

local track = {}

local aspect = require("modules.aspect")
local perspective = require("modules.perspective")

local SMOOTHING_SEGMENT_DDX_STEP = 0.04
local SMOOTHING_SEGMENT_LENGTH = 0.05

track.totalLength = 0

-- note: length is written here as a fraction of maxZ (the length of the road we can see from the
-- bottom of the screen to the horizon), to be converted to the actual length in track.init(), which
-- is called from segments.init(); for example, a length of 1 here would be as long as from the player
-- to the horizon
-- note: ddx is written here as a fraction of segments.MAX_SEGMENT_DDX, to be converted to the
-- actual ddx in segments.addFromIndex(); for example, a ddx of 1 here would be the sharpest curve;
-- a negative ddx value means the curve is to the left
track.segments = {
	{
		ddx = 0,
		length = 2
	},
	{
		ddx = 0.7,
		length = 1.5
	},
	{
		ddx = 0,
		length = 4
	},
	{
		ddx = -0.3,
		length = 2
	}
}

--[[
	If the segments are used directly as defined above, the corner exists are very sudden, especially in a game
	where the road is scrolled at high speed. The road would snap back to the center after a corner. To avoid
	that, you would need to add a series of small curves after the main curve, each with smaller ddx values.
	This is done automatically in the function below.
]]

function track.init()
	-- smoothen corner exits
	local nextDdx
	for i = #track.segments, 1, -1 do
		if (i == #track.segments) then
			nextDdx = track.segments[1].ddx
		else
			nextDdx = track.segments[i + 1].ddx
		end
		if ((track.segments[i].ddx ~= 0) and (nextDdx == 0)) then
			local ddx = track.segments[i].ddx
			local j = 1
			if (ddx > 0) then
				ddx = ddx - SMOOTHING_SEGMENT_DDX_STEP
				while (ddx > 0) do
					table.insert(track.segments,i + j,{
						ddx = ddx,
						length = SMOOTHING_SEGMENT_LENGTH
					})
					ddx = ddx - SMOOTHING_SEGMENT_DDX_STEP
					j = j + 1
				end
			else
				ddx = ddx + SMOOTHING_SEGMENT_DDX_STEP
				while (ddx < 0) do
					table.insert(track.segments,i + j,{
						ddx = ddx,
						length = SMOOTHING_SEGMENT_LENGTH
					})
					ddx = ddx + SMOOTHING_SEGMENT_DDX_STEP
					j = j + 1
				end
			end
		end
	end

	-- compute final segment lengths
	track.totalLength = 0
	for i = 1, #track.segments do
		track.segments[i].length = track.segments[i].length * (perspective.maxZ - perspective.minZ)
		track.totalLength = track.totalLength + track.segments[i].length
	end
end
		
return track