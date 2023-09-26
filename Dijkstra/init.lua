local M = {}

local graphics = love.graphics

local width, height = graphics.getDimensions()
local Screen = {
  width = width,
  height = height,
  
  RandomPoint = function(self)
    return {x = math.random(0, self.width), y = math.random(0, self.height)}
  end
}

local v2 = {
    set = function(ret, x, y)
        ret[1] = x
        ret[2] = y
        return ret
    end,
    sub = function(ret, v1, v2)
        ret[1] = v1[1] - v2[1]
        ret[2] = v1[2] - v2[2]
        return ret
    end,
    add = function(ret, v1, v2)
        ret[1] = v1[1] + v2[1]
        ret[2] = v1[2] + v2[2]
        return ret
    end,
    scale = function(ret, v, t)
        ret[1] = v[1] * t
        ret[2] = v[2] * t
        return ret
    end,
    dist = function(v1, v2)
        local dx = v1[1]-v2[1]
        local dy = v1[2]-v2[2]
        return math.sqrt(dx*dx + dy*dy)
    end,
    mad = function(ret, v1, v2, t)
        ret[1] = v1[1] + v2[1] * t
        ret[2] = v1[2] + v2[2] * t
        return ret
    end,
    normalize = function(v)
        local mag = math.sqrt(v[1]*v[1] + v[2]*v[2])
        if mag > 0 then
            v[1], v[2] = v[1]/mag, v[2]/mag
        end
    end
}

local Agent = {
    create = function(self)
        local t = {
            state = 0,
            active = false,

            radius = 10,
            position = {0, 0},
            direction = {1, 0},

            speed = 0,
            target = {0, 0}
        }
        return setmetatable(t, {__index = self})
    end,

    draw = function(self)
        graphics.circle("line", self.position[1], self.position[2], self.radius)
        graphics.line(self.position[1], self.position[2], self.position[1] + self.radius*self.direction[1], self.position[2] + self.radius*self.direction[2])
    end,

    velocity = function(self)
        return {self.direction[1]*self.speed, self.direction[2]*self.speed}
    end
}

local GridField = {
    create = function(self, width, height, cellsize)
        local t = {x = 100, y = 100, width = width, height = height, cellsize = cellsize}
        return setmetatable(t, {__index = self})
    end,

    draw = function(self, crowd)
        local lr, lg, lb, la = graphics.getColor()        
        graphics.setColor(1,1,1,0.5)
        for i = 0, math.floor(self.width / self.cellsize), 1 do
            graphics.line(self.x + i * self.cellsize, self.y, self.x + i * self.cellsize, self.y + self.height)
        end
        for i = 0, math.floor(self.width / self.cellsize), 1 do
            graphics.line(self.x, self.y + i * self.cellsize, self.x + self.width, self.y + i * self.cellsize)
        end

        graphics.setColor(1,0,0,0.5)
        for i,agent in ipairs(crowd.agents) do
            if agent.active then
                local c, r = self:positionToCoordinate(agent.position)
                love.graphics.rectangle("fill", self.x + (c-1)*self.cellsize + 1, self.y + (r-1)*self.cellsize + 1, self.cellsize-2, self.cellsize-2)
            end
        end

        graphics.setColor(lr,lg,lb,la)
    end,

    isOutOfBounds = function(self, pos)
        if pos[1] >= self.x and pos[1] <= self.x + self.width then
            if pos[2] >= self.y and pos[2] <= self.y + self.height then
                return false
            end
        end
        return true
    end,

    positionToCoordinate = function(self, pos)
        local relateX = pos[1] - self.x
        local relateY = pos[2] - self.y

        local c = math.floor(relateX / self.cellsize) + 1
        local r = math.floor(relateY / self.cellsize) + 1
        
        return c, r
    end
}

local Crowd = {
    create = function(self, maxAgents, field)
        local t = {
            agents = {},
            maxAgents = maxAgents,

            field = field,
        }

        for i=1,maxAgents do
            table.insert(t.agents, Agent:create())
        end

        return setmetatable(t, {__index = self})
    end,

    addAgent = function(self, x, y)
        local idx = -1
        for i = 1, self.maxAgents do
            if not self.agents[i].active then
                idx = i
                break
            end
        end
        
        if idx == -1 then
            return nil
        end

        local agent = self.agents[idx]
        agent.active = true
        v2.set(agent.position, x, y)
        return agent
    end,

    update = function(self, dt)
        for i,agent in ipairs(self.agents) do
            if agent.active and agent.state == 1 then
                v2.sub(agent.direction, agent.target, agent.position)
                v2.normalize(agent.direction)

                local moveDis = agent.speed * dt
                local velocity = agent:velocity()
                v2.scale(velocity, velocity, dt)
                v2.add(agent.position, agent.position, velocity)

                local dist = v2.dist(agent.position, agent.target)
                if dist < (0.1 + 50 / 20) then
                    agent.state = 0
                    agent.speed = 0
                    v2.set(agent.target, 0, 0)
                end
            end
        end

        for iter = 1, 4 do
            for i = 1, #self.agents do
                local w = 0
                local ag = self.agents[i]
                if ag.active then
                    ag.disp = {0, 0}

                    for j = 1, #self.agents do
                        local nag = self.agents[j]
                        if ag ~= nag and nag.active then
                            local dist = v2.dist(ag.position, nag.position)
                            if dist < ag.radius + nag.radius then
                                local diff = {0, 0}
                                v2.sub(diff, ag.position, nag.position)
                                v2.add(ag.disp, ag.disp, v2.scale(diff, diff, 0.5/dist))
                                w = w + 1.0;
                            end
                        end
                    end
                end
                if w > 0.0001 then
                    local iw = 1.0/w
                    v2.scale(ag.disp, ag.disp, iw)
                end
            end

            for i,agent in ipairs(self.agents) do
                if agent.active then
                    v2.add(agent.position, agent.position, agent.disp)
                end
            end

        end
    end,

    draw = function(self)
        for i,agent in ipairs(self.agents) do
            if agent.active then
                agent:draw()
            end
        end
    end,

    requestMoveTarget = function(self, pos)
        for i,agent in ipairs(self.agents) do
            if agent.active then
                agent.state = 1
                agent.speed = 50
                v2.set(agent.target, pos[1], pos[2])
            end
        end
    end
}

local crowd = nil
local field = nil
function M.load()
    field = GridField:create(500, 500, 25)
    crowd = Crowd:create(10, field)
end

function M.update(dt)
    crowd:update(dt)
end
  
function M.draw()
    field:draw(crowd)
    crowd:draw()
end

function M.keyreleased(key)
end

function M.mousereleased(x, y, button, istouch)
    if button == 1 then
        if not field:isOutOfBounds({x, y}) then
            crowd:addAgent(x, y)
        end
    elseif button == 2 then
        local pos = {x, y}
        if not field:isOutOfBounds(pos) then
            crowd:requestMoveTarget(pos)
        end
    end
end

return M