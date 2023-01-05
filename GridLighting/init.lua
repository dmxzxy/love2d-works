local M = {}

local size = 130
local gridSize = 10
local gridColors = {}
local lightSource = {}

local backColor = {1, 1, 1}

local LIGHT_RADIUS = 16
local dropoff = {0.7, 0.7, 0.7}
local tempLight = {}
local tempLight1 = {}
local tempLight2 = {}
local tempLightSize = LIGHT_RADIUS*2+1

local function ColorMul(a, b)
    return {a[1]*b[1], a[2]*b[2], a[3]*b[3]}
end

local function ColorAdd(a,b)
    return {a[1]+b[1], a[2]+b[2], a[3]+b[3]}
end

local function ColorBlend(a, b)
    local function func(c1, c2) -- additive
        return c1 * 1 + c2 * 1
    end
    return {math.min(1, func(a[1],b[1])), math.min(1, func(a[2],b[2])), math.min(1, func(a[3],b[3]))}
end

local function IndexToPos(index)
    local x = index % size
    local y = math.floor(index / size)
    return x, y
end

local function PosToIndex(x, y)
    return x + y * size
end

function M.load()
    for x = 0, size-1 do
        for y = 0, size-1 do
            gridColors[x + y * size] = {0,0,0}
        end
    end
    for i = 0, tempLightSize-1 do 
        for j = 0, tempLightSize-1 do
            tempLight[i+j*tempLightSize] = {0,0,0}
            tempLight1[i+j*tempLightSize] = {0,0,0}
            tempLight2[i+j*tempLightSize] = {0,0,0}
        end
    end
end

local function emitlight(x, y, color)
    tempLight = {}
    for i = 0, tempLightSize-1 do 
        for j = 0, tempLightSize-1 do
            tempLight[i+j*tempLightSize] = {0,0,0}
            tempLight1[i+j*tempLightSize] = {0,0,0}
            tempLight2[i+j*tempLightSize] = {0,0,0}
        end
    end

    local queue = {}
    local lookup = {}

    local function enqueue(_x, _y, col)
        local currLayer = math.max(math.abs(x-_x), math.abs(y-_y))
        if lookup[PosToIndex(_x, _y)] == nil and currLayer <= LIGHT_RADIUS then
            table.insert(queue, {_x, _y, col})
            lookup[PosToIndex(_x, _y)] = true
        end
    end

    local function dequeue()
        return table.remove(queue, 1)
    end

    enqueue(x, y, color)
    
    while #queue > 0 do
        local emit = dequeue()

        local lx = LIGHT_RADIUS + x - emit[1]
        local ly = LIGHT_RADIUS + y - emit[2]
        tempLight[lx+ly*tempLightSize] = ColorBlend(emit[3], tempLight[lx+ly*tempLightSize] or {0,0,0})

        local col = ColorMul(emit[3], dropoff)
        enqueue(emit[1], emit[2]+1, col)
        enqueue(emit[1], emit[2]-1, col)
        enqueue(emit[1]+1, emit[2], col)
        enqueue(emit[1]-1, emit[2], col)
    end

    local function K(source, _x, _y)
        local m = {
            0.0453542/0.4787147, 0.0566406/0.4787147, 0.0453542/0.4787147,
            0.0566406/0.4787147, 0.0707355/0.4787147, 0.0566406/0.4787147,
            0.0453542/0.4787147, 0.0566406/0.4787147, 0.0453542/0.4787147
        }
        local c = {0,0,0}
        for i = _x-1, _x+1 do
            for j = _y-1, _y+1 do
                local mx = 1 + i - _x
                local my = 1 + j - _y
                local sc = source[i+j*tempLightSize] or {0,0,0}
                local mv = m[mx+my*3+1]
                c = {c[1]+sc[1]*mv, c[2]+sc[2]*mv, c[3]+sc[3]*mv}
            end
        end
        return c
    end

    for i = 0, tempLightSize-1 do 
        for j = 0, tempLightSize-1 do
            tempLight1[i+j*tempLightSize] = K(tempLight, i, j)
        end
    end
    for i = 0, tempLightSize-1 do 
        for j = 0, tempLightSize-1 do
            tempLight2[i+j*tempLightSize] = K(tempLight1, i, j)
            local gx = x - LIGHT_RADIUS + i
            local gy = y - LIGHT_RADIUS + j
            gridColors[PosToIndex(gx, gy)] = ColorBlend(tempLight2[i+j*tempLightSize], gridColors[PosToIndex(gx, gy)] or {0,0,0})
        end
    end
end

local function calculateLight()
    -- clear
    for x = 0, size-1 do
        for y = 0, size-1 do
            gridColors[x + y * size] = {0,0,0}
        end
    end

    for k, v in pairs(lightSource) do
        local x, y = IndexToPos(k)
        emitlight(x, y, v)
    end
end

local trigger = false
function M.update(dt)
    if trigger then
        calculateLight()
        trigger = false
    end
end

function M.draw()
    -- love.graphics.rectangle("line", 0, 0, gridSize * size, gridSize * size)
    for x = 0, size-1 do
        for y = 0, size-1 do
            love.graphics.setColor(ColorMul(backColor, gridColors[PosToIndex(x, y)]))
            love.graphics.rectangle("fill", x*gridSize, y*gridSize, gridSize, gridSize)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
    for x = 0, tempLightSize-1 do
        for y = 0, tempLightSize-1 do
            love.graphics.setColor(ColorMul(backColor, tempLight1[x+y*tempLightSize]))
            love.graphics.rectangle("fill", gridSize*size + x*gridSize + 10, y*gridSize, gridSize, gridSize)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
    for x = 0, tempLightSize-1 do
        for y = 0, tempLightSize-1 do
            love.graphics.setColor(ColorMul(backColor, tempLight2[x+y*tempLightSize]))
            love.graphics.rectangle("fill", gridSize*size + x*gridSize + 10, gridSize*tempLightSize + y*gridSize + 10, gridSize, gridSize)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function M.keyreleased(key) 
    local x = math.random(0, size-1)
    local y = math.random(0, size-1)
    lightSource[PosToIndex(x, y)] = {math.random(0,255)/255,math.random(0,255)/255,math.random(0,255)/255}
    -- lightSource[PosToIndex(x, y)] = {1,1,1}
    trigger = true
end

return M