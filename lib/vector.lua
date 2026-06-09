
local vector = {}

metatable = {
  __call = function(self, a, b)
  
    local vec = {
      x = a,
      y = b,
      w = a,
      h = b
    }
    setmetatable(vec, metatable)
    return vec
  
  end,
  __add = function(a, b)
    
    return vector(a.x+b.x, a.y+b.y)
  
  end,
  __sub = function(a, b)
    
    return vector(a.x-b.x, a.y-b.y)
  
  end,
  __mul = function(a, b)
    if type(a) == "number" then return vector(a*b.x, a*b.y)
    elseif type(b) == "number" then return vector(b*a.x, b*a.y) end
    return vector(a.x*b.x, a.y*b.y)
  end,
  __div = function(a, b)
    if type(a) == "number" then return vector(a/b.x, a/b.y)
    elseif type(b) == "number" then return vector(a.x/b, a.y/b) end
    return vector(a.x/b.x, a.y/b.y)
  end,
  __le = function(a, b)
    return a.x <= b.x and a.y <= b.y
  end,
  __lt = function(a, b)
    return a.x < b.x and a.y < b.y
  end,
  __tostring = function (self) return '(' .. self.x .. ', ' .. self.y .. ')' end
}

setmetatable(vector, metatable)

return vector
