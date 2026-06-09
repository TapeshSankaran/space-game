-- Events for Bridging Inputs and Actions --

local class = require("lib.class")

---@class Events
local events = class:extract("Events")


function events:new()
    self.events = {}
    return self
end

---@param key string
---@param triggers? function
---@param action? function
function events:new_event(key, triggers, action)
    self.events[key] = { triggers = triggers, action = action }
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

function events:is_action_pressed(key, ...)
    assert(self.events[key] ~= nil, "Event Key doesn't point to an event.")
    local event = self.events[key]
    for _, trigger in ipairs(event.triggers) do
        if trigger(...) then
            return true
        end
    end
    return false
end

function events:run(key, ...)
    assert(self.events[key] ~= nil, "Event Key doesn't point to an event.")
    return self.events[key]:action(...)
end


return events