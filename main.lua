if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  if pcall(require, "lldebugger") then require("lldebugger").start() end
  if pcall(require, "mobdebug") then require("mobdebug").start() end
end

vector2 = require("vector2")

local Selects = {
  ["CirclePacking"] = require("CirclePacking"),
  ["SpaceColonization"] = require("SpaceColonization")
}

local currSelect = "SpaceColonization"

function love.load()
  Selects[currSelect].load()
end

-- Increase the size of the rectangle every frame.
function love.update(dt)
  Selects[currSelect].update(dt)
end

-- Draw a coloured rectangle.
function love.draw()
  Selects[currSelect].draw()
end

function love.keyreleased(key)
  Selects[currSelect].keyreleased(key)
end
