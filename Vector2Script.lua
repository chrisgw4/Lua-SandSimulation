local vector2 = {}

vector2.__index = vector2

function vector2.new(x, y)
    local myClass = setmetatable({}, vector2)

    myClass.x = x
    myClass.y = y

    return myClass
end

function vector2:getString()
    return "(" .. self.x .. "," .. self.y .. ")"
end

return vector2