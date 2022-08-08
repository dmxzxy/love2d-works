local M = {}

local width, height = love.graphics.getDimensions()
local Screen = {
  width = width,
  height = height,
  
  RandomPoint = function(self)
    return {x = math.random(0, self.width), y = math.random(0, self.height)}
  end
}

function M.load()
end

-- Increase the size of the rectangle every frame.
function M.update(dt)
end

local tileSize = 25
-- Draw a coloured rectangle.
function M.draw()
    for i = 0, math.floor(Screen.width / tileSize), 1 do
        love.graphics.line(i * tileSize, 0, i * tileSize, Screen.height)
    end
    for i = 0, math.floor(Screen.width / tileSize), 1 do
        love.graphics.line(0, i * tileSize, Screen.width, i * tileSize)
    end
end

function M.keyreleased(key) 
end

return M