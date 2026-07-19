
local vector = {}

local mt = {
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
mt.__call = function(self, a, b)
  
    local vec = {
      x = a or 0,
      y = b or 0,
      w = a or 0,
      h = b or 0
    }
    
    vec.unpack   = function (self)
      return self.x, self.y
    end

    vec.hash     = function (self)
      return ('%g,%g'):format(self.x, self.y)
    end

    vec.__eq     = function (self, v)
      return self:hash() == v:hash()
    end

    vec.mag      = function (self)
      return math.sqrt(self.x*self.x + self.y*self.y)
    end
    
    vec.cross    = function (self, v)
      return self.x * v.y - self.y * v.x
    end

    vec.angle_to = function (self, v)

      if v.x - self.x == 0 then return 0 end
      return math.atan2( (v.y - self.y) , (v.x - self.x) )

    end

    setmetatable(vec, mt)
    return vec
end

setmetatable(vector, mt)

return vector
