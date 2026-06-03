-- UI Manager --

local config = require "conf"

local menu = {}
menu.__index = menu

function menu:new(items)
    local m = setmetatable({}, menu)

    m.ui = items
    return m
end

function menu:update(dt)
    for i, element in ipairs(self.ui) do
        if type(element.update) == "function" then
            element:update(dt)
        end
    end
end

function menu:draw()
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

return menu
