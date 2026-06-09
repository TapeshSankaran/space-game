-- Button for UI --

local shape = require("lib.shape")

local button = Class:extract("Button")

-- cfg: [f{ill color}, b{order color}, name*, font, action*, args, triggers] --
function button:new(cfg)
    self.pos = cfg.p and cfg.p or Vector(0, 0)
    self.size = cfg.s and cfg.s or Vector(200, 100)
    
    local square = { 
        t = "rect", 
        f = cfg.f,
        b = cfg.b,
        p = self.pos,
        s = self.size
    }
    
    if cfg.shape and (cfg.shape.type == "rect" or cfg.shape.type == "rectangle") then
        square = cfg.shape
    end
    
    self.pressed    = false
    self.event      = cfg.name:lower() .. "_pressed"
    
    InputEvents:new_event(self.event, 
        cfg.triggers and cfg.triggers or nil,
        cfg.action
    )

    InputEvents:update_trigger(self.event, self)

    self.name       = cfg.name
    self.background = shape:new(square)
    self.font       = cfg.font             and cfg.font   or Fonts.s16.martius
    self.args       = cfg.args and cfg.args or {}

    return self
end

function button:is_hovering()
    local m_pos = Input:mouse_screen_position()
    return (m_pos >= self.pos and m_pos <= self.pos+self.size) 
end

function button:is_pressed()
    return self:is_hovering() and Input:is_mouse_down('left')
end

function button:is_triggered()
    return self:is_hovering() and Input:mouse_released('left')
end

function button:update(dt)
    if InputEvents:is_action_pressed(self.event) then
        print("clicked button")
        self.pressed = true
        InputEvents:run(self.event, unpack(self.args))
    end
end

function button:draw(pos)
    local transform
    if pos and pos ~= self.pos then
        self.background:change_pos(pos)
        transform = love.math.newTransform(pos.x, pos.y)
        self.pos = pos
    end

    local c_offset = self:is_hovering() and COLORS.TRUE.WHITE or nil
    self.background:draw(c_offset, c_offset)

    local w = self.font:getWidth(self.name)
    local h = self.font:getHeight()
    love.graphics.setFont(self.font)
    love.graphics.print(self.name, self.pos.x + self.size.w / 2 - w / 2, self.pos.y + self.size.h / 2 - h / 2)

    self.pressed = false
end

return button
