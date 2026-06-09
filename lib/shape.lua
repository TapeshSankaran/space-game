-- Shape Maker for UI --

require("conf")

local shape = Class:extract("Shape")

-- cfg: [t{ype}*, f{ill}, b{order}, p{osition}, (s{ize}), (r), (points)]
function shape:new(cfg)
    self.type   = cfg.t
    self.fill   = cfg.f and cfg.f or nil
    self.border = cfg.b and cfg.b or nil

    if self.type == "rect" or self.type == "rectangle" then
        self.drawShape = love.graphics.rectangle
        self.pos  = cfg.p
        self.size = cfg.s
        self.args = { cfg.p.x, cfg.p.y, cfg.s.w and cfg.s.w or 100, cfg.s.h and cfg.s.h or 100 }

    elseif self.type == "circle" then
        self.drawShape = love.graphics.circle
        self.pos  = cfg.p
        self.rad  = cfg.r
        self.args = { cfg.p.x, cfg.p.y, cfg.r and cfg.r or 100 }

    elseif self.type == "polygon" then
        self.drawShape = love.graphics.polygon
        self.pos = Vector(cfg.points[1], cfg.points[2])
        self.args = cfg.points
    end

    return self
end

function shape:draw(f_offset, b_offset)
    local fill_offset = f_offset and f_offset or self.fill
    if self.fill ~= nil then
        love.graphics.setColor( (self.fill + fill_offset):rgb() )
        self.drawShape("fill", unpack(self.args))
    end

    local border_offset = b_offset and b_offset or self.border
    if self.border ~= nil then
        love.graphics.setColor( (self.border + border_offset):rgb() )
        self.drawShape("line", unpack(self.args))
    end

end

function shape:change_pos(pos)
    self.pos = pos
    if self.type == "polygon" then
        local anchor = Vector(self.args[1], self.args[2])
        for i=1, #self.args, 2 do
            local x = self.args[i]
            local y = self.args[i+1]
            self.args[i]   = pos.x + x - anchor.x
            self.args[i+1] = pos.y + y - anchor.y
        end
        return
    end

    self.args[1] = pos.x
    self.args[2] = pos.y
end

return shape
