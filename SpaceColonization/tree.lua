local Leaves = require("leaves")
local Branch = require("branch")

local width, height = love.graphics.getDimensions()
local Screen = {
  width = width,
  height = height,
  
  RandomPoint = function(self, paddingx, paddingy)
    return {math.random(paddingx, self.width-paddingx), math.random(paddingy, self.height-paddingy)}
  end
}

local function createTree(setting)
  local branchLen = setting.branchGrowLength
  
  local branchs = {}
  local root = Branch.create(nil, {Screen.width/2, Screen.height}, {0, -1})
  table.insert(branchs, root)
  
  local Tree = {
    leafset = Leaves.create(Screen.width/2, Screen.height/2-50, 400, setting.leafCount, setting.leafEffectRadius, setting.leafKillRadius),
    branchs = branchs,

    -- function
    draw = function(self, debugdraw)
      if debugdraw then
        Leaves.draw(self.leafset)
      end

      for _, b in ipairs(self.branchs) do
        b:draw(debugdraw)
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
      
      Leaves.removeClosed(self.leafset)
      
      -- grow branch
      for _, b in ipairs(self.branchs) do
        if b:hasAttractLeaf() then
          local nextdir = b:getAverageDir()
          local nextpos = { b.pos[1] + nextdir[1] * branchLen, b.pos[2] + nextdir[2] * branchLen }
          table.insert(self.branchs, Branch.create(b, nextpos, nextdir, branchLen))
        end
      end
    end,

    toggleDebug = function(self)
      self.debugdraw = not self.debugdraw
    end
  }
  return Tree  
end

return {
  create = createTree
}