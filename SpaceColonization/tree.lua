
local leaves = require("leaves")
local branch = require("branch")

local width, height = love.graphics.getDimensions()
local Screen = {
  width = width,
  height = height,
  
  RandomPoint = function(self, paddingx, paddingy)
    return {math.random(paddingx, self.width-paddingx), math.random(paddingy, self.height-paddingy)}
  end
}

function createTree()
  local branchLen = 15
  
  local branchs = {}
  local root = branch.create(nil, {Screen.width/2, Screen.height}, {0, -1})
  table.insert(branchs, root)
  
  local Tree = {
    leafset = leaves.create(Screen.width/2, Screen.height/2-50, 300, 1000, 20, 100),
    branchs = branchs,
    draw = function(self)
      leaves.draw(self.leafset)
      for _, b in ipairs(self.branchs) do
        b:draw()
      end
    end,
    
    grow_branch = function(self)
      for _, b in ipairs(self.branchs) do
        if b:hasAttractLeaf() then
          local nextdir = b:getAverageDir()
          local nextpos = { b.pos[1] + nextdir[1] * branchLen, b.pos[2] + nextdir[2] * branchLen }
          table.insert(self.branchs, branch.create(b, nextpos, nextdir, branchLen))
        end
      end
    end,
    
    grow = function(self)
      for _, b in ipairs(self.branchs) do
        b:clearAttractLeafs()
      end
      
      for i, leaf in ipairs(self.leafset) do
        local closestBranch = leaf:getClosest(self.branchs)
        if closestBranch then
          closestBranch:addAttractLeaf(leaf)
        end
      end
      
      leaves.removeClosed(self.leafset)
    end
  }
  return Tree  
end

return {
  create = createTree
}