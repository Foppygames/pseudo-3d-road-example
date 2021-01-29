-- pseudo 3d road example - aspect.lua
-- 2021 Foppygames

--[[
	Aspect.lua is a general purpose module for displaying a game that uses its own resolution
	on a screen that may use another resolution. The module scales the game graphics to match either
	the screens width or height (or both), while keeping the game's aspect ratio, and adds bars
	(letterboxing) to the left and right, or to the top and bottom, if necessary. If the game's
	aspect ratio matches that of the screen, bars are not added. See main.lua for how this is used.

	It can be noted that in some games, such as racing games, you could perhaps use the full screen
	size even if it is not in the game's aspect ratio. For example if the screen is very wide, it
	would not ruin the gameplay of a racing game to actually draw grass and trees there, as long
	as the road is still of the correct width. (In such a case you would not want to simply stretch
	the game to be wider than intended as it would flatten all graphics. Instead you would want to
	extend the game's horizontal resolution so that there is more horizontal game space and it fits
	the screen's very wide aspect ratio.) In this example this idea is not implemented, as it can
	be very game specific.
]]

local aspect = {}

local utils = require("modules.utils")

aspect.WINDOW_WIDTH = 1068
aspect.WINDOW_HEIGHT = 600
aspect.GAME_WIDTH = 356
aspect.GAME_HEIGHT = 200

local BAR_COLOR = {0,0,0}

local windowWidth
local windowHeight
local gameWidth = aspect.GAME_WIDTH
local gameHeight = aspect.GAME_HEIGHT
local scale
local bars
local gameX
local gameY
local fullScreen = true

function aspect.init()
	if (fullScreen) then
		local _, _, flags = love.window.getMode()
		local width, height = love.window.getDesktopDimensions(flags.display)
		windowWidth = width
		windowHeight = height
		
		-- hide mouse
		love.mouse.setVisible(false)
	else
		windowWidth = aspect.WINDOW_WIDTH
		windowHeight = aspect.WINDOW_HEIGHT
		
		-- show mouse
		love.mouse.setVisible(true)
	end

	bars = {}
	
	local gameAspect = gameWidth / gameHeight
	local windowAspect = windowWidth / windowHeight
	
	if (gameAspect > windowAspect) then
		-- game is wider than window; scale to use full width, use horizontal letterboxing
		scale = windowWidth / gameWidth
		local scaledGameHeight = gameHeight * scale
		local barHeight = math.ceil((windowHeight - scaledGameHeight) / 2)
		gameX = 0
		gameY = barHeight
		table.insert(bars,{
			x = 0,
			y = 0,
			width = windowWidth,
			height = barHeight
		})
		table.insert(bars,{
			x = 0,
			y = windowHeight - barHeight,
			width = windowWidth,
			height = barHeight
		})
	elseif (windowAspect > gameAspect) then
		-- window is wider than game; scale to use full height, use vertical letterboxing
		scale = windowHeight / gameHeight
		local scaledGameWidth = gameWidth * scale
		local barWidth = math.ceil((windowWidth - scaledGameWidth) / 2)
		gameX = barWidth
		gameY = 0
		table.insert(bars,{
			x = 0,
			y = 0,
			width = barWidth,
			height = windowHeight
		})
		table.insert(bars,{
			x = windowWidth-barWidth,
			y = 0,
			width = barWidth,
			height = windowHeight
		})
	else
		-- scale to full width and height, no letterboxing
		scale = windowWidth / gameWidth
		gameX = 0
		gameY = 0
	end
	
	love.window.setMode(aspect.WINDOW_WIDTH,aspect.WINDOW_HEIGHT,{fullscreen=fullScreen,fullscreentype="desktop"})	
end

function aspect.apply()
	love.graphics.push()
	love.graphics.translate(gameX,gameY)
	love.graphics.scale(scale)
end

function aspect.unapply()
	love.graphics.pop()
end

function aspect.letterbox()
	love.graphics.push()
	love.graphics.setColor(BAR_COLOR)
	for i = 1, #bars do
		love.graphics.rectangle("fill",bars[i].x,bars[i].y,bars[i].width,bars[i].height)
	end
	love.graphics.pop()
end

function aspect.toggleFullScreen()
	fullScreen = not fullScreen
	aspect.init()
end

return aspect