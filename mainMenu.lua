
local width, height = love.graphics.getDimensions()
local Screen = {
  width = width,
  height = height,
}

local RegisteModule = {
    "CirclePacking",
    "SpaceColonization",
    "UlamSpiral",
    "GridTile",
    "TreeMap",
    "HeatTransfer",
    "GridLighting",
    "Dijkstra",
}
  
local menu = {
    onselect = nil
}

local function CreateMenuItem(name, x, y, func)
    local width = 200
    local height = 35
    local menuItem = {x = x, y = y, width = width, height = height, name = name, func = func}

    function menuItem.draw()
        love.graphics.rectangle("line", x, y, width, height)
        love.graphics.printf(name, x, y + 10, width, "center")
    end
    function menuItem.mousepressed(x, y, button, istouch)
        if x > menuItem.x and x < menuItem.x + menuItem.width and y > menuItem.y and y < menuItem.y + menuItem.height then
            menuItem.pressed = true
        end
    end
    function menuItem.mousereleased(x, y, button, istouch)
        if x > menuItem.x and x < menuItem.x + menuItem.width and y > menuItem.y and y < menuItem.y + menuItem.height and menuItem.pressed then
            menuItem.func()
            menuItem.pressed = false
        end
    end
    return menuItem
end


local menuItems = nil
local titleFont = nil
function menu.load()
    local items = {}
    for i, v in ipairs(RegisteModule) do
        local menumItem = CreateMenuItem(v, Screen.width/2 - 100, 80 + i * 50, function()
            menu.onselect(v)
        end)
        table.insert(items, menumItem)
    end
    menuItems = items

    titleFont = love.graphics.newFont(48)
end

function menu.update(dt)
end

function menu.mousepressed(x, y, button, istouch)
    if button == 1 then
        for i, v in ipairs(menuItems) do
            if v.mousepressed then
                v.mousepressed(x, y, button, istouch)
            end
        end
    end
end

function menu.mousereleased(x, y, button, istouch)
    if button == 1 then
        for i, v in ipairs(menuItems) do
            if v.mousereleased then
                v.mousereleased(x, y, button, istouch)
            end
        end
    end
end

function menu.draw()
    local of = love.graphics.getFont()

    love.graphics.setFont(titleFont)
    love.graphics.printf("Love2d-Works", 0, 0, Screen.width, "center")

    love.graphics.setFont(of)
    if menuItems then
        for i, v in ipairs(menuItems) do
            v.draw()
        end
    end
end

return menu