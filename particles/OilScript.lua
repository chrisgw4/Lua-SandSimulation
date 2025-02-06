local Vector2 = require("Vector2Script")
local GravityComponent = require("Components.GravityMovementComponent")
local FluidComponent = require("Components.FluidSpreadOutComponent")
local DisplacementComponent = require("Components.DisplacementComponent")
local Color = require("ColorScript")
local DissolveComponent = require("Components.DissolveComponent")

local oil = {}

oil.__index = oil
oil.name = "Oil"

function oil.new(x, y)
    local myClass = setmetatable({}, oil)

    myClass.position = Vector2.new(x, y)
    myClass.velocity = 1
    myClass.type = 7

    -- Oil has -1 density, since it should float on water
    myClass.density = -2

    myClass.grav_component = GravityComponent.new(false, {0}, myClass.density)

    myClass.fluid_component = FluidComponent.new({2})
    
    myClass.displace_component = DisplacementComponent.new()

    -- Default Color #03fc6b Hexcode
    myClass.color = Color.new(0.050980392156862744, 0.050980392156862744, 0.058823529411764705, 0.9)

    -- Depth variable will contain which level of color the current water particle is associated with
    myClass.depth = 0

    myClass.Clampf = Clampf
    myClass.HEIGHT = HEIGHT
    myClass.SCALE = SCALE


    myClass.depthCount = 0 -- How many layers down the particle is from other water particles

    myClass.previous_position = Vector2.new(x, y)
    
    -- Will allow the depth to be updated every so often
    myClass.depthUpdateTimer = 2
    myClass.depthUpdateClock = math.random(0, myClass.depthUpdateTimer)

    myClass.dissolve_component = DissolveComponent.new(3, 0.015)

    return myClass
end

function oil:getPosition()
    return self.position
end

-- Displace function is called when a particle lands where this particle was and so this particle must be moved out of the way
function oil:Displace(particle_table, position, distance)
    self.position = self.displace_component:Displace(particle_table, self.position, self, distance)
end


function oil:Update(particle_table)

    

    -- This will update the color based on where the particle is
    -- if self.previous_position.x ~= self.position.x or self.previous_position.y ~= self.position.y then
    --     self:changeColor(particle_table)
    --     self.previous_position.x = self.position.x
    --     self.previous_position.y = self.position.y
    -- end
    -- Checks if there is a particle beneath the current position
    if self.position.y+1 < self.HEIGHT then
        if particle_table[self.position.y+1][self.position.x] ~= nil and particle_table[self.position.y+1][self.position.x].density >= self.density then--particle_table[self.Clampf(self.position.y+1, 1, HEIGHT)][self.position.x] ~= nil then --and particle_table[self.Clampf(self.position.y+1, 1, WIDTH)][self.position.x].type ~= 0 then
        
            -- Checks if there is a free space to either the right or the left of the particle
            
            -- if not IsSpaceOccupied(self.position.y, self.position.x+1) or not IsSpaceOccupied(self.position.y, self.position.x-1) then --particle_table[self.Clampf(self.position.y, 1, HEIGHT)][self.position.x+1] == nil or particle_table[self.Clampf(self.position.y, 1, HEIGHT)][self.position.x-1] == nil then
                -- Spreadout if there is space on either side
                
                self.position = self.fluid_component:SpreadOut(particle_table, self.position, self)
            -- end
            self.velocity = 1
    
        -- Checks to see if there is no particle beneath the current position
        else -- particle_table[self.Clampf(self.position.y+1, 1, WIDTH)][self.position.x] == nil then
            -- Follows gravity to fall
            self.position = self.grav_component:FallDown(particle_table, self.position, self)
        
        end
    end
    

    


end

-- This will change the color of the water dependent on how much is above it
function oil:changeColor(particle_table)

    if self.depthUpdateClock < self.depthUpdateTimer then
        self.depthUpdateClock = self.depthUpdateClock + 1
        return
    end
    self.depthUpdateClock = 0
    
    
    -- If the space above is not occupied or its a liquid that is less dense
    if self.position.y-1 > 0 and (particle_table[self.position.y-1][self.position.x] == nil or (particle_table[self.position.y-1][self.position.x] ~= nil and particle_table[self.position.y-1][self.position.x].density < self.density )) then
        self.depthCount = self.Clampf(self.depthCount-1, 0, 220)
    -- Check if the particle above is a water particle
    elseif self.position.y-1 > 0 and particle_table[self.position.y-1][self.position.x].type == self.type then
        self.depthCount = self.Clampf(self.depthCount+1, 0, particle_table[self.position.y-1][self.position.x].depthCount + 1)
    end

    -- Determine color based on the depthCount
    if self.depthCount <= 1 then --math.random( 1, 4 ) then
        -- #292b30 Hexcode for the color
        self.color:changeColor(0.1607843137254902, 0.16862745098039217, 0.18823529411764706, self.color.a)
    elseif self.depthCount <= 5 then --math.random( 5, 9 ) then
        -- #212226 Hexcode for the color
        self.color:changeColor(0.12941176470588237, 0.13333333333333333, 0.14901960784313725, self.color.a)
    elseif self.depthCount <= 12 then -- math.random( 12, 18 ) then
        -- #1c1d21 Hexcode for the color
        self.color:changeColor(0.10980392156862745, 0.11372549019607843, 0.12941176470588237, self.color.a)
    elseif self.depthCount <= 30 then --math.random( 30, 37 ) then
        -- #15161a Hexcode for the color
        self.color:changeColor(0.08235294117647059, 0.08627450980392157, 0.10196078431372549, self.color.a)
    elseif self.depthCount <= 800 then --math.random( 80, 87 ) then
        -- #0d0d0f Hexcode for the color
        self.color:changeColor(0.050980392156862744, 0.050980392156862744, 0.058823529411764705, self.color.a)
    
    end

end





function oil:Draw(batch, particle_table)
    --batch:setColor(0, 0, 0.49411764705882355, 0.85)
    self:changeColor(particle_table)
    batch:setColor(self.color.r, self.color.g, self.color.b, self.color.a)
    batch:add((self.position.x-1)*self.SCALE, self.position.y*self.SCALE, 0, self.SCALE, self.SCALE, 0)
end

return oil