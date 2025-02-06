local Vector2 = require("Vector2Script")

local fluid_component = {}

fluid_component.__index = fluid_component


function fluid_component.new(spread_out_through_types)
    local myClass = setmetatable({}, fluid_component)

    
    myClass.spread_out_through_types = spread_out_through_types
    myClass.velocity = 1

    myClass.Clampf = Clampf
    myClass.WIDTH = WIDTH
    

    return myClass
end


function fluid_component:canPassThroughType(type)
    -- print(self)

    for i=1, #self.spread_out_through_types do
         if self.spread_out_through_types[i] == type then
            return true
         end
    end 
    return false
 end
 


function fluid_component:SpreadLeft(particle_table, position, parent)
    -- Check if left side is open, then we move
    --if particle_table[position.y][self.Clampf(position.x-1, 1, self.WIDTH)] == nil or self:canPassThroughType(particle_table[position.y][self.Clampf(position.x-1, 1, self.WIDTH)].type) then
        -- Set the previous point the fluid was at to nil
        particle_table[position.y][position.x] = nil

        -- Check if the spot is occupied
        if particle_table[position.y][self.Clampf(position.x-1, 1, self.WIDTH)] ~= nil then
            -- Move the spot for the acid to move
            particle_table[position.y][self.Clampf(position.x, 1, self.WIDTH)] = particle_table[position.y][self.Clampf(position.x-1, 1, self.WIDTH)]
            particle_table[position.y][self.Clampf(position.x, 1, self.WIDTH)].position.x = position.x
            particle_table[position.y][self.Clampf(position.x, 1, self.WIDTH)].position.y = position.y
            -- particle_table[position.y][self.Clampf(position.x-1, 1, self.WIDTH)]:Displace(particle_table, position, position.y, 60)
            particle_table[position.y][self.Clampf(position.x-1, 1, self.WIDTH)] = nil
        end

        -- Increment the current position
        position.x = self.Clampf(position.x - 1, 1, self.WIDTH)

        -- Set the new point the fluid is at to parent (occupied)
        particle_table[position.y][position.x] = parent
    --end
    return position
end

function fluid_component:SpreadRight(particle_table, position, parent)
     -- Check if left side is open, then we move
    --if particle_table[position.y][self.Clampf(position.x+1, 1, self.WIDTH)] == nil then
        -- Set the previous point the fluid was at to nil
        particle_table[position.y][position.x] = nil

        -- Check if the spot is occupied
        if particle_table[position.y][self.Clampf(position.x+1, 1, self.WIDTH)] ~= nil then

            -- Move the spot for the acid to move
            particle_table[position.y][self.Clampf(position.x, 1, self.WIDTH)] = particle_table[position.y][self.Clampf(position.x+1, 1, self.WIDTH)]
            particle_table[position.y][self.Clampf(position.x, 1, self.WIDTH)].position.x = position.x
            particle_table[position.y][self.Clampf(position.x, 1, self.WIDTH)].position.y = position.y
            -- particle_table[position.y][self.Clampf(position.x+1, 1, self.WIDTH)]:Displace(particle_table, position, 60)
        end

        -- Increment the current position
        position.x = self.Clampf(position.x + 1, 1, self.WIDTH)

        -- Set the new point the fluid is at to parent (occupied)
        particle_table[position.y][position.x] = parent
    --end
    return position
end

-- Spreads out the fluid to the left and right --
function fluid_component:SpreadOut(particle_table, position, parent)
    
    -- Checks the left and right to see if they are both free spaces --
    if position.x-1 > 0 and position.x+1 < self.WIDTH and particle_table[position.y][self.Clampf(position.x-1, 1, self.WIDTH)] == nil and particle_table[position.y][position.x+1] == nil then
        -- randomizes the direction to go if both directions are free --
        local val = self.Clampf(math.random(0, 2)+0.5, 0, 1)
        if val == 0 then
            return self:SpreadLeft(particle_table, position, parent)
        else
            return self:SpreadRight(particle_table, position, parent)
        end
    elseif position.x-1 > 0 and position.x+1 < self.WIDTH and particle_table[position.y][position.x-1] ~= nil and particle_table[position.y][position.x+1] ~= nil and parent.density > particle_table[position.y][position.x+1].density and parent.density > particle_table[position.y][position.x-1].density then--and self:canPassThroughType(particle_table[position.y][self.Clampf(position.x+1, 1, self.WIDTH)].type) and self:canPassThroughType(particle_table[position.y][self.Clampf(position.x-1, 1, self.WIDTH)].type) then
        -- randomizes the direction to go if both directions are free --
        local val = self.Clampf(math.random(0, 2)+0.5, 0, 1)
        if val == 0 then
            return self:SpreadLeft(particle_table, position, parent)
        else
            return self:SpreadRight(particle_table, position, parent)
        end

    -- Checks left
    elseif position.x-1 > 0 and (particle_table[position.y][position.x-1] == nil or parent.density > particle_table[position.y][position.x-1].density) then --or self:canPassThroughType(particle_table[position.y][self.Clampf(position.x-1, 1, self.WIDTH)].type) then
        
        return self:SpreadLeft(particle_table, position, parent)
    -- Checks right
    elseif position.x+1 <= self.WIDTH and (particle_table[position.y][position.x+1] == nil or parent.density > particle_table[position.y][position.x+1].density) then --or self:canPassThroughType(particle_table[position.y][self.Clampf(position.x+1, 1, self.WIDTH)].type) then
        return self:SpreadRight(particle_table, position, parent)
    end

    

    return position
end


return fluid_component