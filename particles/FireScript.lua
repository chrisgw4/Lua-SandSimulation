local Vector2 = require("Vector2Script")
local Color = require("ColorScript")
local GravityComponent = require("Components.GravityMovementComponent")
local DisplacementComponent = require("Components.DisplacementComponent")
local fire = {}

fire.__index = fire
fire.name = "Fire"


function fire.new(x, y, life_time, float_on_liquid)
    local myClass = setmetatable({}, fire)

    myClass.displace_component = DisplacementComponent.new()

    -- Density is -100 since it should float on everything
    myClass.density = -100

    myClass.position = Vector2.new(x, y)
    myClass.type = 5

    myClass.Random = math.random
    myClass.Min = math.min
    myClass.Max = math.min
    myClass.Clamp = Clamp

    -- #d45c00
    myClass.color = Color.new(myClass.Clamp(myClass.Random(), 0.8313725490196079, 0.8413725490196079), myClass.Clamp(myClass.Random(), 0.3607843137254902, 0.3707843137254902), 0, 0.75)
    
    myClass.SCALE = SCALE
    myClass.WIDTH = WIDTH
    myClass.HEIGHT = HEIGHT

    myClass.gravity_component = GravityComponent.new(false, {0}, myClass.density)

    myClass.flight_time = 0
    myClass.flight_time_max = 10


    -- How central the fire is. The more central it is the whiter it is (More bright)
    myClass.centrality = 0

    -- The time it takes to update the color of the particle
    myClass.color_update_timer = 1
    myClass.color_update_clock = myClass.Random(0, myClass.color_update_timer) -- Stagger the updates to help prevent lag

    -- The time it takes for the fire particle to disappear
    myClass.lifetime_timer = 100
    myClass.lifetime_clock = myClass.Random(0, myClass.lifetime_timer*myClass.Clamp(myClass.Random(), 0.1, 1)) -- Stagger the times so they disappear at random times

    myClass.chance_to_flake = 0.006
    myClass.is_flaking = false

    myClass.AddDelete = AddToDeleteQueue
    

    return myClass 
end

function fire:getPosition()
    return self.position
end

-- Displace function is called when a particle lands where this particle was and so this particle must be moved out of the way
    function fire:Displace(particle_table, position, distance)
        self.position = self.displace_component:Displace(particle_table, self.position, self, distance)
    end

-- Check if there is a fire particle on one side and air on the other, and flake off, have a little upwards velocity and horizontal, and change color. Then after a bit go out
function fire:FlakeOut(particle_table)

    -- Make a local variable to store the particles touching the current one
    -- Have -1 be default value, to differentiate between air and nothing
    local particle_west = -1
    local particle_east = -1
    local particle_north = -1
    local particle_south = -1
    -- End local variable creation


    -- #region Get Particles surrounding current particle
    -- Check if left is in range
    if self.position.x-1 > 0 then
        particle_west = particle_table[self.position.y][self.position.x-1]
    end

    -- Check if right is in range
    if self.position.x+1 < self.WIDTH then
        particle_east = particle_table[self.position.y][self.position.x+1]
    end

    -- Check if up is in range
    if self.position.y-1 > 0 then
        particle_north = particle_table[self.position.y-1][self.position.x]
    end

    -- Check if down is in range
    if self.position.y+1 < self.HEIGHT then
        particle_south = particle_table[self.position.y+1][self.position.x]
    end
    -- #endregion

    -- Check if particle to the left is a Fire Particle
    if particle_west ~= nil and particle_west ~= -1 and particle_west.type == 5 then -- The West Particle is Fire
        -- Check if particle to the right is an air particle
        if particle_east == nil and particle_east ~= -1 then -- The East Particle is Air
            
            if self.Random() < self.chance_to_flake then
                -- print("West to East")
                self.gravity_component.velocity = -self.Random(64, 97)
                self.is_flaking = true
            end
            
        end
        
    

    -- Check if particle to the right is a Fire Particle
    elseif particle_east ~= nil and particle_east ~= -1 and particle_east.type == 5 then
        -- Check if particle to the left is an air particle
        if particle_west == nil and particle_west ~= -1 then -- The West Particle is Air
            
            if self.Random() < self.chance_to_flake then
                -- print("East to West")
                self.gravity_component.velocity = -self.Random(64, 97)
                self.is_flaking = true
            end
            
        end
    

    -- Check if particle to the down is a Fire Particle
    elseif particle_south ~= nil and particle_south ~= -1 and particle_south.type == 5 then
        -- Check if particle to the above is an air particle
        if particle_north == nil and particle_north ~= -1 then -- The North Particle is Air
            
            if self.Random() < self.chance_to_flake then
                self.gravity_component.velocity = -self.Random(64, 97)
                self.is_flaking = true
            end
            
        end
    end

    -- Check if particle to the up is a Fire Particle
    if particle_north ~= nil and particle_north ~= -1 and particle_north.type == 5 then
        
    end

end

-- Let the fire particle shift around when its floating in the air
function fire:ShiftAround(particle_table)
    if self.gravity_component.velocity >= 0 and self.color.a < 1 and self.is_flaking then
        self.AddDelete(self)
        return
    end
    if self.gravity_component.velocity >= 0 then
        return
    end

    local rand = self.Random()

    -- Change the alpha level of the Particle by a random amount each time
    self.color.a = self.color.a - self.Clamp(rand, 0.0075, 0.015)

    -- Add the particle to be deleted since it is no longer visible
    if self.color.a <= 0 then
        self.AddDelete(self)
        return
    end

    if rand < 0.12800 then
        if self.position.x+1 < self.WIDTH and particle_table[self.position.y][self.position.x+1] == nil then
            particle_table[self.position.y][self.position.x] = nil
            self.position.x = self.position.x + 1
            particle_table[self.position.y][self.position.x] = self
        end
    elseif rand < 0.25600 then
        if self.position.x-1 > 0 and particle_table[self.position.y][self.position.x-1] == nil then
                particle_table[self.position.y][self.position.x] = nil
                self.position.x = self.position.x -1
                particle_table[self.position.y][self.position.x] = self
        end
    end

end


-- Update properties about the fire particle
function fire:Update(particle_table)

    -- Cause Fire particles to flake out from the bunch
    self:FlakeOut(particle_table)

    -- Call for the gravity to change where the particle is
    self.position = self.gravity_component:FallDown(particle_table, self.position, self)
    self:ShiftAround(particle_table)

    if self.gravity_component.velocity < 0 then
        return
    end

    if self.lifetime_clock < self.lifetime_timer then
        self.lifetime_clock = self.lifetime_clock + 1
        -- self.color.a = 1.2-self.lifetime_clock/self.lifetime_timer
        return
    end
    self.AddDelete(self)

end



-- This will change the color of the fire dependent on how much is around it
function fire:changeColor(particle_table)

    if self.color_update_clock < self.color_update_timer then
        self.color_update_clock = self.color_update_clock + 1
        return
    end
    self.color_update_clock = 0

    -- Make a local variable to store the particles touching the current one
    -- Have -1 be default value, to differentiate between air (nil) and nothing (-1). Incase an index is out of bounds, default is -1
    local particle_west = -1
    local particle_east = -1
    local particle_north = -1
    local particle_south = -1
    -- End local variable creation


    --  Get Particles surrounding current particle #region
    -- Check if left is in range
    if self.position.x-1 > 0 then
        particle_west = particle_table[self.position.y][self.position.x-1]
    end

    -- Check if right is in range
    if self.position.x+1 < self.WIDTH then
        particle_east = particle_table[self.position.y][self.position.x+1]
    end

    -- Check if up is in range
    if self.position.y-1 > 0 then
        particle_north = particle_table[self.position.y-1][self.position.x]
    end

    -- Check if down is in range
    if self.position.y+1 < self.HEIGHT then
        particle_south = particle_table[self.position.y+1][self.position.x]
    end
    -- #endregion

    -- Store the minimum Centrality value in min_value
    local min_value = 999999


    -- Check if any of the surrounding prticles is air #region 

    -- Check if particle to the left is air
    if particle_west == nil then -- The West Particle is air
        min_value = 0        
    end

    -- Check if particle to the right is air
    if particle_east == nil then -- The East Particle is air
        min_value = 0        
    end

    -- Check if particle to the down is air
    if particle_south == nil then -- The South Particle is air
        min_value = 0        
    end

     -- Check if particle to the up is air
     if particle_north == nil then -- The North Particle is air
        min_value = 0        
    end
    -- #endregion

    

    -- Check if any of the surrounding particles is fire #region
    if min_value ~= 0 then
        -- Check if particle to the left is fire
        if particle_west ~= nil and particle_west ~= -1 and particle_west.type == 5 then -- The West Particle is fire
            min_value = self.Max(min_value, particle_west.centrality+1) -- get the minimum of centrality     
        end

        -- Check if particle to the right is fire
        if particle_east ~= nil and particle_east ~= -1 and  particle_east.type == 5 then -- The East Particle is fire
            min_value = self.Max(min_value, particle_east.centrality+1) -- get the minimum of centrality 
        end

        -- Check if particle to the down is fire
        if particle_south ~= nil and particle_south ~= -1 and particle_south.type == 5 then -- The South Particle is fire
            min_value = self.Max(min_value, particle_south.centrality+1) -- get the minimum of centrality 
        end

        -- Check if particle to the up is air
        if particle_north ~= nil and particle_north ~= -1 and particle_north.type == 5 then -- The North Particle is fire 
            min_value = self.Max(min_value, particle_north.centrality+1) -- get the minimum of centrality    
        end
    end

    

    -- #endregion

    -- -- If the particle is directly exposed to air, then we dont want to mess with it
    -- if min_value > 0 then
    --     self.centrality = self.Clamp(self.centrality + 1, 0, 20)
    -- end
        -- print(min_value)
    if min_value < 2 then
        -- #d40e00 Hexcode for Color
        self.color = Color.new(0.8313725490196079, 0.054901960784313725, 0, self.color.a)
    elseif min_value < 4 then
        -- #d45800 Hexcode for Color
        self.color = Color.new(0.8313725490196079, 0.34509803921568627, 0, self.color.a)
    elseif min_value < 6 then
        -- #faee66 Hexcode for Color
        self.color = Color.new(0.9803921568627451, 0.9333333333333333, 0.4, self.color.a)
    elseif min_value < 8 then
        -- #fff9b8 Hexcode for Color
        self.color = Color.new(1, 0.9764705882352941, 0.7215686274509804, self.color.a)
    end
    self.centrality = min_value
end

function fire:Draw(batch, particle_table)
    self:changeColor(particle_table)
    batch:setColor(self.color.r, self.color.g, self.color.b, self.color.a)
    batch:add((self.position.x-1)*self.SCALE, (self.position.y)*self.SCALE, 0, self.SCALE, self.SCALE, 0)
end




return fire