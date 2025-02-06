local Vector2 = require("Vector2Script")
local GravityComponent = require("Components.GravityMovementComponent")
local FluidComponent = require("Components.FluidSpreadOutComponent")
local DisplacementComponent = require("Components.DisplacementComponent")
local Color = require("ColorScript")
local DissolveComponent = require("Components.DissolveComponent")

local water = {}

water.__index = water
water.name = "Water"

function water.new(x, y)
    local myClass = setmetatable({}, water)

    myClass.position = Vector2.new(x, y)
    myClass.velocity = 1
    myClass.type = 2

    -- Water's Density is 0, as it is the basis of density here
    myClass.density = 0

    myClass.grav_component = GravityComponent.new(false, {}, myClass.density)
    myClass.fluid_component = FluidComponent.new({})
    myClass.displace_component = DisplacementComponent.new()

    myClass.color = Color.new(0.20784313725490197, 0.43137254901960786, 0.6313725490196078, 0.85)

    -- Depth variable will contain which level of color the current water particle is associated with
    myClass.depth = 0


    myClass.depthCount = 0 -- How many layers down the particle is from other water particles

    myClass.previous_position = Vector2.new(x, y)
    
    -- Will allow the depth to be updated every so often
    myClass.depthUpdateTimer = 2
    myClass.depthUpdateClock = math.random(0, myClass.depthUpdateTimer)

    myClass.dissolve_component = DissolveComponent.new(1, 0.0015)

    -- Make local variable of global to reduce processing global lookup
    myClass.SCALE = SCALE
    myClass.HEIGHT = HEIGHT
    myClass.WIDTH = WIDTH
    myClass.Clampf = Clampf

    return myClass
end

function water:getPosition()
    return self.position
end

-- Displace function is called when a particle lands where this particle was and so this particle must be moved out of the way
function water:Displace(particle_table, position, distance)
    self.position = self.displace_component:Displace(particle_table, self.position, self, distance)
end


function water:Update(particle_table)

    

    -- This will update the color based on where the particle is
    -- if self.previous_position.x ~= self.position.x or self.previous_position.y ~= self.position.y then
    --     self:changeColor(particle_table)
    --     self.previous_position.x = self.position.x
    --     self.previous_position.y = self.position.y
    -- end
    -- Checks if there is a particle beneath the current position
    if self.position.y+1 < self.HEIGHT then
        if particle_table[self.position.y+1][self.position.x] ~= nil and particle_table[self.position.y+1][self.position.x].density >= self.density then
            self.position = self.fluid_component:SpreadOut(particle_table, self.position, self)
        end
    end

    -- if self.position.y+1 < self.HEIGHT and particle_table[self.position.y+1][self.position.x] ~= nil then --IsSpaceOccupied(self.position.y+1, self.position.x) then--particle_table[Clampf(self.position.y+1, 1, HEIGHT)][self.position.x] ~= nil then --and particle_table[Clampf(self.position.y+1, 1, WIDTH)][self.position.x].type ~= 0 then
        
    --     -- Checks if there is a free space to either the right or the left of the particle
        
    --     if (self.position.x+1 < self.WIDTH and particle_table[self.position.y][self.position.x+1] == nil) or (self.position.x-1 > 0 and particle_table[self.position.y][self.position.x-1] == nil) then --particle_table[Clampf(self.position.y, 1, HEIGHT)][self.position.x+1] == nil or particle_table[Clampf(self.position.y, 1, HEIGHT)][self.position.x-1] == nil then
    --         -- Spreadout if there is space on either side
    --         self.position = self.fluid_component:SpreadOut(particle_table, self.position, self)
    --     end
    --     self.velocity = 1

    -- Checks to see if there is no particle beneath the current position
    -- else -- particle_table[Clampf(self.position.y+1, 1, WIDTH)][self.position.x] == nil then
        -- Follows gravity to fall
        self.position = self.grav_component:FallDown(particle_table, self.position, self)
    
    -- end

    self.dissolve_component:Dissolve(particle_table, self.position)



    -- if particle_table[Clampf(self.position.y, 1, WIDTH)][self.position.x+1] ~= nil and particle_table[Clampf(self.position.y, 1, WIDTH)][self.position.x-1] ~= nil and particle_table[Clampf(self.position.y+1, 1, WIDTH)][self.position.x] == nil then
        
    -- else
    --     self.position = self.fluid_component:SpreadOut(particle_table, self.position, self)
    -- end

    -- -- Check the spot immediately below the particle and if its filled return early to not waste time in for loop
    -- if particle_table[Clampf(self.position.y+1, 1, WIDTH)][self.position.x] ~= nil and particle_table[Clampf(self.position.y+1, 1, WIDTH)][self.position.x].type ~= 0 then
    --     self.velocity = 1
        
    -- else

    --     self.position = self.grav_component:FallDown(particle_table, self.position, self)
    -- end
    
end

-- This will change the color of the water dependent on how much is above it
function water:changeColor(particle_table)

    if self.depthUpdateClock < self.depthUpdateTimer then
        self.depthUpdateClock = self.depthUpdateClock + 1
        return
    end
    self.depthUpdateClock = 0
    
    if self.position.y-1 <= 0 then
        return
    end

    if self.position.y-1 > 0 and (particle_table[self.position.y-1][self.position.x] == nil or (particle_table[self.position.y-1][self.position.x] ~= nil and particle_table[self.position.y-1][self.position.x].density < self.density )) then
        self.depthCount = self.Clampf(self.depthCount-1, 0, 220)
    -- Check if the particle above is a water particle
    elseif self.position.y-1 > 0 and particle_table[self.position.y-1][self.position.x].type == self.type then
        self.depthCount = self.Clampf(self.depthCount+1, 0, particle_table[self.position.y-1][self.position.x].depthCount + 1)
    end

    -- Determine color based on the depthCount
    if self.depthCount <= 1 then --math.random( 1, 4 ) then
        --batch:setColor(0.27450980392156865, 0.6039215686274509, 0.8901960784313725, 0.85)
        self.color:changeColor(0.7058823529411765, 0.8509803921568627, 0.9803921568627451, self.color.a)
        --batch:setColor(0.7058823529411765, 0.8509803921568627, 0.9803921568627451, 0.85)
        self.depth = 0
    elseif self.depthCount <= 5 then --math.random( 5, 9 ) then
        --batch:setColor(0.2627450980392157, 0.5490196078431373, 0.8, 0.85)
        self.color:changeColor(0.2627450980392157, 0.5490196078431373, 0.8, self.color.a)
        self.depth = 1
    elseif self.depthCount <= 12 then -- math.random( 12, 18 ) then
        --batch:setColor(0.20784313725490197, 0.43137254901960786, 0.6313725490196078, 0.85)
        self.color:changeColor(0.20784313725490197, 0.43137254901960786, 0.6313725490196078, self.color.a)
        self.depth = 2
    elseif self.depthCount <= 30 then --math.random( 30, 37 ) then
        --batch:setColor(0.13725490196078433, 0.29411764705882354, 0.43137254901960786, 0.85)
        self.color:changeColor(0.13725490196078433, 0.29411764705882354, 0.43137254901960786, self.color.a)
        self.depth = 3
    elseif self.depthCount <= 80 then --math.random( 80, 87 ) then
        -- #1d3f5c Hexcode for the color
        self.color:changeColor(0.11372549019607843, 0.24705882352941178, 0.3607843137254902, self.color.a)
        self.depth = 4
    elseif self.depthCount <= 200 then
        -- #12293d Hexcode for the color
        self.color:changeColor(0.07058823529411765, 0.1607843137254902, 0.23921568627450981, self.color.a)
        self.depth = 5
    end


    -- -- Check the particle to the right and copy its depthcount
    -- if self.position.x+1 < WIDTH and IsSpaceOccupied(self.position.y, self.position.x+1) and particle_table[self.position.y][self.position.x+1].type == 2 then
    --     self.depthCount = particle_table[self.position.y][self.position.x+1].depthCount
    -- end
    -- -- Check the particle to the left and copy its depthcount if its greater
    -- if self.position.x-1 > 0 and IsSpaceOccupied(self.position.y, self.position.x-1) and particle_table[self.position.y][self.position.x-1].type == 2 then
    --     if self.depthCount < particle_table[self.position.y][self.position.x-1].depthCount then
    --         self.depthCount = particle_table[self.position.y][self.position.x-1].depthCount
    --     end
    -- end
    -- if self.position.y+1 < HEIGHT and IsSpaceOccupied(self.position.y+1, self.position.x) and particle_table[self.position.y+1][self.position.x].type == 2 and self.depthCount == 0 then
    --     if self.depthCount < particle_table[self.position.y+1][self.position.x].depthCount then
    --         self.depthCount = particle_table[self.position.y+1][self.position.x].depthCount
    --     end
    -- end

    
    -- if self.depthCount <= 12 then -- math.random( 12, 18 ) then
    --     --batch:setColor(0.20784313725490197, 0.43137254901960786, 0.6313725490196078, 0.85)
    --     --self.color:changeColor(0.20784313725490197, 0.43137254901960786, 0.6313725490196078, self.color.a)
    --     self.color:mixColors(Color.new(0.20784313725490197, 0.43137254901960786, 0.6313725490196078, self.color.a))
        
    -- elseif self.depthCount <= 30 then --math.random( 30, 37 ) then
    --     --batch:setColor(0.13725490196078433, 0.29411764705882354, 0.43137254901960786, 0.85)
    --     --self.color:changeColor(0.13725490196078433, 0.29411764705882354, 0.43137254901960786, self.color.a)
    --     self.color:mixColors(Color.new(0.13725490196078433, 0.29411764705882354, 0.43137254901960786, self.color.a))
        
    -- elseif self.depthCount <= 80 then --math.random( 80, 87 ) then
    --     -- #1d3f5c Hexcode for the color
    --     --self.color:changeColor(0.11372549019607843, 0.24705882352941178, 0.3607843137254902, self.color.a)
    --     self.color:mixColors(Color.new(0.11372549019607843, 0.24705882352941178, 0.3607843137254902, self.color.a))
        
    -- elseif self.depthCount <= 200 then
    --     -- #12293d Hexcode for the color
    --     --self.color:changeColor(0.07058823529411765, 0.1607843137254902, 0.23921568627450981, self.color.a)
    --     self.color:mixColors(Color.new(0.07058823529411765, 0.1607843137254902, 0.23921568627450981, self.color.a))
        
    -- end



end





function water:Draw(batch, particle_table)
    --batch:setColor(0, 0, 0.49411764705882355, 0.85)
    self:changeColor(particle_table)
    batch:setColor(self.color.r, self.color.g, self.color.b, self.color.a)
    batch:add((self.position.x-1)*self.SCALE, self.position.y*self.SCALE, 0, self.SCALE, self.SCALE, 0)
end

return water