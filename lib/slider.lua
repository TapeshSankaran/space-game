local conf = require("conf")

local slider = Class:extract("Slider")

-- cfg: [name*, pos*, w*, min, max, val, step, c: [name, bar, knob], onChange]
function slider:new(cfg)
    self.name = cfg.name
    self.pos = cfg.pos
    self.size = Vector(cfg.w, 20)

    self.min    = cfg.min  and cfg.min  or 0
    self.max    = cfg.max  and cfg.max  or 1
    self.value  = cfg.val  and cfg.min  or 0
    self.step   = cfg.step and cfg.step or 1
    self.colors = {
        name = cfg.c.name and cfg.c.name or COLORS.TRUE.GREY,
        bar  = cfg.c.bar  and cfg.c.bar  or COLORS.TRUE.GREY,
        knob = cfg.c.knob and cfg.c.knob or COLORS.TRUE.WHITE,
    }
    self.onChange = cfg.onChange and cfg.onChange or function(val) end

    self.knobRadius = 10
    self.dragging = false

    return self
end

function slider:update(dt)
    if self.dragging then
        local mouseX = love.mouse.getX()
        local percent = (mouseX - self.x) / self.size.w
        percent = math.max(0, math.min(1, percent))

        local rawValue = self.min + percent * (self.max - self.min)
        local step = self.step
        self.value = math.floor((rawValue - self.min) / step + 0.5) * step + self.min

        self.onChange(self.value)
    end
    return self.value
end

function slider:draw()
    -- Name --
    local name_font = Fonts.s16.martius

    love.graphics.setColor(self.colors.name:rgb())
    love.graphics.setFont(name_font)
    love.graphics.print(self.name, self.x-name_font:getWidth(self.name)-10, self.y)
    
    -- Bar --
    love.graphics.setColor(self.colors.bar:rgb())
    love.graphics.rectangle("fill", self.x, self.y + self.size.h/2 - 2, self.size.w, 4)

    -- Knob --
    local percent = (self.value - self.min) / (self.max - self.min)
    local knobX = self.x + percent * self.size.w

    love.graphics.setColor(self.colors.knob:rgb())
    love.graphics.circle("fill", knobX, self.y + self.size.h / 2, self.knobRadius)
    
    -- Value Indicator --
    local indicator_font = Fonts.s12.martius
    love.graphics.setColor(self.colors.name:rgb())
    love.graphics.setFont(indicator_font)
    local fW = indicator_font:getWidth(self.value)
    love.graphics.print(self.value, knobX, self.y + self.size.h/8, 0, 1, 1, fW/2, 0)
end

function slider:mousepressed(x, y, button)
    if button == 1 then
        local percent = (self.value - self.min) / (self.max - self.min)
        local knobX = self.x + percent * self.size.w
        local knobY = self.y + self.size.h / 2
        local dist = math.sqrt((x - knobX)^2 + (y - knobY)^2)
        if dist <= self.knobRadius then
            self.dragging = true
        end
    end
end

function slider:mousereleased(x, y, button)
    if button == 1 then
        self.dragging = false
    end
end

return slider
