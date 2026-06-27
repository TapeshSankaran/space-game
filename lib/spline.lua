require("conf")

local spline = Class:extract("Spline")

--Config: { points(Array<Vector>), duration(Float)=1sec, easeIn(Bool)=true, easeOut(Bool)=true, curve(Bool)=true, loop(Bool)=false }
function spline:new(cfg)
    self.points = cfg.points
    
    self.easeIn   = cfg.easeIn   and cfg.easeIn   or true
    self.easeOut  = cfg.easeOut  and cfg.easeOut  or true
    self.curve    = cfg.curve    and cfg.curve    or true
    self.loop     = cfg.loop     and cfg.loop     or false
    self.duration = cfg.duration and cfg.duration or 1.0

    

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
    self.points = self.curve:render()
end

function spline:update(dt)
    
end

function spline:is_curve()
    return self.curve
end

return spline