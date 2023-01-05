local M = {}

local width, height = love.graphics.getDimensions()
local Screen = {
  width = width,
  height = height,
  
  RandomPoint = function(self)
    return {x = math.random(0, self.width), y = math.random(0, self.height)}
  end
}

local function CreateNode(name, value)
    local node = {
        data = {
            name = name,
            value = value,
            x = 0,
            y = 0,
            width = 0,
            height = 0,
            color = {
                r = math.random(0, 255),
                g = math.random(0, 255),
                b = math.random(0, 255)
            }
        }
    }
    return node
end

local function CalculateTreeMapSlice(datas)
    table.sort( datas, function(a, b) return a.data.value > b.data.value end )

    local totalValue = 0
    for i,v in ipairs(datas) do
        totalValue = totalValue + v.data.value
    end

    local height = 0
    for i,v in ipairs(datas) do
        local addHeight = Screen.height * (v.data.value / totalValue)
        v.data.x = 0
        v.data.y = height
        v.data.width = Screen.width
        v.data.height = addHeight
        height = height + addHeight
    end
end

local function CalculateTreeMapDice(datas)
    table.sort( datas, function(a, b) return a.data.value > b.data.value end )

    local totalValue = 0
    for i,v in ipairs(datas) do
        totalValue = totalValue + v.data.value
    end

    local width = 0
    for i,v in ipairs(datas) do
        local addWidth = Screen.width * (v.data.value / totalValue)
        v.data.x = width
        v.data.y = 0
        v.data.width = addWidth
        v.data.height = Screen.height
        width = width + addWidth
    end
end

local datas = {}
function M.load()
    table.insert(datas, CreateNode("A", 6))
    table.insert(datas, CreateNode("B", 1))
    table.insert(datas, CreateNode("C", 8))
    table.insert(datas, CreateNode("D", 4))
    table.insert(datas, CreateNode("E", 3))
    table.insert(datas, CreateNode("F", 1))
    table.insert(datas, CreateNode("G", 2))
    table.insert(datas, CreateNode("H", 3))
    table.insert(datas, CreateNode("I", 10))

    CalculateTreeMapSlice(datas)    
end

function M.update(dt)
end

local function drawNode(node)
    love.graphics.setColor(node.data.color.r/255, node.data.color.g/255, node.data.color.b/255, 1)
    love.graphics.rectangle("fill", node.data.x, node.data.y, node.data.width, node.data.height)
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("line", node.data.x, node.data.y, node.data.width, node.data.height)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(node.data.name, node.data.x, node.data.y, node.data.width, "center")
end

function M.draw()
    for i,v in ipairs(datas) do
        drawNode(v)
    end
end

function M.keyreleased(key) 
end

return M