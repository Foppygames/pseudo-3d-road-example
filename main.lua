-- pseudo 3d road example - main.lua
-- 2021 Foppygames

--[[
	This is demonstration of a pseudo 3d road in Lua/Love2d. In short, horizontal lines of decreasing width 
	are stacked on top of each other to create a road disappearing on the horizon. The effect of a scrolling 
	road is created by drawing colored stripes on the road and the grass at an offset that is modified by the 
	player's speed. This is based on the techniques described on: http://www.extentofthejam.com/pseudo/
]]

local aspect = require("modules.aspect")
local horizon = require("modules.horizon")
local perspective = require("modules.perspective")
local road = require("modules.road")
local segments = require("modules.segments")

local CURBS_COLORS = {{1, 0.26, 0}, {1, 0.95, 0.95}}
local GRASS_COLORS = {{0.45, 0.8, 0.25}, {0.36, 0.6, 0.20}}
local STRIPES_COLOR = {1, 0.95, 0.95}
local TARMAC_COLORS = {{0.32, 0.26, 0.26}, {0.37, 0.30, 0.30}}
local SKY_COLOR = {0,0.65,1}
local SKY_HEIGHT = aspect.GAME_HEIGHT * 0.5
local SPEED = 40

local textureOffset = 0

function love.load()
	love.window.setTitle("Pseudo 3d Road Example")
	love.graphics.setDefaultFilter("nearest","nearest",1)
	love.graphics.setLineStyle("rough")
	
	aspect.init()
	horizon.init()
	perspective.initZMapAndScaling()
	segments.init()
	segments.addFirst()
end

function love.update(dt)
	-- update texture offset
	textureOffset = textureOffset + SPEED * dt
	if (textureOffset > 8) then
		textureOffset = textureOffset - 8
	end
	
	segments.update(SPEED,dt)
	horizon.update(segments.getAtIndex(1).ddx,SPEED,dt)
end

function love.keypressed(key)
	if (key == "w") then
		aspect.toggleFullScreen()
	end
	if (key == "escape") then
		love.event.quit()
	end
end

function love.draw()
	aspect.apply()
	
	-- draw sky
	love.graphics.setColor(SKY_COLOR)
	love.graphics.rectangle("fill",0,0,aspect.GAME_WIDTH,SKY_HEIGHT)

	-- draw horizon
	horizon.draw()

	-- player is at x = 0 which is center of road;
	-- in a game this value would be changed by steering;
	-- for example: -road.ROAD_WIDTH / 2 means player is on left edge of road
	local playerX = 0
	
	-- initial vertical position of drawing of road; starting at the bottom of the screen;
	-- subtracting 0.5 to counter off-by-one problems when drawing lines
	-- as discussed at top of page here https://love2d.org/wiki/love.graphics
	local screenY = aspect.GAME_HEIGHT - 0.5
	
	-- initial horizontal position of drawing of road; where the center of the road is drawn on screen;
	-- playerX is used in computation in such a way that player is always in center of screen
	local screenX = aspect.GAME_WIDTH / 2 - playerX * perspective.scale[1]
	
	-- correction to always make road point to horizontal center of horizon
	local perspectiveDX = (aspect.GAME_WIDTH / 2 - screenX) / perspective.GROUND_HEIGHT
			
	-- start with first active segment; assuming there is at least one active segment;
	-- this is the track segment we are currently on, at the bottom of the screen
	local segmentIndex = 1

	-- get the index of the last active segment so we know when we have reached it;
	-- this is the track segment we can see on the horizon (can be the same we are on)
	local lastSegmentIndex = segments.getLastIndex()

	-- get information on the first active segment
	local segment = segments.getAtIndex(segmentIndex)
	
	-- at the bottom of the screen there is no curve yet
	local dx = 0

	-- draw the ground and road one line at a time;
	-- i = 1 is the bottom line, i = GROUND_HEIGHT is the top line at the horizon
	for i = 1, perspective.GROUND_HEIGHT do
		-- get the z for this line; z represents the distance;
		-- lines at the bottom of the screen have small z
		local z = perspective.zMap[i]
		
		-- set default color index; this index is used to pick either color 1 or color 2 from a pair of colors;
		-- this will create the horizontal striping effect in grass, tarmac and curbs
		local colorIndex = 1
		
		-- toggle color index for horizontal striping effect; z is used in this computation so striping towards the horizon
		-- is more flattened, this helps in creating the 3d perspective; try replacing z with i in this computation
		-- and you will see the striping is of the same height regardless of distance towards horizon
		if (((z + textureOffset) % 8) > 4) then
			colorIndex = 2
		end
		
		-- consider switching to next segment
		if (segmentIndex < lastSegmentIndex) then
			if (z > segments.getAtIndex(segmentIndex+1).z) then
				segmentIndex = segmentIndex + 1
				segment = segments.getAtIndex(segmentIndex)
			end
		end
		
		-- elements are scaled for current line
		local roadWidth = road.ROAD_WIDTH * perspective.scale[i]
		local curbWidth = road.CURB_WIDTH * perspective.scale[i]
		local stripeWidth = road.STRIPE_WIDTH * perspective.scale[i]
		
		-- start x of road line
		local roadX = screenX - roadWidth / 2
		
		-- draw grass
		love.graphics.setColor(GRASS_COLORS[colorIndex])
		love.graphics.line(0,screenY,aspect.GAME_WIDTH,screenY)

		-- draw tarmac
		love.graphics.setColor(TARMAC_COLORS[colorIndex])
		love.graphics.line(roadX,screenY,roadX+roadWidth,screenY)

		-- draw stripes
		if (colorIndex ~= 1) then
			love.graphics.setColor(STRIPES_COLOR)
			love.graphics.line(screenX-stripeWidth/2,screenY,screenX+stripeWidth/2,screenY)			
		end

		-- draw curbs
		love.graphics.setColor(CURBS_COLORS[colorIndex])
		love.graphics.line(roadX,screenY,roadX+curbWidth,screenY)
		love.graphics.line(roadX+roadWidth-curbWidth,screenY,roadX+roadWidth,screenY)
		
		-- no hills, just decrease y by one
		screenY = screenY - 1
		
		-- update the change that is applied to x
		dx = dx + segment.ddx * perspective.zMap[i] * (perspective.zMap[i] / 6) * ((perspective.scale[1]-perspective.scale[i])*2.5)
		
		-- apply the change to x and apply perspective correction 
		screenX = screenX + dx + perspectiveDX
	end		
	
	aspect.unapply()
	aspect.letterbox()
end