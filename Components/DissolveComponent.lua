local Vector2 = require("Vector2Script")

local dissolve_component = {}

dissolve_component.__index = dissolve_component


function dissolve_component.new(type, chance)
    local myClass = setmetatable({}, dissolve_component)

    myClass.type_to_dissolve = type
    myClass.chance_to_dissolve = chance
    
    myClass.HEIGHT = HEIGHT
    myClass.WIDTH = WIDTH
    myClass.Random = math.random

    myClass.AddDelete = AddToDeleteQueue

    myClass.dissolve_timer = 30
    myClass.dissolve_clock = myClass.Random(0, myClass.dissolve_timer)
    return myClass
end

function dissolve_component:Dissolve(particle_table, position)
    
    if self.dissolve_clock < self.dissolve_timer then
        self.dissolve_clock = self.dissolve_clock + 1
        return
    end
    self.dissolve_clock = 0

    -- Make local variables for the particles surrounding this one
    local particle_south = nil
    local particle_east = nil
    local particle_west = nil

    if position.y+1 < self.HEIGHT then
        particle_south = particle_table[position.y+1][position.x]
    end
    if position.x+1 < self.WIDTH then
        particle_east = particle_table[position.y][position.x+1]
    end
    if position.x-1 > 0 then
        particle_west = particle_table[position.y][position.x-1]
    end

    -- Check the adjacent particles

    
    if particle_south ~= nil then -- IsSpaceOccupied(position.y+1, position.x) then -- Check the space below
        if particle_south.type == self.type_to_dissolve then
            local chance = self.Random() -- Calculate chance to dissolve material
            if chance < self.chance_to_dissolve then
                self.AddDelete(particle_south)
                
            end
        end
    
    elseif particle_east ~= nil then --IsSpaceOccupied(position.y, position.x+1) then -- Check the space to the right
        if particle_east.type == self.type_to_dissolve then
            local chance = self.Random() -- Calculate chance to dissolve material
            if chance < self.chance_to_dissolve then
                self.AddDelete(particle_east)
                
            end
        end
    
    elseif particle_west ~= nil then -- IsSpaceOccupied(position.y, position.x-1) then -- Check the to the left
        if particle_west.type == self.type_to_dissolve then
            local chance = self.Random() -- Calculate chance to dissolve material
            if chance < self.chance_to_dissolve then
                self.AddDelete(particle_west)
                
            end
        end
    end


end


return dissolve_component