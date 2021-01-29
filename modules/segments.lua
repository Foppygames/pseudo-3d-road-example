-- pseudo 3d road example - segments.lua
-- 2021 Foppygames

--[[
	Segments.lua is a module that manages the active segments that make up the track layout currently on screen.
	These segments are in the 'active' table. As the road scrolls along, new segments are created on the 
	horizon, and are added to 'active'. The data for these segments is retrieved from the track.lua module, 
	which contains the segment data (length and curve value) for the complete track. The active segments affect
	how how the road is displayed in main.lua.
	
	Note that the 'length' property of an active segment is actually the part that is still beyond the horizon.
	When the 'length' of the last active segment reaches zero, this means we can see the end of that segment,
	and it is time to introduce a new last active segment at the horizon.
]]

local segments = {}

local perspective = require("modules.perspective")
local track = require("modules.track")

segments.MAX_SEGMENT_DDX = 0.0030

local segmentIndex
local active

function segments.init()
	track.init()
	active = {}
end

local function addFromIndex(index,z)
	local segment = {
		z = z
	}
	
	for key,value in pairs(track.segments[segmentIndex]) do
		segment[key] = value
	end
	
	segment.length = segment.length - (perspective.maxZ - z)
	segment.ddxFraction = segment.ddx
	segment.ddx = segment.ddx * segments.MAX_SEGMENT_DDX

	table.insert(active,segment)
end

local function addNext(dz)
	segmentIndex = segmentIndex + 1
	if (segmentIndex > #track.segments) then
		segmentIndex = 1
	end
	addFromIndex(segmentIndex,perspective.maxZ + dz)
end

function segments.addFirst()
	segmentIndex = 1
	addFromIndex(segmentIndex,0)
end

function segments.update(speed,dt)
	local removeFromStart = 0
	for i, segment in ipairs(active) do
		if (segment.z > perspective.minZ) then
			segment.z = segment.z - speed * dt
			if (segment.z <= perspective.minZ) then
				segment.z = perspective.minZ
				if (i > 1) then
					removeFromStart = removeFromStart + 1
				end
			end
		end
		segment.length = segment.length - speed * dt
	end
	
	if (#active > 0) then
		if (active[#active].length <= 0) then
			-- add next segment
			addNext(active[#active].length)
		end
	end
	
	-- remove segments now behind us
	while (removeFromStart > 0) do
		table.remove(active,1)
		removeFromStart = removeFromStart - 1
	end
end

function segments.getLastIndex()
	return #active
end

function segments.getAtIndex(index)
	return active[index]
end

return segments