-- This class will store color information

local color = {}

color.__index = color

function color.new(r, g, b, a)
    local myClass = setmetatable({}, color)

    myClass.r = r
    myClass.b = b
    myClass.g = g
    myClass.a = a


    return myClass
end

function color:mixColors(color1)

    local output = color.new((self.r*2+color1.r)/3, (self.g*2+color1.g)/3, (self.b*2+color1.b)/3, (self.a+color1.a)/2)

    return output
end

function color:changeColor(r, g, b, a) 
    self.r = r
    self.b = b
    self.g = g
    self.a = a
end

return color