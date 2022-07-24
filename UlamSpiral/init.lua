--[[

    17- 16- 15- 14- 13
    |               |
    18  5 - 4 - 3   12
    |   |       |   |
    19  6   1 - 2   11
    |   |           |
    20  7 - 8 - 9 - 10
    |
    21- 22- 23- 24- 25... 

]]--


local width, height = love.graphics.getDimensions()
local Screen = {
  width = width,
  height = height,

  center = {width/2, height/2},
  
  RandomPoint = function(self, paddingx, paddingy)
    return {math.random(paddingx, self.width-paddingx), math.random(paddingy, self.height-paddingy)}
  end
}

local function rotateDirection(dir, angle)
    local rad = math.rad(angle)
    return {dir[1]*math.cos(rad)-dir[2]*math.sin(rad), dir[1]*math.sin(rad)+dir[2]*math.cos(rad)}
end

local function isPrime(num)
    num = math.floor(num)
    if num == 1 then
        return false
    end
    if num < 1 then
        return false
    end
    for i = 2, num-1 do
        if num % i == 0 then
            return false
        end
    end
    return true
end

local function createSpiralPoint(index, pos)
    local this = {
        index = index,
        pos = {pos[1], pos[2]},
    }

    this.draw = function()
        if isPrime(this.index) then
            love.graphics.points(this.pos[1], this.pos[2])
        end
        -- love.graphics.printf(tostring(this.index), this.pos[1], this.pos[2], 30, "center")
    end

    return this
end


local M = {}
local stepLenght = 1
local stepDirection = {1, 0}
local autoSpeed = 0.01
local acctime = 0
local maxPoints = 10000
local rotateStep = 0
local rotateLevelRotCount = 0
local rotateLevel = 1
local spiralPoints = {}
function M.load()
    table.insert(spiralPoints, createSpiralPoint(1, Screen.center))
end

function M.update(dt)
    acctime = acctime + dt
    if acctime > autoSpeed and #spiralPoints < maxPoints then
        local lastPoint = spiralPoints[#spiralPoints]
        local newIndex = #spiralPoints + 1

        local newPosition = {lastPoint.pos[1]+stepLenght*stepDirection[1], lastPoint.pos[2]+stepLenght*stepDirection[2]}
        table.insert(spiralPoints, createSpiralPoint(newIndex, newPosition))

        rotateStep = rotateStep + 1
        if rotateStep >= rotateLevel then
            stepDirection = rotateDirection(stepDirection, -90)
            rotateLevelRotCount = rotateLevelRotCount + 1
            if rotateLevelRotCount >= 2 then
                rotateLevel = rotateLevel + 1
                rotateLevelRotCount = 0
            end
            rotateStep = 0
        end

        acctime = acctime - autoSpeed
    end
end
  
function M.draw()
    for i, v in ipairs(spiralPoints) do
        v.draw()
    end
end

function M.keyreleased(key)
end

return M