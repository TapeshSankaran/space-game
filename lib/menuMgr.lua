-- menuManager --

local menu   = require("lib.menu")
-- cfg: [t{ype}*, f{ill}, b{order}, p{osition}, (s{ize}), (r), (points)] --
local shape  = require("lib.shape")

local slider = require("lib.slider")
-- cfg: [f{ill color}, b{order color}, name*, font, action] --
local button = require("lib.button")

function font_maker(fontList, g_list)
    for name, fileLoc in pairs(fontList) do
        name = name:lower()
        for _, size in pairs(g_list) do
            size[name] = love.graphics.newFont(fileLoc, size.s)
        end
    end
    return g_list
end

function make_menus()
    local g_list = {}

    -- Start Menu --

    startButton = button:new({
        name = "Start",
        action = function ()
            Scene_Manager:switch("gameScene")
        end,
        p = Vector(width / 2 - 50, height*0.8),
        s = Vector(100, 50),
        f = COLORS.TRUE.WHITE,
        b = COLORS.TRUE.BLACK,
    })
    g_list["mainMenu"] = menu:new({i = {startButton}})

    -- Pause Menu --



    --  Main UI  --



    return g_list
end
