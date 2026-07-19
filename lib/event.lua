-- Events for Bridging Inputs and Actions --

local class = require("lib.class")

---@class Events
local events = class:extract("Events")

function events:new()
    self.events = {}
    return self
end

---@param key string
---@param triggers? table<function>
---@param action? function
function events:new_event(key, triggers, action)
    self.events[key] = { triggers = triggers and triggers or {}, action = action }
end



function events:remove_event(key)
    assert(self.events[key] ~= nil, "Event Key doesn't point to an event.")
    local e = self.events[key]
    self.events[key] = nil
    return e
end

function events:update_trigger(key, trigger)
    assert(self.events[key] ~= nil, "Event Key doesn't point to an event.")
    table.insert(self.events[key].triggers, trigger)
end

function events:update_action(key, action)
    assert(self.events[key] ~= nil, "Event Key doesn't point to an event.")
    self.events[key].action = action
end

---@param key string
---@param context? table
---@return boolean
function events:is_action_pressed(key, context)
    assert(self.events[key] ~= nil, "Event Key doesn't point to an event.")
    if context == nil then context = {} end
    local event = self.events[key]
    for _, trigger in ipairs(event.triggers) do
        if type(trigger) ~= "function" and trigger:is_type("Button") then
            if trigger:is_triggered() then
                return true
            end
        else
            if trigger(context) then
                return true
            end
        end
    end
    return false
end

function events:run(key, args)
    assert(self.events[key] ~= nil, "Event Key doesn't point to an event.")
    return self.events[key].action(args)
end


return events