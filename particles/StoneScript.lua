local Vector2 = require("Vector2Script")


local stone = {}

stone.__index = stone
stone.name = "Stone"


function stone.new(x, y, index)
    local myClass = setmetatable({}, stone)

    myClass.position = Vector2.new(x, y)
    myClass.type = 3

    myClass.color = Clamp(math.random(), 0.4196078431372549, 0.4396078431372549)
    


    return myClass 
end

function stone:getPosition()
    return self.position
end

function stone:Update(particle_table)

end

function stone:Draw(batch, graphics)
    batch:setColor(self.color, self.color, self.color)
    --batch:setColor(0.5294117647058824, 0.5294117647058824, 0.5294117647058824)
    batch:add((self.position.x-1)*SCALE, (self.position.y)*SCALE, 0, SCALE, SCALE, 0)
end




return stone