-- UI Manager --

require "conf"

local menu = Class:extract("Menu")

--Config: { items, name?, triggers?, extra? }
function menu:new(cfg)
    self.ui = cfg.items

    self.name = cfg.name and cfg.name or tostring(love.math.random(10000))

    self.event = self.name:lower() .. "_open"
    
    InputEvents:new_event(self.event,
        cfg.triggers and cfg.triggers or {},
        function (m)
            m:toggle()
        end
    )

    self.enabled = false

    if cfg.extra then
        self.extra = cfg.extra
        if type(self.extra.new) == "function" then
            cfg.extra.new(self)
        end
    end
    
    return self
end

function menu:update(dt)
    if InputEvents:is_action_pressed(self.event) then
        InputEvents:run(self.event, self)
    end
    
    if not self.enabled then
        return
    end

    for i, element in ipairs(self.ui) do
        if type(element.update) == "function" then
            element:update(dt)
        end
    end

    if self.extra and type(self.extra.update) == "function" then
        self.extra:update(dt)
    end
end

function menu:draw()
    if not self.enabled then
        return
    end

    for i, item in ipairs(self.ui) do
        if type(item.draw) == "function" then
            item:draw()
        else
            love.graphics.draw(item.img, item.t)
        end
    end

    if self.extra and type(self.extra.draw) == "function" then
        self.extra:draw()
    end
end

function menu:add_item(item)
    table.insert(self.ui, item)
end

function menu:enable()
    self.enabled = true
end

function menu:disable()
    self.enabled = false
end

function menu:toggle(isEnabled)
    if isEnabled ~= nil then
        self.enabled = isEnabled
    else
        self.enabled = not self.enabled
    end
end

function menu:__tostring()
    return "Menu<" .. self.name .. ">"
end

return menu
