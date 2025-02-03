local Vector2 = require("Vector2Script")

local gravity_component = {}

gravity_component.__index = gravity_component


function gravity_component.new(pass_through_water)
    local myClass = setmetatable({}, gravity_component)

    myClass.velocity = 1
    myClass.pass_through_water = pass_through_water
    return myClass
end

function gravity_component:FallDown(particle_table, position, parent)
    -- Check how far the particle can fall with its velocity before hitting something
    -- for i=self.velocity,1, -1 do
    --     -- Checks if block below is free or if it is water, but can only pass through water with the boolean pass_through_water
    --     if particle_table[Clampf(position.y+i, 1, HEIGHT-1)][position.x] == nil or (particle_table[Clampf(position.y+i, 1, HEIGHT-1)][position.x].type == 2 and self.pass_through_water) then
            
    --         -- Set the previous point the sand was at to 0
    --         particle_table[position.y][position.x] = nil

    --         -- If the particle in the way is a fluid we can displace it
    --         if (particle_table[Clampf(position.y+i, 1, HEIGHT-1)][position.x] ~= nil and particle_table[Clampf(position.y+i, 1, HEIGHT-1)][position.x].type == 2) then
    --             particle_table[Clampf(position.y+i, 1, HEIGHT-1)][position.x]:Displace(particle_table, Vector2.new(position.x, Clampf(position.y + i, 1, HEIGHT-1)), i)
    --         end
            
            

    --         -- Increment the current position
    --         position.y = Clampf(position.y + i, 1, HEIGHT-1)

    --         -- Set the new point the sand is at to 1 (occupied)
    --         particle_table[position.y][position.x] = parent

    --         -- Increase velocity as it falls (to mimic gravity)
    --         self.velocity = self.velocity + 1
    --         break
    --     end
    -- end

    local max_fall = 0
    local max_fall_through = 0
    local pass_through_flag = false
    for i = 1, self.velocity do
        -- If there is nothing at the current falling position, we can increase the distance of the fall
        if InBounds(position.y+i, position.x) and IsSpaceOccupied(position.y+i, position.x) == false then
            max_fall = i -- store the farthest fall the particle can go
            pass_through_flag = false
        elseif InBounds(position.y+i, position.x) and IsSpaceOccupied(position.y+i, position.x) == true and particle_table[position.y+i][position.x].type == 2 and self.pass_through_water then
            max_fall_through = i
            pass_through_flag = true
        else
            self.velocity = 0
            break
        end
    end

    -- local new_pos = Vector2.new(position.x, position.y)

    -- for i = 1,self.velocity do
    --     -- Checks if block below is free or if it is water, but can only pass through water with the boolean pass_through_water
    --     if not IsSpaceOccupied(position.y+i, position.x) then --or (particle_table[Clampf(position.y+i, 1, HEIGHT-1)][position.x].type == 2 and self.pass_through_water) then
            
            

    --         -- If the particle in the way is a fluid we can displace it
    --         -- if (particle_table[Clampf(position.y+i, 1, HEIGHT-1)][position.x].type == 2) then
    --         --     particle_table[Clampf(position.y+i, 1, HEIGHT-1)][position.x]:Displace(particle_table, Vector2.new(position.x, Clampf(position.y + i, 1, HEIGHT-1)), i)
    --         -- end
            
            

    --         -- Increment the current position
    --         new_pos.y = Clampf(position.y + i, 1, HEIGHT-1)

            

            
            
    --     end
    -- end
    -- -- Set the previous point the sand was at to 0
    -- particle_table[position.y][position.x] = nil
    -- -- Set the new point the sand is at to 1 (occupied)
    -- particle_table[new_pos.y][new_pos.x] = parent
    -- -- Increase velocity as it falls (to mimic gravity)
    
    -- If the particle will fall through another particle and displace it
    if max_fall_through ~= 0 and pass_through_flag then
        -- Check if the location to fall to is in bounds
        if InBounds(position.y+max_fall_through, position.x) then

            -- Set the last position to nil
            particle_table[position.y][position.x] = nil
            
            -- Call displacement on the particle that is being moved out of the way
            particle_table[ClampHeight(position.y+max_fall_through)][position.x]:Displace(particle_table, Vector2.new(position.x, ClampHeight(position.y + max_fall_through)), max_fall_through)
            
            -- Update the y position of the current falling particle
            position.y = ClampHeight(position.y + max_fall_through)
        end
    -- If just falling through the air
    else
        -- Set last position to nil
        particle_table[position.y][position.x] = nil

        -- Update the y position of the current falling particle
        position.y = ClampHeight(position.y + max_fall)
    
        
        
    end
    -- Update the particle table to have the current position for the particle
    particle_table[position.y][position.x] = parent
    self.velocity = Clampf(self.velocity + 1, 1, 100)
    return position
end


return gravity_component