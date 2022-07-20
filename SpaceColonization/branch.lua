
local function createSegment(x,y,x1,y1)
  local Segment = {
    beginPoint = {x, y},
    endPoint = {x1, y1},
    draw = function(self, width, alpha)
      love.graphics.setColor(1, 1, 1, alpha)
      local owidth = love.graphics.getLineWidth()
      love.graphics.setLineWidth(width)
      love.graphics.setLineStyle("smooth")
      love.graphics.line(self.beginPoint[1], self.beginPoint[2], unpack(self.endPoint))
      love.graphics.setLineWidth(owidth)
    end
  }
  return Segment
end

local serialseed = 0
local function createBranch(parent, pos, dir)
  serialseed = serialseed + 1
  local branch = {
    serial = serialseed,
    parent = parent,
    pos = {pos[1], pos[2]},
    dir = {dir[1], dir[2]},
    attractLeafs = {},
    childcount = 0,
    
    segment = nil,
    normal_dir = function(self)
      local m = math.sqrt(self.dir[1] * self.dir[1], self.dir[2] * self.dir[2])
      self.dir = {self.dir[1] / m, self.dir[2] / m}
    end,
    
    draw = function(self)
        if self.segment then
          local thickness = math.min(math.floor(self.childcount / 20), 12)
          self.segment:draw(thickness, 1)
        end
        
--        love.graphics.setColor(1, 0, 0, 1)
--        love.graphics.setPointSize(4)
--        love.graphics.points(self.pos[1], self.pos[2])
--        love.graphics.setPointSize(1)
        
        love.graphics.setColor(0, 1, 0, 0.3)
        for _, leaf in ipairs(self.attractLeafs) do
          love.graphics.line(self.pos[1], self.pos[2], leaf.pos[1], leaf.pos[2])
        end
        
    end,
    
    clearAttractLeafs = function(self)
      self.attractLeafs = {}
    end,
  
    addAttractLeaf = function(self, leaf)
      table.insert(self.attractLeafs, leaf)
    end,
    
    hasAttractLeaf = function(self)
      return #self.attractLeafs > 0
    end,
    
    getAverageDir = function(self)
      local dir = {self.dir[1], self.dir[2]}
      for _, leaf in ipairs(self.attractLeafs) do
        local sub = {leaf.pos[1] - self.pos[1], leaf.pos[2] - self.pos[2]}
        local m = math.sqrt(sub[1] * sub[1] + sub[2] * sub[2])
        dir[1] = dir[1] + sub[1]/m
        dir[2] = dir[2] + sub[2]/m
      end
      
      ---
      dir[1] = dir[1] + math.random(-10000, 10000) / 10000
      dir[2] = dir[2] + math.random(-10000, 10000) / 10000
      local m = math.sqrt(dir[1] * dir[1] + dir[2] * dir[2])
      dir[1] = dir[1] / m
      dir[2] = dir[2] / m
      
      ---
      dir[1] = dir[1] / #self.attractLeafs
      dir[2] = dir[2] / #self.attractLeafs
      local m = math.sqrt(dir[1] * dir[1] + dir[2] * dir[2])
      dir[1] = dir[1] / m
      dir[2] = dir[2] / m
      
      return dir
    end,
  }
  
  if parent then
    branch.segment = createSegment(pos[1], pos[2], parent.pos[1], parent.pos[2])
    
    while parent do
      parent.childcount = parent.childcount + 1
      parent = parent.parent
    end
  end
  
  return branch
end


return {
  create = createBranch
}