-- pseudo 3d road example - road.lua
-- 2021 Foppygames

--[[
    Road.lua is a module that defines the road dimensions. It has to be noted that these values
    are to be used in the game, without scaling, to check if a car goes offroad, and also to place objects
    next to the road. In other words, even for objects towards the horizon, all logic should be using the
    1:1 distance values such as defined below. The scaling is done later when drawing those objects.
    For example, placing a tree at x = road.ROAD_WIDTH / 2 means it is on the right edge of the road, regardless
    of its distance towards the horizon. (The center of the road is defined as x = 0. Negative values are to 
    the left of the center.)
]]

local road = {}

local aspect = require("modules.aspect")

road.ROAD_WIDTH = aspect.GAME_WIDTH * 1.6
road.CURB_WIDTH = road.ROAD_WIDTH / 15
road.STRIPE_WIDTH = road.CURB_WIDTH / 3

return road