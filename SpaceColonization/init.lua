local M = {}

package.path = package.path..";SpaceColonization/?.lua"

local Tree = require("tree")

--[[
  1.A volume inside which the leaves will be contained is defined. Its shape will have a direct influence on the shape of the final tree
  2.This volume is populated by leaves (points in the space), using any kind of distribution
  3.A branch starts to grow from the bottom of the volume towards the leafs
  4.The branch is attracted by the leaves and starts to split over and over to reach more of them. Once a leaf is reached, it is removed from the volume
  5.This keeps going until no more leaves are left
]]--


local tree = nil
local acctime = 0
local frametime = 0.1
function M.load()
  math.randomseed(os.time())
  tree = Tree.create()
end

-- Increase the size of the rectangle every frame.
function M.update(dt)
  acctime = acctime + dt
  if acctime > frametime then
    tree:grow()
    tree:grow_branch()
    acctime = acctime - frametime
  end

end

-- Draw a coloured rectangle.
function M.draw()
  tree:draw()
end

function M.keyreleased(key)
end

return M