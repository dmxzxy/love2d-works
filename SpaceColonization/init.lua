package.path = package.path..";SpaceColonization/?.lua"


local M = {}
local Tree = require("tree")
local Setting = require("setting")

--[[
  1.A volume inside which the leaves will be contained is defined. Its shape will have a direct influence on the shape of the final tree
  2.This volume is populated by leaves (points in the space), using any kind of distribution
  3.A branch starts to grow from the bottom of the volume towards the leafs
  4.The branch is attracted by the leaves and starts to split over and over to reach more of them. Once a leaf is reached, it is removed from the volume
  5.This keeps going until no more leaves are left
]]--


local tree = nil
local autogrow = false
local debugdraw = false
local helpdraw = true
local acctime = 0
local setting = {}
function M.load()
  math.randomseed(os.time())

  Setting(setting)
  tree = Tree.create(setting)
end

function M.update(dt)
  if autogrow then
    acctime = acctime + dt
    if acctime > setting.autoGrowSpeed then
      tree:grow()
      acctime = acctime - setting.autoGrowSpeed
    end
  end
end

function M.draw()
  tree:draw(debugdraw)

  if helpdraw then
    local runtime_str = {}
    table.insert(runtime_str, "A growing tree based on the space colonization algorithm!")
    table.insert(runtime_str, "")
    table.insert(runtime_str, string.format("Branch Count:%d, Leaf Count:%d", #tree.branchs, #tree.leafset))
    table.insert(runtime_str, "")
    table.insert(runtime_str, "r = reset tree")
    table.insert(runtime_str, "h = toggle help")
    table.insert(runtime_str, "a = toggle auto grow")
    table.insert(runtime_str, "d = toggle debug draw")
    if not autogrow then
      table.insert(runtime_str, "g = one step grow")
    end
  
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(table.concat(runtime_str, "\n"), 0, 0, 300, "left")
  end
end

function M.keyreleased(key)
  if key == "a" then
    autogrow = not autogrow
  end

  if key == "r" then
    tree = Tree.create(setting)
  end
  
  if key == "h" then
    helpdraw = not helpdraw
  end

  if key == "d" then
    debugdraw = not debugdraw
  end

  if key == "g" then
    tree:grow()
  end
end

return M