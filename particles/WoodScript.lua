local Vector2 = require("Vector2Script")
local Color = require("ColorScript")

local wood = {}

wood.__index = wood
wood.name = "Wood"


function wood.new(x, y, index)
    local myClass = setmetatable({}, wood)

    myClass.position = Vector2.new(x, y)
    myClass.type = 5

    myClass.Random = math.random
    myClass.Clamp = Clamp

    -- #755c34
    myClass.color = Color.new(myClass.Clamp(myClass.Random(), 0.4588235294117647, 0.4688235294117647), myClass.Clamp(myClass.Random(), 0.3607843137254902, 0.3707843137254902), myClass.Clamp(myClass.Random(), 0.20392156862745098, 0.21392156862745098 ), 1)
    
    myClass.SCALE = SCALE

    myClass.density = 1000

    return myClass 
end

function wood:getPosition()
    return self.position
end

function wood:Update(particle_table)

end

function wood:Draw(batch, graphics)
    batch:setColor(self.color.r, self.color.g, self.color.b, self.color.a)
    batch:add((self.position.x-1)*self.SCALE, (self.position.y)*self.SCALE, 0, self.SCALE, self.SCALE, 0)
end




return wood