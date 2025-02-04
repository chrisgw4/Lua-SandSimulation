local Vector2 = require("Vector2Script")
local GravityComponent = require("Components.GravityMovementComponent")
local FluidComponent = require("Components.FluidSpreadOutComponent")
local DisplacementComponent = require("Components.DisplacementComponent")
local Color = require("ColorScript")
local DissolveComponent = require("Components.DissolveComponent")

local acid = {}

acid.__index = acid
acid.name = "Acid"

function acid.new(x, y)
    local myClass = setmetatable({}, acid)

    myClass.position = Vector2.new(x, y)
    myClass.velocity = 1
    myClass.type = 4

    myClass.grav_component = GravityComponent.new(false, {2})
    myClass.fluid_component = FluidComponent.new({2})
    myClass.displace_component = DisplacementComponent.new()

    -- Default Color #03fc6b Hexcode
    myClass.color = Color.new(0.011764705882352941, 0.9882352941176471, 0.4196078431372549, 0.85)

    -- Depth variable will contain which level of color the current water particle is associated with
    myClass.depth = 0


    myClass.depthCount = 0 -- How many layers down the particle is from other water particles

    myClass.previous_position = Vector2.new(x, y)
    
    -- Will allow the depth to be updated every so often
    myClass.depthUpdateTimer = 2
    myClass.depthUpdateClock = math.random(0, myClass.depthUpdateTimer)

    myClass.dissolve_component = DissolveComponent.new(3, 9950)

    return myClass
end

function acid:getPosition()
    return self.position
end

-- Displace function is called when a particle lands where this particle was and so this particle must be moved out of the way
function acid:Displace(particle_table, position, distance)
    self.position = self.displace_component:Displace(particle_table, self.position, self, distance)
end


function acid:Update(particle_table)

    

    -- This will update the color based on where the particle is
    -- if self.previous_position.x ~= self.position.x or self.previous_position.y ~= self.position.y then
    --     self:changeColor(particle_table)
    --     self.previous_position.x = self.position.x
    --     self.previous_position.y = self.position.y
    -- end
    -- Checks if there is a particle beneath the current position
    
    if IsSpaceOccupied(self.position.y+1, self.position.x) and particle_table[Clampf(self.position.y+1, 1, HEIGHT)][self.position.x] ~= nil and particle_table[Clampf(self.position.y+1, 1, HEIGHT)][self.position.x].type ~= 2 then--particle_table[Clampf(self.position.y+1, 1, HEIGHT)][self.position.x] ~= nil then --and particle_table[Clampf(self.position.y+1, 1, WIDTH)][self.position.x].type ~= 0 then
        
        -- Checks if there is a free space to either the right or the left of the particle
        
        -- if not IsSpaceOccupied(self.position.y, self.position.x+1) or not IsSpaceOccupied(self.position.y, self.position.x-1) then --particle_table[Clampf(self.position.y, 1, HEIGHT)][self.position.x+1] == nil or particle_table[Clampf(self.position.y, 1, HEIGHT)][self.position.x-1] == nil then
            -- Spreadout if there is space on either side
            
            self.position = self.fluid_component:SpreadOut(particle_table, self.position, self)
        -- end
        self.velocity = 1

    -- Checks to see if there is no particle beneath the current position
    else -- particle_table[Clampf(self.position.y+1, 1, WIDTH)][self.position.x] == nil then
        -- Follows gravity to fall
        
    
    end
    self.position = self.grav_component:FallDown(particle_table, self.position, self)

    self.dissolve_component:Dissolve(particle_table, self.position)


end

-- This will change the color of the water dependent on how much is above it
function acid:changeColor(particle_table)

    if self.depthUpdateClock < self.depthUpdateTimer then
        self.depthUpdateClock = self.depthUpdateClock + 1
        return
    end
    self.depthUpdateClock = 0
    
    
    -- If the space above is not occupied
    if InBounds(self.position.y-1, self.position.x) and (IsSpaceOccupied(self.position.y-1, self.position.x) == false or (particle_table[self.position.y-1][self.position.x] ~= nil and particle_table[self.position.y-1][self.position.x].type == 2 )) then
        self.depthCount = Clampf(self.depthCount-1, 0, 220)
    -- Check if the particle above is a water particle
    elseif self.position.y-1 > 0 and particle_table[self.position.y-1][self.position.x].type == self.type then
        self.depthCount = Clampf(self.depthCount+1, 0, particle_table[self.position.y-1][self.position.x].depthCount + 1)
    end

    -- Determine color based on the depthCount
    if self.depthCount <= 1 then --math.random( 1, 4 ) then
        -- #03fc6b Hexcode for the color
        self.color:changeColor(0.011764705882352941, 0.9882352941176471, 0.4196078431372549, self.color.a)
    elseif self.depthCount <= 5 then --math.random( 5, 9 ) then
        -- #00bf50 Hexcode for the color
        self.color:changeColor(0, 0.7490196078431373, 0.3137254901960784, self.color.a)
    elseif self.depthCount <= 12 then -- math.random( 12, 18 ) then
        -- #009c41 Hexcode for the color
        self.color:changeColor(0, 0.611764705882353, 0.2549019607843137, self.color.a)
    elseif self.depthCount <= 30 then --math.random( 30, 37 ) then
        -- #007531 Hexcode for the color
        self.color:changeColor(0, 0.4588235294117647, 0.19215686274509805, self.color.a)
    elseif self.depthCount <= 80 then --math.random( 80, 87 ) then
        -- #005c26 Hexcode for the color
        self.color:changeColor(0, 0.4588235294117647, 0.19215686274509805, self.color.a)
    elseif self.depthCount <= 200 then
        -- #003d1a Hexcode for the color
        self.color:changeColor(0, 0.23921568627450981, 0.10196078431372549, self.color.a)
    end

end





function acid:Draw(batch, particle_table)
    --batch:setColor(0, 0, 0.49411764705882355, 0.85)
    self:changeColor(particle_table)
    batch:setColor(self.color.r, self.color.g, self.color.b, self.color.a)
    batch:add((self.position.x-1)*SCALE, self.position.y*SCALE, 0, SCALE, SCALE, 0)
end

return acid