local Config = require "conf"

local Slider = {}
Slider.__index = Slider

-- cfg: [name*, pos*, w*, min, max, val, step, c: [name, bar, knob], onChange]
function Slider:new(cfg)
    local self = setmetatable({}, Slider)
    self.name = cfg.name
    self.pos = cfg.pos
    self.width = cfg.w
    self.height = 20
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

function Slider:update(dt)
    if self.dragging then
        local mouseX = love.mouse.getX()
        local percent = (mouseX - self.x) / self.width
        percent = math.max(0, math.min(1, percent))

        local rawValue = self.min + percent * (self.max - self.min)
        local step = self.step
        self.value = math.floor((rawValue - self.min) / step + 0.5) * step + self.min

        self.onChange(self.value)
    end
    return self.value
end

function Slider:draw()
    -- Name --
    love.graphics.setColor(self.colors.name:rgb())
    love.graphics.setFont(name_font)
    love.graphics.print(self.name, self.x-name_font:getWidth(self.name)-10, self.y)
    
    -- Bar --
    love.graphics.setColor(self.colors.bar:rgb())
    love.graphics.rectangle("fill", self.x, self.y + self.height/2 - 2, self.width, 4)

    -- Knob --
    local percent = (self.value - self.min) / (self.max - self.min)
    local knobX = self.x + percent * self.width

    love.graphics.setColor(self.colors.knob:rgb())
    love.graphics.circle("fill", knobX, self.y + self.height / 2, self.knobRadius)
    
    -- Value Indicator --
    love.graphics.setColor(self.colors.name:rgb())
    local font = love.graphics.newFont(FILE_LOCATIONS.FONT2, 11)
    love.graphics.setFont(font)
    local fW = font:getWidth(self.value)
    love.graphics.print(self.value, knobX, self.y + self.height/8, 0, 1, 1, fW/2, 0)
end

function Slider:mousepressed(x, y, button)
    if button == 1 then
        local percent = (self.value - self.min) / (self.max - self.min)
        local knobX = self.x + percent * self.width
        local knobY = self.y + self.height / 2
        local dist = math.sqrt((x - knobX)^2 + (y - knobY)^2)
        if dist <= self.knobRadius then
            self.dragging = true
        end
    end
end

function Slider:mousereleased(x, y, button)
    if button == 1 then
        self.dragging = false
    end
end

return Slider
