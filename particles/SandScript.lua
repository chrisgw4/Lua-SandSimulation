local Vector2 = require("Vector2Script")
local GravityComponent = require("Components.GravityMovementComponent")
local Color = require("ColorScript")

local sand = {}

sand.__index = sand
sand.name = "Sand"



function sand.new(x, y, index)
    local myClass = setmetatable({}, sand)

    myClass.position = Vector2.new(x, y)
    myClass.velocity = 1
    myClass.type = 1

    myClass.grav_component = GravityComponent.new(true)

    -- The wetness counter keeps track of how wet the sand particle is and what color it should be
    myClass.wetness = 0
    myClass.dry_timer = 40 -- Keeps track of how long it takes to go down 1 wetness
    myClass.dry_counter = math.random(0, myClass.dry_timer+1) -- Will count each changeColor call in order to dry the sand

    -- Color keeps track of the color the sand should be based on its wetness
    myClass.color = Color.new(1, 1, 0.6862745098039216, 1)

    return myClass 
end

function sand:getPosition()
    return self.position
end


function sand:FallLeft(particle_table)
    -- Check if left side is open, then we fall
    if particle_table[self.position.y][Clampf(self.position.x-1, 1, WIDTH)] == nil then
        -- Check left and down one
        if particle_table[Clampf(self.position.y+1, 1, HEIGHT)][Clampf(self.position.x-1, 1, WIDTH)] == nil  then
            -- Set the previous point the sand was at to 0
            particle_table[self.position.y][self.position.x] = nil

            -- Increment the current position
            self.position.y = Clampf(self.position.y + 1, 1, HEIGHT)
            self.position.x = Clampf(self.position.x - 1, 1, WIDTH)

            -- Set the new point the sand is at to 1 (occupied)
            particle_table[self.position.y][self.position.x] = self
        end
    end
end

function sand:FallRight(particle_table)
    -- Check if right side is open, then we fall
    if particle_table[self.position.y][Clampf(self.position.x+1, 1, WIDTH)] == nil then
        -- Check right and down one
        if particle_table[Clampf(self.position.y+1, 1, WIDTH)][Clampf(self.position.x+1, 1, WIDTH)] == nil  then
            -- Set the previous point the sand was at to 0
            particle_table[self.position.y][self.position.x] = nil

            -- Increment the current position
            self.position.y = Clampf(self.position.y + 1, 1, HEIGHT)
            self.position.x = Clampf(self.position.x + 1, 1, WIDTH)

            -- Set the new point the sand is at to 1 (occupied)
            particle_table[self.position.y][self.position.x] = self
        end
    end
end

function sand:FallToSide(particle_table)
    
    -- if there are not any particles to the left and right of current particle, we can fall to both sides
    if particle_table[self.position.y][Clampf(self.position.x-1, 1, WIDTH)] == nil and particle_table[self.position.y][Clampf(self.position.x+1, 1, WIDTH)] == nil then
        -- Use a random variable to help split the falling to both sides evenly
        local val = Clampf(math.random(0, 2)+0.5, 0, 1)
        if val == 0 then
            self:FallLeft(particle_table)
        else
            self:FallRight(particle_table)
        end
    elseif particle_table[self.position.y][Clampf(self.position.x-1, 1, WIDTH)] ~= nil and particle_table[self.position.y][Clampf(self.position.x+1, 1, WIDTH)] ~= nil then

    elseif particle_table[self.position.y][Clampf(self.position.x-1, 1, WIDTH)] == nil then
        self:FallLeft(particle_table)
    else
        self:FallRight(particle_table)
    end
end

function sand:Update(particle_table)
    --if self.position.y < #particle_table and self.position.x < #particle_table then

        -- Check the spot immediately below the particle and if its filled return early to not waste time in for loop
        if particle_table[Clampf(self.position.y+1, 1, HEIGHT)][self.position.x] ~= nil and particle_table[Clampf(self.position.y+1, 1, HEIGHT)][self.position.x].type ~= 2 then
            self:FallToSide(particle_table)
            self.velocity = 1
            return
        end

    
        -- Use gravity Component to let the particle fall
        self.position = self.grav_component:FallDown(particle_table, self.position, self)

end


-- This will change the color of the water dependent on how much is above it
function sand:changeColor(particle_table)
    
    if InBounds(self.position.y-1, self.position.x) and IsSpaceOccupied(self.position.y-1, self.position.x) then
        -- Check if the particle above is a water particle
        if particle_table[self.position.y-1][self.position.x] ~= nil and particle_table[self.position.y-1][self.position.x].type == 2 then
            self.wetness = Clampf(self.wetness+1, 0, 16)
        -- Check if the particle to the above is a sand particle
        elseif  particle_table[self.position.y-1][self.position.x] ~= nil and particle_table[self.position.y-1][self.position.x].type == 1 then
            self.wetness = Clampf(particle_table[self.position.y-1][self.position.x].wetness - 1, 0, 100)
            
        end
    end

    if InBounds(self.position.y+1, self.position.x) and IsSpaceOccupied(self.position.y+1, self.position.x) then
        -- Check if the particle above is a water particle
        if particle_table[self.position.y+1][self.position.x] ~= nil and particle_table[self.position.y+1][self.position.x].type == 2 then
            self.wetness = Clampf(self.wetness+1, 0, 16)
        -- Check if the particle to the above is a sand particle
        elseif  particle_table[self.position.y+1][self.position.x] ~= nil and particle_table[self.position.y+1][self.position.x].type == 1 then
            self.wetness = math.max(Clampf(particle_table[self.position.y+1][self.position.x].wetness - 1, 0, 100), self.wetness)
            
        end
    end

    
    if InBounds(self.position.y, self.position.x+1) and IsSpaceOccupied(self.position.y, self.position.x+1) and particle_table[self.position.y][self.position.x+1] ~= nil then
        -- Check if the particle to the right is a water particle
        if particle_table[self.position.y][self.position.x+1].type == 2 then
            self.wetness = Clampf(self.wetness+1, 0, 16)
        -- Check if the particle to the left is a sand particle
        elseif particle_table[self.position.y][self.position.x+1].type == 1 then
            self.wetness = math.max(Clampf(particle_table[self.position.y][self.position.x+1].wetness - 1, 0, 100), self.wetness)
        end
    end

    if InBounds(self.position.y, self.position.x-1) and IsSpaceOccupied(self.position.y, self.position.x-1) and particle_table[self.position.y][self.position.x-1] ~= nil then
        -- Check if the particle to the left is a water particle
        if particle_table[self.position.y][self.position.x-1].type == 2 then
            self.wetness = Clampf(self.wetness+1, 0, 16)
        -- Check if the particle to the left is a sand particle
        elseif particle_table[self.position.y][self.position.x-1].type == 1 then
            self.wetness = math.max(Clampf(particle_table[self.position.y][self.position.x-1].wetness - 1, 0, 100), self.wetness)
        end
    end


    -- Determine color based on the depthCount
    if self.wetness <= 1 then --math.random( 1, 4 ) then
        -- #ffffaf HexCode for color
        self.color:changeColor(1, 1, 0.6862745098039216, self.color.a)
    elseif self.wetness <= 6 then -- math.random( 12, 18 ) then
        -- #dbdb9a HexCode for color
        self.color:changeColor(0.8588235294117647, 0.8588235294117647, 0.6039215686274509, self.color.a)
        
    elseif self.wetness <= 12 then --math.random( 5, 9 ) then
        -- #baba80 HexCode for color
        self.color:changeColor(0.7294117647058823, 0.7294117647058823, 0.5019607843137255, self.color.a)
        
    elseif self.wetness <= 16 then -- math.random( 12, 18 ) then
        -- #8a8a60 HexCode for color
        self.color:changeColor(0.5411764705882353, 0.5411764705882353, 0.3764705882352941, self.color.a)
    
    end
    

    -- Increment the dry_counter
    self.dry_counter = self.dry_counter + 1

    -- Check if the wetness should go down a level
    if self.dry_counter >= self.dry_timer then
        self.dry_counter = 0
        self.wetness = self.wetness - 1
    end

    
end



function sand:Draw(batch, particle_table)
    --batch:setColor(1, 0.8941176470588236, 0.49411764705882355).
    --batch:setColor(1, 1, 0.6862745098039216) -- #ffffaf HexCode for color
    self:changeColor(particle_table)
    batch:setColor(self.color.r, self.color.g, self.color.b, self.color.a)
    batch:add((self.position.x-1)*SCALE, (self.position.y)*SCALE, 0, SCALE, SCALE, 0)
end

return sand