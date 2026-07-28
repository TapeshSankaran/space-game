require("conf")

local T  = Vector(0.5,   0)

local L  = Vector(  0, 0.5)
local R  = Vector(  1, 0.5)

local B  = Vector(0.5,   1)

local outlines = {           -- (1,1) | (0,1) | (1,0) | (0,0)
    [0]  = { 0 },            --   0   |   0   |   0   |   0
    [1]  = {{T, L}},         --   0   |   0   |   0   |   1
    [2]  = {{T, R}},         --   0   |   0   |   1   |   0
    [3]  = {{L, R}},         --   0   |   0   |   1   |   1
    [4]  = {{L, B}},         --   0   |   1   |   0   |   0
    [5]  = {{T, B}},         --   0   |   1   |   0   |   1
    [6]  = {{T, L}, {R, B}}, --   0   |   1   |   1   |   0
    [7]  = {{R, B}},         --   0   |   1   |   1   |   1
    [8]  = {{R, B}},         --   1   |   0   |   0   |   0
    [9]  = {{B, L}, {T, R}}, --   1   |   0   |   0   |   1
    [10] = {{T, B}},         --   1   |   0   |   1   |   0
    [11] = {{R, B}},         --   1   |   0   |   1   |   1
    [12] = {{L, R}},         --   1   |   1   |   0   |   0
    [13] = {{T, R}},         --   1   |   1   |   0   |   1
    [14] = {{T, L}},         --   1   |   1   |   1   |   0
    [15] = { 1 },            --   1   |   1   |   1   |   1
}

local lines = {6, 7, 9, 10}

local mesh = Class:extract("Mesh")

function mesh:new(name, img)
    self.img  = img.img
    self.imgData = img.data
    self.name = name
    self.poly = {}
    self.finished = true

    if self:exists() then
        self:load()
    else
        self.polygon = {}
        self.triangles = {}
        self.finished = false
    end
    
    return self
end

function mesh:load()
    local path = FILE_LOCATIONS.CACHE .. self.name .. '.mesh'
    local serialized = love.filesystem.load(path)()
    self:deserialize(serialized)
end

function mesh:update()
    if not self.finished then

        self:make_poly()
    end
end

function mesh:save()
    local path = FILE_LOCATIONS.CACHE .. self.name .. '.mesh'
    local file = love.filesystem.newFile(path)
    local serialized = self:serialize()
    
    file:open('w')
    file:write('return ' .. serialized)
    file:close()
end

function mesh:deserialize(sTbl)
    self.version = sTbl.version
    self.bounds  = {
        min = Vector(unpack(sTbl.bounds.min)),
        max = Vector(unpack(sTbl.bounds.max))
    }
    self.poly = {}
    for _, vec in ipairs(sTbl.poly) do
        table.insert(self.poly, Vector(unpack(vec)))
    end
    self.triangles = {}
    for _, triangle in ipairs(sTbl.triangles) do
        table.insert(self.triangles, {
            a=Vector(unpack(triangle.a)),
            b=Vector(unpack(triangle.b)),
            c=Vector(unpack(triangle.c))
        })
    end
end

function mesh:serialize()
    local sTbl = {}
    sTbl.version = self.version
    sTbl.bounds  = {
        min = self.bounds.min:serialize(),
        max = self.bounds.max:serialize()
    }
    sTbl.poly = {}
    for _, vec in ipairs(self.poly) do
        table.insert(sTbl.poly, vec:serialize())
    end
    sTbl.triangles = {}
    for _, triangle in ipairs(self.triangles) do
        table.insert(sTbl.triangles, {
            a=triangle.a:serialize(),
            b=triangle.b:serialize(),
            c=triangle.c:serialize()
        })
    end
    return Lume.serialize(sTbl)
end

function mesh:exists(p)
    local path = FILE_LOCATIONS.CACHE .. self.name .. '.mesh'
    return love.filesystem.getInfo(p or path) ~= nil
end



function mesh:generate()
    self:make_poly()
    self:generate_triangles()
end

function mesh:make_poly()

    if Input:mouse_clicked('left') then
        local mPos = Input:mouse_screen_position()
        
        local imgSize = Vector(self.imgData:getDimensions())
        local s = imgSize.h / height
        local x = width/2 - imgSize.w/2

        mPos = (mPos - Vector(x, 0)) * s
        table.insert(self.polygon, mPos)
    end

    if Input:mouse_clicked('right') then
        if #self.polygon > 1 then
            table.remove(self.polygon, #self.polygon)
        end
    end

    if Input:is_key_pressed('return') then
        
    end
end

function mesh:marching_squares()
    local imgW, imgH = self.imgData:getDimensions()
    local edges = {}
    local vertices = {}
    local min = Vector(math.huge, math.huge)
    local max = Vector(0-math.huge, 0-math.huge)
    for x=1,imgW-1 do
        for y=1,imgH-1 do
            local a00 = Color(self.imgData:getPixel(x - 1, y - 1)).a
            local a10 = Color(self.imgData:getPixel(x    , y - 1)).a
            local a01 = Color(self.imgData:getPixel(x - 1, y    )).a
            local a11 = Color(self.imgData:getPixel(x    , y    )).a

            local binInt = foursquare_mask(
                a00, a10,
                a01, a11
            )
            local outlnMask = outlines[binInt]
            for _, seg in ipairs(outlnMask) do
                if seg == 0 or seg == 1 then break end

                local v1  = seg[1]
                local v2  = seg[2]
                local pos = Vector(x, y)
                -- fill left/top side if v1.x > v2.x   ...    or v1.y > v2.y if v1.x == v2.x
                -- else fill right/bottom side if v1.x < v2.x or v1.y < v2.y if v1.x == v2.x
                
                local p1 = pos + v1
                local p2 = pos + v2
                local edge = {
                    a = p1,
                    b = p2,
                    t = binInt,
                    v = false,
                }
                table.insert(edges, edge)
                if vertices[p1:hash()] then
                    table.insert(vertices[p1:hash()].e, edge)
                else
                    vertices[p1:hash()] = { e={ edge }, vec=p1 }
                end
                if vertices[p2:hash()] then
                    table.insert(vertices[p2:hash()].e, edge)
                else
                    vertices[p2:hash()] = { e={ edge }, vec=p2 }
                end

            end
        end
    end

    --for key, item in pairs(vertices) do
    --    local v = item.vec
    --    local edges = item.e
    --    if #edges ~= 2 then
    --        print("Bad Vertex " .. tostring(v) .. ": \n  Edges:")
    --        for i, edge in ipairs(edges) do
    --            print("    " .. i .. ': ' .. tostring(edge.a) .. '->' .. tostring(edge.b))
    --        end
    --    end
    --end
    --local count = {}

    local bad = {}

    for _, v in pairs(vertices) do
        if #v.e ~= 2 then
            table.insert(bad, v)
        end
    end

    for _, v in ipairs(bad) do
        local nearest = math.huge
        local nearestVec

        for _, u in ipairs(bad) do
            if u ~= v then
                local d = (u.vec - v.vec):mag()
                if d < nearest then
                    nearest = d
                    nearestVec = u.vec
                end
            end
        end

        print(v.vec, "deg", #v.e, "nearest", nearest, nearestVec)
    end

    local start = edges[1]
    local prev     = nil
    local curr     = start
    local currVec  = start.a
    local polygon = {}
    while true do
        if prev then
            if prev.t ~= curr.t then

                local isAligned = false
                for _, v in ipairs(lines) do
                    if prev.t == (curr.t + v) % 16 then
                        isAligned = true
                        break
                    end
                end

                if not isAligned then
                    table.insert(polygon, currVec)
                end

            else

                local t = prev.t
                if t~=3 or t~=5 or t~=10 or t~=12 then
                    table.insert(polygon, currVec)
                end
                
            end
        else
            table.insert(polygon, currVec)
        end
        curr.v = true

        if currVec.x < min.x then
            min.x = currVec.x
        elseif currVec.x > max.x then
            max.x = currVec.x
        end

        if currVec.y < min.y then
            min.y = currVec.y
        elseif currVec.y > max.y then
            max.y = currVec.y
        end

        local nextVec
        if currVec == curr.a then
            nextVec = curr.b
        else
            nextVec = curr.a
        end

        if nextVec == start.a then
            break
        end

        local next
        local msg = ''
        for _, edge in ipairs(vertices[nextVec:hash()].e) do
            msg = msg .. '\n  ' .. tostring(edge.a) .. '->' .. tostring(edge.b) .. '\n  <\n    currEdge?: ' .. tostring(edge == curr) .. '\n    visited?: ' .. tostring(edge.v) .. '\n    extmdy?: ' .. tostring(edge.a == start.a or edge.b == start.a) .. '\n  >'
            if edge ~= curr and edge.v == false then
                next = edge
                break
            end
        end

        assert(next ~= nil, "Next edge broken. \nCurrent Vector: " .. tostring(currVec) .. '\nNext Vector: ' .. tostring(nextVec) .. '\nNext Edge(s):' .. msg)
        currVec = nextVec
        prev = curr
        curr = next
    end

    self.vertices = vertices
    self.edges = edges
    self.poly = polygon
    
    self.bounds = { 
        min=min,
        max=max
    }
end

function foursquare_mask(a1, a2, a3, a4)
    return  (a4 > 0.5 and 1 or 0) * 8 +
            (a3 > 0.5 and 1 or 0) * 4 +
            (a2 > 0.5 and 1 or 0) * 2 +
            (a1 > 0.5 and 1 or 0) * 1
end

function mesh:generate_triangles()
    --Ear Clipping
    local poly = table.clone(self.poly)
    local triangles = {}
    while #poly > 3 do
        
        for i, vertex in ipairs(poly) do
            local iA = i == 1 and #poly or i-1

            local a = poly[ iA ]
            local b = vertex
            local c = poly[ ((i+1) % #poly) ]
            
            local theta = math.abs( math.deg( b:angle_to(a) - b:angle_to(c) ) )
            if theta < 180 then

                local triangle = {
                    a=a,
                    b=b,
                    c=c
                }

                local outOfBounds = false
                
                for _, item in pairs(self.vertices) do

                    local v = item.vec
                    if triangle.a ~= v and triangle.b ~= v and triangle.c ~= v then
                        if in_triangle(triangle, v) then
                            outOfBounds = true
                            break
                        end
                    end

                end
                if outOfBounds then
                    goto continue
                end

                table.insert(triangles, triangle)
                table.remove(poly, i)
                break
            end
            ::continue::
        end
    end
    table.insert(triangles, { a=poly[1], b=poly[2], c=poly[3] })
    self.triangles = triangles
end

function sign(pt, tri)
    local t1 = tri.a
    local t2 = tri.b
    local t3 = tri.c

    local dir1 = (pt.x - t2.x) * (t1.y - t2.y) - (t1.x - t2.x) * (pt.y - t2.y)
    local dir2 = (pt.x - t3.x) * (t2.y - t3.y) - (t2.x - t3.x) * (pt.y - t3.y)
    local dir3 = (pt.x - t1.x) * (t3.y - t1.y) - (t3.x - t1.x) * (pt.y - t1.y)

    return dir1, dir2, dir3
end

function inBounds(d1, d2, d3)
    local hasNegPt = (d1 < 0) or (d2 < 0) or (d3 < 0)
    local hasPosPt = (d1 > 0) or (d2 > 0) or (d3 > 0)
    return not (hasNegPt and hasPosPt)
end

function in_triangle(tri, pt)
    
    local d1, d2, d3 = sign(pt, tri)
    
    return inBounds(d1, d2, d3)
end

function mesh:draw()
    if not self.finished then
        love.graphics.setColor(COLORS.TRUE.WHITE:rgb())

        local imgSize = Vector(self.imgData:getDimensions())
        local s = height / imgSize.h
        local anchor = Vector(imgSize.w / 2, imgSize.h / 2)
        local x = width/2 - imgSize.w/2
        love.graphics.draw(self.img, width/2, height/2, 0, s, s, anchor.x, anchor.y)

        for i, v in ipairs(self.polygon) do
            local n = self.polygon[i==#self.polygon and 1 or i+1]

            local vec  = v*s + Vector(x, 0)
            local next = n*s + Vector(x, 0)
            
            if #self.polygon > 1 then
                love.graphics.setColor((COLORS.TRUE.B + COLORS.TRUE.G):rgb())
                love.graphics.line(next:unpack(), vec:unpack())
            end

            love.graphics.setColor((COLORS.TRUE.R + COLORS.TRUE.G):rgb())
            love.graphics.circle("fill", vec.x, vec.y, 5)
        end

    end
end

return mesh