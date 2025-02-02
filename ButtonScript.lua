local vector2 = require("Vector2Script")

local button = {}

button.__index = button

function button.new(x, y)
    local myClass =setmetatable({}, button)

    myClass.position = vector2.new(x, y)

    return myClass
    
end

return button