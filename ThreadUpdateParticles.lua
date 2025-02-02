
local SandScript = require("particles.SandScript")


-- print("start")

local c1 = love.thread.getChannel("particles")



local particle = c1:demand()
local p_table = c1:demand()

-- print("start of func")

--print("Type " .. particle[1].type)

-- for i=1, #particle do
    -- print(i)
    --particle[i]:Update(p_table)
-- end

-- print('out of for loop')
c1:push(particle)

