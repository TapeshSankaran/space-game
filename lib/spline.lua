require("conf")

local spline = Class:extract("Spline")

--Config: { points(Array<Vector> or Vector), duration(Float)=1sec, ease(Function)=linear, loop(Bool)=false }
function spline:new(cfg, name, manager)
    if cfg.points.x then
        self.type = 'num'
    else
        self.type = 'vec'
    end
    self.points = cfg.points
    
    self.name     = name
    self.ease     = cfg.ease     and cfg.ease     or Ease.linear
    self.isCurve  = cfg.isCurve  and cfg.isCurve  or true
    self.loop     = cfg.loop     and cfg.loop     or false
    self.duration = cfg.duration and cfg.duration or 1.0
    self.manager  = manager      and manager      or nil
    self.exit     = cfg.exit     and cfg.exit     or nil
    self.args     = cfg.args     and cfg.args     or nil

    self.curve = nil
    if self.type == 'vec' then
        self:render_curve()
    end

    return self
end

function spline:render_curve()
    local pts = {}
    for _, vec in ipairs(self.points) do
        local x, y = vec:unpack()
        table.insert(pts, x)
        table.insert(pts, y)
    end

    self.curve = love.math.newBezierCurve(pts)
end

function spline:update(dt)
    if self.finished then
        if self.exit then
            self.exit(self.args)
        end

        if self.manager then
            self.manager:pop_spline(self.name)
        end
        
        self = nil
        return
    end

    self.time = self.time + dt

    if self.time >= self.duration then
        if self.loop then
           self.time = self.time - self.duration
        else
            self.time = self.duration
            self.finished = true
        end
    end
end

function spline:get_t()

    local t = self.time / self.duration
    return self.ease(t)

end

function spline:get()
    local t = self.ease(self.time)

    if self.curve then
        
        local x, y = self.curve:evaluate(t)
        return Vector(x, y)

    elseif self:is_mode('num') then

        local range = self:range()
        return range.s + t * (range.e - range.s)
        
    end


end

function spline:range(pos)
    if not pos then pos = 'none' end
    
    if self.type ~= 'num' then return Vector() end

    if pos == 'start' then

        return self.points.x
        
    elseif pos == 'end' then
        
        return self.points.y

    else
        
        return { s=self.points.x, e=self.points.y }

    end
end

function spline:is_mode(type)
    return self.type == type
end

function spline:set_manager(mgr)
    self.manager = mgr
end

function spline:is_curve()
    return self.curve
end

return spline