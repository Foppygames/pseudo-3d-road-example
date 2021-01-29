-- pseudo 3d road example - horizon.lua
-- 2021 Foppygames

--[[
	Module horizon.lua manages and draw the horizon. If the road is scrolling and the player (camera)
	is in a curve, the horizon has to scroll in the opposite direction to create a sense of movement
	into the direction of the curve. The speed of the horizon scroll is influenced by the curve value
	and the road scrollig speed. Below, the horizon actually consists of three layers that scroll at
	different fractions of the base horizon scroling speed (those in the background go slowest) to create
	a parallax scrolling effect.
]]

local horizon = {}

local aspect = require("modules.aspect")
local perspective = require("modules.perspective")
local segments = require("modules.segments")

local images = {}
local imageIndexes = {1,2,3}
local width = {}
local count = {}
local x = {}
local y = {}
local speed = {}
local layerCount

function horizon.init()
	images = {
		love.graphics.newImage("images/horizon_clouds.png"),
		love.graphics.newImage("images/horizon_hills.png"),
		love.graphics.newImage("images/horizon_trees.png")
	}

	layerCount = #imageIndexes
	for i = 1,layerCount,1 do
		width[i] = images[imageIndexes[i]]:getWidth()
		count[i] = math.ceil(aspect.GAME_WIDTH / width[i]) + 1
		x[i] = -math.random(0,20)
		y[i] = perspective.HORIZON_Y - images[imageIndexes[i]]:getHeight()
		speed[i] = 1600 + (i-1) * 300
	end
end

function horizon.update(playerSegmentDdx,playerSpeed,dt)
	for i = 1,layerCount,1 do
		x[i] = x[i] - speed[i] * playerSegmentDdx * playerSpeed * dt
		if (x[i] < -width[i]) then
			x[i] = x[i] + width[i]
		elseif (x[i] > 0) then
			x[i] = x[i] - width[i]
		end
	end
end

function horizon.draw()
	love.graphics.setColor(1,1,1)
	for i = 1,layerCount,1 do
		for j = 0,count[i]-1,1 do
			love.graphics.draw(images[imageIndexes[i]],x[i]+j*width[i],y[i])
		end
	end
end

return horizon