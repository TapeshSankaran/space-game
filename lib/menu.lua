-- UI Manager --

require "conf"

local menu = Class:extract("Menu")

function menu:new(items)
    self.ui      = items.i
    self.trigger = type(items.t) == "function" and items.t or nil
    self.enabled = false
    
    return self
end

function menu:update(dt)
    if not self.enabled then
        return
    end

    for i, element in ipairs(self.ui) do
        if type(element.update) == "function" then
            element:update(dt)
        end
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

return menu
