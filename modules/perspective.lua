-- pseudo 3d road example - perspective.lua
-- 2021 Foppygames

--[[
	Module perspective.lua holds tables that define the z value (distance) and scaling
	factors corresponding to every screen line below the level of the horizon. The number
	of these lines is equal to GROUND_HEIGHT, as opposed to the part of the screen above
	that part, which is the sky.
]]

local perspective = {}

local aspect = require("modules.aspect")

perspective.GROUND_HEIGHT = aspect.GAME_HEIGHT / 2
perspective.HORIZON_Y = aspect.GAME_HEIGHT - perspective.GROUND_HEIGHT

perspective.maxZ = nil
perspective.minZ = nil
perspective.scale = {}
perspective.zMap = {}

function perspective.initZMapAndScaling()
	for i = 1, perspective.GROUND_HEIGHT do
		-- the z map holds the z value for each screen line i;
		-- this computation is the result of experimentation
		perspective.zMap[i] = -1.0 / (i - perspective.GROUND_HEIGHT * 1.05) * 380

		-- scale is scaling value for each screen line i;
		-- this computation is the result of experimentation
		perspective.scale[i] = 1.0 / (-1.0 / (i - (perspective.GROUND_HEIGHT * 1.01)))
	end

	-- correct scaling so that scale 1.0 is used at y = 1
	local correct = 1.0 / perspective.scale[1]
	for i = 1, perspective.GROUND_HEIGHT do
		perspective.scale[i] = perspective.scale[i] * correct
	end
	
	-- take note of min and max z
	perspective.minZ = perspective.zMap[1]
	perspective.maxZ = perspective.zMap[perspective.GROUND_HEIGHT]
end

return perspective