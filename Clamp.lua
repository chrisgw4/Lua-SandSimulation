-- This script adds a function called Clamp --

function Clamp(num, min, max)

    if num > max then
        return max
    end
    if num < min then
        return min
    end

    return num
end

-- Clamp Floor. Floors the clamp number when returned
function Clampf(num, min, max)
    if num > max then
        return math.floor(max)
    end
    if num < min then
        return math.floor(min)
    end

    return math.floor(num)
end


function ClampHeight(y)
    return Clampf(y, 1, HEIGHT-1)
end

function ClampWidth(x)
    return Clampf(x, 1, WIDTH)
end