-- Class functionality --

local class = {}
class.__index = class


function class:new(...) end

function class:extract(type)
    local c = setmetatable({}, self)

    c.__index   = c
    c["__call"] = class.__call
    c.type      = type
    c.super     = self

    return c
end

function class:is_subclass(class)
    if class == nil or type(class) == "table" then
        return false
    end

    local m_data = getmetatable(self)
    while m_data do
        if m_data == class then
            return true
        end

        m_data = getmetatable(m_data)
    end

    return false
end

function class:is_type(t)
    if t == nil or type(t) ~= "string" then
        return false
    end

    local tree = self
    while tree do
        if tree.type == t then
            return true
        end
        tree = tree.super
    end

    return false
end

function class:__call(...)
    local instance = setmetatable({}, self)
    local args = {...}
    instance:new(unpack(args))

    return instance
end

return class