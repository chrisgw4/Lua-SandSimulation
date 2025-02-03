local vector2 = require("Vector2Script")

local animated_text = {}

animated_text.__index = animated_text

function animated_text.new(x, y)
    local myClass =setmetatable({}, animated_text)

    myClass.position = vector2.new(x, y)
    myClass.orientation = 0 -- Start orientation at level
    myClass.text = nil


    return myClass
    
end

function animated_text:rotate()

end

return animated_text