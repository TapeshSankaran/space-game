require("conf")

local T  = Vector(0.5,   0)

local L  = Vector(  0, 0.5)
local R  = Vector(  1, 0.5)

local B  = Vector(0.5,   1)

local outlines = {           -- (1,1) | (0,1) | (1,0) | (0,0)
    [0]  = { 0 },            --   0   |   0   |   0   |   0
    [1]  = {{L, T}},         --   0   |   0   |   0   |   1
    [2]  = {{R, T}},         --   0   |   0   |   1   |   0
    [3]  = {{L, R}},         --   0   |   0   |   1   |   1
    [4]  = {{L, B}},         --   0   |   1   |   0   |   0
    [5]  = {{T, B}},         --   0   |   1   |   0   |   1
    [6]  = {{T, L}, {B, R}}, --   0   |   1   |   1   |   0
    [7]  = {{B, R}},         --   0   |   1   |   1   |   1
    [8]  = {{R, B}},         --   1   |   0   |   0   |   0
    [9]  = {{B, L}, {T, R}}, --   1   |   0   |   0   |   1
    [10] = {{B, T}},         --   1   |   0   |   1   |   0
    [11] = {{R, B}},         --   1   |   0   |   1   |   1
    [12] = {{R, L}},         --   1   |   1   |   0   |   0
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

    if self:exists() then
        
        self:load()
        
    else

        self:generate()
        self:save()

    end

    return self
end

function mesh:load()  end

function mesh:save()  end

function mesh:exists()  end

function mesh:generate()
    self:marching_squares()
    self:delaunay_triangle()
end

function mesh:marching_squares()
    local imgW, imgH = self.imgData:getDimensions()
    local edges = {}
    local vertices = {}
    for x=1,imgW-1 do
        for y=1,imgH-1 do
            local a00 = Color(self.imgData:getPixel(x    , y    )).a
            local a10 = Color(self.imgData:getPixel(x + 1, y    )).a
            local a01 = Color(self.imgData:getPixel(x    , y + 1)).a
            local a11 = Color(self.imgData:getPixel(x + 1, y + 1)).a

            local binInt = foursquare_mask(
                a00, a10,
                a01, a11
            )
            local outlnMask = outlines[binInt]
            for _, seg in ipairs(outlnMask) do
                if seg == 0 or seg == 1 then goto continue end

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
                    table.insert(vertices[p1:hash()], edge)
                else
                    vertices[p1:hash()] = { edge }
                end
                if vertices[p2:hash()] then
                    table.insert(vertices[p2:hash()], edge)
                else
                    vertices[p2:hash()] = { edge }
                end

                ::continue::
            end
        end
    end

    local start = edges[1]
    local prev     = nil
    local prevVec  = nil
    local curr     = start
    local currVec  = start.a
    local polygon
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
        for _, edge in ipairs(vertices[nextVec:hash()]) do
            if edge ~= curr and not edge.v then
                next = edge
                break
            end
        end

        prevVec = currVec
        currVec = nextVec
        prev = curr
        curr = next
    end

    self.poly = polygon
    self.vertices = vertices
    self.edges = edges
end

function foursquare_mask(a1, a2, a3, a4)
    return  (a4 > 0.5 and 1 or 0) * 8 +
            (a3 > 0.5 and 1 or 0) * 4 +
            (a2 > 0.5 and 1 or 0) * 2 +
            (a1 > 0.5 and 1 or 0) * 1
end

function mesh:delaunay_triangle()
    
end

function mesh:draw()  end

return mesh