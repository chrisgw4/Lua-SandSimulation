local Vector2 = require("Vector2Script")

local fluid_component = {}

fluid_component.__index = fluid_component


function fluid_component.new()
    local myClass = setmetatable({}, fluid_component)

    myClass.velocity = 1

    return myClass
end

function fluid_component:SpreadLeft(particle_table, position, parent)
    -- Check if left side is open, then we move
    if particle_table[position.y][Clampf(position.x-1, 1, WIDTH)] == nil then
        -- Set the previous point the fluid was at to nil
        particle_table[position.y][position.x] = nil

        -- Increment the current position
        position.x = Clampf(position.x - 1, 1, WIDTH)

        -- Set the new point the fluid is at to parent (occupied)
        particle_table[position.y][position.x] = parent
    end
    return position
end

function fluid_component:SpreadRight(particle_table, position, parent)
     -- Check if left side is open, then we move
    if particle_table[position.y][Clampf(position.x+1, 1, WIDTH)] == nil then
        -- Set the previous point the fluid was at to nil
        particle_table[position.y][position.x] = nil

        -- Increment the current position
        position.x = Clampf(position.x + 1, 1, WIDTH)

        -- Set the new point the fluid is at to parent (occupied)
        particle_table[position.y][position.x] = parent
    end
    return position
end

-- Spreads out the fluid to the left and right --
function fluid_component:SpreadOut(particle_table, position, parent)

    -- Checks the left and right to see if they are both free spaces --
    if particle_table[position.y][Clampf(position.x-1, 1, WIDTH)] == nil and particle_table[position.y][Clampf(position.x+1, 1, WIDTH)] == nil then
        -- randomizes the direction to go if both directions are free --
        local val = Clampf(math.random(0, 2)+0.5, 0, 1)
        if val == 0 then
            return self:SpreadLeft(particle_table, position, parent)
        else
            return self:SpreadRight(particle_table, position, parent)
        end
    -- Checks left
    elseif particle_table[position.y][Clampf(position.x-1, 1, WIDTH)] == nil then
        return self:SpreadLeft(particle_table, position, parent)
    -- Checks right
    elseif particle_table[position.y][Clampf(position.x+1, 1, WIDTH)] == nil then
        return self:SpreadRight(particle_table, position, parent)
    end
    return position
end


return fluid_component