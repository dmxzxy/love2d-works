local M = {}

local width, height = love.graphics.getDimensions()
local Screen = {
  width = width,
  height = height,
  
  RandomPoint = function(self)
    return {x = math.random(0, self.width), y = math.random(0, self.height)}
  end
}

local Circle = {
  create = function(self, x, y)
    local newcircle = {x = x, y = y, r = 1}
    return setmetatable(newcircle, {__index = self})
  end,
  update = function(self)
    local width, height = love.graphics.getDimensions()
    if self.x - self.r < 0 or self.x + self.r > width then
      return
    elseif self.y - self.r < 0 or self.y + self.r > height then
      return
    end
    self.r = self.r + 1
  end,
  draw = function(self)
    love.graphics.setColor(0, 0.4, 0.4)
    love.graphics.circle("line", self.x, self.y, self.r)
  end
}

local circleArray = {
  push = function(self, item)
    table.insert(self, item)
  end
}

function M.load()
end

-- Increase the size of the rectangle every frame.
function M.update(dt)

    local point = Screen:RandomPoint()
    circleArray:push(Circle:create(point.x, point.y))
    for i, circle in ipairs(circleArray) do
      circle:update()
    end
end

-- Draw a coloured rectangle.
function M.draw()
    for i, circle in ipairs(circleArray) do
      circle:draw()
    end
end

return M