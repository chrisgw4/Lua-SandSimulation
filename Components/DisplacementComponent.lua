local Vector2 = require("Vector2Script")

local displacement_component = {}

displacement_component.__index = displacement_component


function displacement_component.new()
    local myClass = setmetatable({}, displacement_component)

    myClass.velocity = 1
    
    return myClass
end

function displacement_component:Displace(particle_table, position, parent, distance)
    -- Check how far the particle can fall with its velocity before hitting something
    for i = 1,distance do
        -- Checks if block above is nothing and then is able to displace the current particle there
        if particle_table[Clampf(position.y-i, 1, HEIGHT-1)][position.x] == nil then

            

            -- Increment the current position
            position.y = Clampf(position.y - i, 1, HEIGHT-1)

            -- Set the new point the displaced particle is at to (occupied)
            particle_table[position.y][position.x] = parent

            break
        end
    end
    return position
end


return displacement_component