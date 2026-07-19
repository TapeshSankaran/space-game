-- menuManager --

local menu   = require("lib.menu")
-- cfg: [t{ype}*, f{ill}, b{order}, p{osition}, (s{ize}), (r), (points)] --
local shape  = require("lib.shape")

local slider = require("lib.slider")
-- cfg: [f{ill color}, b{order color}, name*, font, action] --
local button = require("lib.button")

local funcList = {
    images = image_maker,
    fonts  = font_maker,
}

function font_maker(fontList, g_list)
    for name, fileLoc in pairs(fontList) do
        name = name:lower()
        for _, size in pairs(g_list) do
            size[name] = love.graphics.newFont(fileLoc, size.s)
        end
    end
    return g_list
end

function image_maker(imgList, g_list)
    for name, fileLoc in pairs(imgList) do
        name = name:lower()
        g_list[name] = {
            img  = love.graphics.newImage(fileLoc),
            data = love.image.newImageData(fileLoc),
            path = fileLoc
        }
    end
    return g_list
end

function enum_handler(enumList, g_lists)
    for name, list in pairs(enumList) do
        if funcList[name] then funcList[name](list, g_lists[name])
        else
            table.insert(g_lists[name], funcList)
        end
    end
    return g_lists
end

function make_menus()
    local g_list = {}
    --Menu Create Config: { items, name?, triggers?, extra? }
    
    -- Start Menu --

    startButton = button({
        name = "Start",
        action = function ()
            Scene_Manager:switch("gameScene")
        end,
        triggers = {
            function ()
                return Input:is_key_pressed('return')
            end,
        },
        p = Vector(width / 2 - 50, height*0.8),
        s = Vector(100, 50)
    })
    g_list["mainMenu"] = menu({items = {startButton}})

    
    -- Pause Menu --
    g_list["pauseMenu"] = menu({
        name = "pause",
        triggers = {
            function ()
                return Input:is_key_pressed('escape')
            end
        },
        items = {
            button({
                name="Exit",
                action=function ()
                    g_list["pauseMenu"]:toggle(false)
                    Scene_Manager:switch("mainMenu")
                end,
                p=Vector(width / 2 - 50, height * 0.5 - 25),
                s=Vector(100, 50)
            }),

        }
    })
    g_list["pauseMenu"]:add_item(button:new({
        name="Return",
        action=g_list["pauseMenu"],
        p = Vector(width / 2 - 50, height * 0.8),
        s = Vector(100, 50)
    }))


    --  Main UI  --



    return g_list
end
