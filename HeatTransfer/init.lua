local M = {}

local size = 250
local range = 3
local blockSize = 5
local dropoff = 0.01
local dropoff1 = 0.0005
local blocks = {}
local blockChanges = {}

local function IndexToPos(index)
end

local function PosToIndex(x, y)
    return x + y * size
end

function M.load()
    for x = 0, size-1 do
        for y = 0, size-1 do
            blocks[x + y * size] = PosToIndex(x, y) % 1000
            blocks[x + y * size] = math.random(1, 1000)
            -- blocks[x + y * size] = 0
            blockChanges[x + y * size] = 0
        end
    end
end

local function TransferHeat(x, y, OtherHeat, bDiagonal)
    local transValue = 0
    if OtherHeat > blocks[PosToIndex(x, y)] then
        if bDiagonal then
            transValue = math.max(1, math.floor((OtherHeat - blocks[PosToIndex(x, y)]) * dropoff1))
        else
            transValue = math.max(1, math.floor((OtherHeat - blocks[PosToIndex(x, y)]) * dropoff))
        end
        blockChanges[PosToIndex(x, y)] = blockChanges[PosToIndex(x, y)] - transValue
    end
    return transValue + transValue * 0.1
end


local function ProcessBlock(x, y, block)
    local function CheckVaild(_x, _y)
        return (_x ~= x or _y ~= y) and _x >= 0 and _x < size and _y >= 0 and _y < size
    end

    if(blocks[PosToIndex(x, y)] <= 0) then
        return
    end

    local totalTransValue = 0
    for _x = x - range, x + range do
        for _y = y - range, y + range do
            if CheckVaild(_x, _y) then
                local bDiagonal = _x ~= x and _y ~= y
                totalTransValue = totalTransValue + TransferHeat(_x, _y, blocks[PosToIndex(x, y)], bDiagonal)
            end
        end
    end

    blockChanges[PosToIndex(x, y)] = blockChanges[PosToIndex(x, y)] + totalTransValue
end

function M.update(dt)
    for x = 0, size-1 do
        for y = 0, size-1 do
            ProcessBlock(x, y, blocks[PosToIndex(x, y)])
        end
    end
    for x = 0, size-1 do
        for y = 0, size-1 do
            local index = PosToIndex(x, y);
            blocks[index] = blocks[index] - blockChanges[index]
            blockChanges[index] = 0;
        end
    end
end

local ColorPalette = {
    {1,1,1},
    {0.5,0.5,0.5},
    {1,0,1},
    {0,0,1},
    {0,1,0.5},
    {0,1,0},
    {1,1,0},
    {1,0.2,0},
    {1,0.5,0},
    {1,0,0},
}

function GetColorPaletteIndexByHeatValue(value)
    if value < 100 then
        return 1
    elseif value >= 100 and value < 200 then
        return 2
    elseif value >= 200 and value < 300 then
        return 3
    elseif value >= 300 and value < 400 then
        return 4
    elseif value >= 400 and value < 500 then
        return 5
    elseif value >= 500 and value < 600 then
        return 6
    elseif value >= 600 and value < 700 then
        return 7
    elseif value >= 700 and value < 800 then
        return 8
    elseif value >= 800 and value < 900 then 
        return 9
    elseif value >= 900 then 
        return 10
    end
end

function ColorLerp(color1, color2, p)
    return {color2[1]*p + color1[1]*(1-p) , color2[2]*p + color1[2]*(1-p), color2[3]*p + color1[3]*(1-p)}
end

function GetColorByHeatValue(value)
    local index = GetColorPaletteIndexByHeatValue(value)
    if index == 1 then
        return ColorPalette[index]
    end
    return ColorLerp(ColorPalette[index - 1], ColorPalette[index], (value % 100)/100)
end

function M.draw()
    for x = 0, size-1 do
        for y = 0, size-1 do
            local temp = blocks[PosToIndex(x, y)]
            local color = GetColorByHeatValue(temp)
            love.graphics.setColor(color[1], color[2], color[3], 1)
            love.graphics.rectangle("fill", x*blockSize, y*blockSize, blockSize, blockSize)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end

    for x = 0, 20 do
        for y = 0, 50 do
            local color = GetColorByHeatValue(PosToIndex(x, y))
            love.graphics.setColor(color[1], color[2], color[3], 1)
            love.graphics.rectangle("fill", 600+x*10, y*10, 10, 10)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

function M.keyreleased(key) 
    local x = math.random(0, size-1);
    local y = math.random(0, size-1);
    blocks[PosToIndex(x, y)] = blocks[PosToIndex(x, y)] + math.random(1, 1000000)
end

return M