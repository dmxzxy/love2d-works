

local function RandomPointWithinCircle(x, y, r)
  local _r = r * math.sqrt(math.random(0, 100)/100)
  local theta = math.random() * 2 * math.pi
  local _x = x + _r * math.cos(theta)
  local _y = y + _r * math.sin(theta)
  return {_x, _y}
end

local serialseed = 0
local function createLeaf(pos, effectRadius, killRadius)
  serialseed = serialseed + 1
  local leaf = {
    serial = serialseed,
    -- 位置
    pos = {pos[1], pos[2]},    
    -- 影响半径
    effectRadius = effectRadius,
    -- 消亡半径
    killRadius = killRadius,
    -- 是否关闭
    reached = false,
    -- 绘制
    draw = function (self)
        love.graphics.points(self.pos[1], self.pos[2])
        love.graphics.setColor(0, 0, 1, 0.3)
        love.graphics.circle("line", self.pos[1], self.pos[2], self.effectRadius)
        love.graphics.setColor(1, 0, 0, 0.3)
        love.graphics.circle("line", self.pos[1], self.pos[2], self.killRadius)
        love.graphics.setColor(1, 1, 1, 1)
--        love.graphics.printf(tostring(self.serial), self.pos[1], self.pos[2], 30, "center")
    end,
    
    distance = function(self, pos)
      local dx = self.pos[1] - pos[1]
      local dy = self.pos[2] - pos[2]
      return math.sqrt(dx*dx + dy*dy)
    end,
    
    inEffectRadius = function(self, pos)
      return self:distance(pos) <= self.effectRadius
    end,
  
    inKillRadius = function(self, pos)
      return self:distance(pos) <= self.killRadius
    end,
    
    getClosest = function(self, branchs)
      local closestDist = self.effectRadius
      local closestBranch = nil
      for _, branch in ipairs(branchs) do
        if self:inKillRadius(branch.pos) then
          self.reached = true
          closestBranch = nil
          break
        elseif self:inEffectRadius(branch.pos) then
          local dist = self:distance(branch.pos)
          if dist < closestDist then
            closestBranch = branch
            closestDist = dist
          end
        end
      end
      return closestBranch
    end
  }
  return leaf
end

local function createLeaves(centerx, centery, size, length, effectRadius, killRadius)
  length = math.max(10, length)
  size = math.max(100, size)
  effectRadius = effectRadius or 200
  killRadius = killRadius or 10
  if killRadius > effectRadius then
    print("killRadius bigger than effectRadius, make killRadius smaller")
    killRadius = math.floor(effectRadius / 2)
  end
  
  local leaves = {}
  for i = 1, length do
    local point = RandomPointWithinCircle(centerx, centery, size)
    leaves[i] = createLeaf(point, effectRadius, killRadius)
  end
  
  return leaves
end

local function drawLeaves(leaves)
  for i, leaf in ipairs(leaves) do
    leaf:draw()
  end
end

local function removeclosedleaves(leaves)
  for i = #leaves, 1, -1 do
    if leaves[i].reached then
      table.remove(leaves, i)
    end
  end
end

return {
  create = createLeaves,
  draw = drawLeaves,
  removeClosed = removeclosedleaves
}