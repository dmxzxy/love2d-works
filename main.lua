if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    if pcall(require, "lldebugger") then
        require("lldebugger").start()
    end
    if pcall(require, "mobdebug") then
        require("mobdebug").start()
    end
end

SVC = require("services")

local function __NULL__() end
local GSStack = {}
local GS = {callbacks = {}}
local function change_state(offset, to, ...)
	  local pre = GSStack[#GSStack]
	
    if offset == 0 then
        GSStack[#GSStack] = to
    else
        GSStack[#GSStack + offset] = to
    end
    return (GS.callbacks[to].onenter or __NULL__)(to, pre, ...)
end
function GS.register(name, onenter, onleave)
    GS.callbacks[name] = {onenter = onenter, onleave = onleave}
end
function GS.switch(to, ...)
    return change_state(0, to, ...)
end
function GS.push(to, ...)
    return change_state(1, to, ...)
end
function GS.pop()
	  local pre, to = GSStack[#GSStack], GSStack[#GSStack-1]
    GSStack[#GSStack] = nil
    (GS.callbacks[pre].onleave or __NULL__)(pre)
    return (GS.callbacks[to].onresume or __NULL__)(to, pre)
end
function GS.current()
    return GSStack[#GSStack]
end

local current = nil
local mainMenu = require("mainMenu")
function love.load()
    GS.register("menu", function(to, pre) 
        mainMenu.load()
        current = mainMenu
    end)
    GS.register("game", function(to, pre, game) 
        game.load()
        current = game
    end)

    mainMenu.onselect = function(name)
        GS.push("game", require(name))
    end

    GS.push("menu")
end

-- Increase the size of the rectangle every frame.
function love.update(dt)
  (current.update or __NULL__)(dt)
end

-- Draw a coloured rectangle.
function love.draw()
  (current.draw or __NULL__)()
end

function love.keyreleased(key)
  (current.keyreleased or __NULL__)(key)
end

function love.mousepressed(x, y, button, istouch)
  (current.mousepressed or __NULL__)(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
  (current.mousereleased or __NULL__)(x, y, button, istouch)
end

-- function love.errorhandler()
--   (current.errorhandler or __NULL__)()
-- end
