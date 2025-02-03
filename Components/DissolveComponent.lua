local Vector2 = require("Vector2Script")

local dissolve_component = {}

dissolve_component.__index = dissolve_component


function dissolve_component.new(type, chance)
    local myClass = setmetatable({}, dissolve_component)

    myClass.type_to_dissolve = type
    myClass.chance_to_dissolve = chance
    
    return myClass
end

function dissolve_component:Dissolve(particle_table, position)
    
    -- Check the adjacent particles

    
    if InBounds(position.y+1, position.x) and IsSpaceOccupied(position.y+1, position.x) then -- Check the space below
        if particle_table[position.y+1][position.x].type == self.type_to_dissolve then
            local chance = math.random(0, 10000) -- Calculate chance to dissolve material
            if chance >= self.chance_to_dissolve then
                AddToDeleteQueue(particle_table[position.y+1][position.x])
                
            end
        end
    
    elseif InBounds(position.y, position.x+1) and IsSpaceOccupied(position.y, position.x+1) then -- Check the space to the right
        if particle_table[position.y][position.x+1].type == self.type_to_dissolve then
            local chance = math.random(0, 10000) -- Calculate chance to dissolve material
            if chance >= self.chance_to_dissolve then
                AddToDeleteQueue(particle_table[position.y][position.x+1])
                
            end
        end
    
    elseif InBounds(position.y, position.x-1) and IsSpaceOccupied(position.y, position.x-1) then -- Check the to the left
        if particle_table[position.y][position.x-1].type == self.type_to_dissolve then
            local chance = math.random(0, 10000) -- Calculate chance to dissolve material
            if chance >= self.chance_to_dissolve then
                AddToDeleteQueue(particle_table[position.y][position.x-1])
                
            end
        end
    end


end


return dissolve_component