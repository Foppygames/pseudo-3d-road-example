-- pseudo 3d road example - utils.lua
-- 2021 Foppygames

local utils = {}

function utils.round(num) 
	if num >= 0 then 
		return math.floor(num + 0.5) 
	else 
		return math.ceil(num - 0.5)
	end
end

return utils