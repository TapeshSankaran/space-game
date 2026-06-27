require("conf")

local player = Class:extract("Player")

-- Creation of player, in each scene, must find a way to transfer player info across scenes or make player global
function player:new()
    

    return self
end

-- Update player info, manage animations, booster, mode, etc. 
function player:update(dt)
    
end

-- Draw player model, update based on info of ship, etc. Micht have to change for future games
function player:draw()

end

return player