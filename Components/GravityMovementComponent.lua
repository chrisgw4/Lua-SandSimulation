local Vector2 = require("Vector2Script")

local gravity_component = {}

gravity_component.__index = gravity_component


function gravity_component.new(pass_through_water, pass_through_types, density)
    local myClass = setmetatable({}, gravity_component)

    myClass.HEIGHT = HEIGHT
    myClass.WIDTH = WIDTH

    myClass.InBounds = InBounds
    myClass.IsSpaceOccupied = IsSpaceOccupied

    myClass.Clampf = Clampf
    myClass.ClampHeight = ClampHeight


    myClass.pass_through_types = pass_through_types
    myClass.velocity = 1

    myClass.density = density
    
    

    return myClass
end


function gravity_component:canPassThroughType(type)
   for i=1, #self.pass_through_types do
        if self.pass_through_types[i] == type then
            return true
        end
   end 
   return false
end


function gravity_component:FallDown(particle_table, position, parent)
    


    -- Do this if the Velocity is pulling the particle Upward
    if self.velocity < 0 then
        local max_fall = 0
        local max_fall_through = 0

        -- Start from -1 to Velocity and go down in values to see how far up the particle wil lgo
        for i = -1, self.velocity, -1 do
            -- Check if position.y+i is in of bounds
            if position.y+i > 0 then
                local temp = particle_table[position.y+i][position.x]

                -- If there is nothing at the current falling position, we can increase the distance of the fall
                if temp == nil then --IsSpaceOccupied(position.y+i, position.x) == false then
                    max_fall = i -- store the farthest fall the particle can go
                -- Check if the particle in the position to fall is in the pass through list
                elseif parent.density > temp.density then--self:canPassThroughType(particle_table[position.y+i][position.x].type) then
                    max_fall_through = i
                else
                    self.velocity = 0
                    break
                end
            -- If the position.y+i is out of bounds
            else
                self.velocity = 0
                break
            end
            

            -- If the particle will fall through another particle and displace it
            if max_fall_through ~= 0 then
                -- Check if the location to fall to is in bounds
                if position.y+max_fall_through > 0 then -- InBounds(position.y+max_fall_through, position.x, self.HEIGHT, self.WIDTH) then

                    -- Set the last position to nil
                    particle_table[position.y][position.x] = nil
                    
                    -- Call displacement on the particle that is being moved out of the way
                    particle_table[(position.y+max_fall_through)][position.x]:Displace(particle_table, Vector2.new(position.x, (position.y + max_fall_through)), max_fall_through)
                    
                    -- Update the y position of the current falling particle
                    position.y = (position.y + max_fall_through)
                end
            -- If just falling through the air
            else
                -- Set last position to nil
                particle_table[position.y][position.x] = nil

                -- Update the y position of the current falling particle
                position.y = self.ClampHeight(position.y + max_fall)
            
                
                
            end
            -- Update the particle table to have the current position for the particle
            particle_table[position.y][position.x] = parent
            self.velocity = self.Clampf(self.velocity + 1, self.velocity, 12)
            return position

            
            
        end
    end

    

    -- Do this if the Velocity is pulling the particle Downward
    if self.velocity >= 0 then

        local max_fall = 0
        local max_fall_through = 0
        for i = 1, self.velocity do
            if position.y+i < self.HEIGHT then
                local temp = particle_table[position.y+i][position.x]
                -- If there is nothing at the current falling position, we can increase the distance of the fall
                if temp == nil then --IsSpaceOccupied(position.y+i, position.x) == false then
                    max_fall = i -- store the farthest fall the particle can go
                -- Check if the particle in the position to fall is in the pass through list
                elseif parent.density > temp.density then --and self:canPassThroughType(particle_table[position.y+i][position.x].type) then
                    max_fall_through = i
                    
                else
                    self.velocity = 0
                    break
                end
            else
                self.velocity = 0
                break
            end
        end

    
        -- If the particle will fall through another particle and displace it
        if max_fall_through ~= 0 then
            -- Check if the location to fall to is in bounds
            if position.y+max_fall_through < self.HEIGHT then -- InBounds(position.y+max_fall_through, position.x, self.HEIGHT, self.WIDTH) then

                -- Set the last position to nil
                particle_table[position.y][position.x] = nil
                
                -- Call displacement on the particle that is being moved out of the way
                particle_table[(position.y+max_fall_through)][position.x]:Displace(particle_table, Vector2.new(position.x, (position.y + max_fall_through)), max_fall_through)
                
                -- Update the y position of the current falling particle
                position.y = (position.y + max_fall_through)
            end
        -- If just falling through the air
        else
            -- Set last position to nil
            particle_table[position.y][position.x] = nil

            -- Update the y position of the current falling particle
            position.y = position.y + max_fall
        
            
            
        end
        -- Update the particle table to have the current position for the particle
        particle_table[position.y][position.x] = parent
        self.velocity = self.Clampf(self.velocity + 1, 1, 12)
        return position
    end
end


return gravity_component