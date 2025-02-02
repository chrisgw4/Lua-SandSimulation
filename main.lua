-- #region Required Start Statement --
if arg[2] == "debug" then
    require("lldebugger").start()
end

-- #endregion End of required Statement --

-- #region Required Class Scripts --
local button = require("ButtonScript")
local vector2 = require("Vector2Script")

-- Particle Requires
local Sand = require("particles.SandScript")
local Water = require("particles.WaterScript")
local Stone = require("particles.StoneScript")
-- End Particle Requires

local Clamp = require("Clamp")
local tick = require("tick")
-- #endregion End of required Class Scripts --

local vec2 = vector2.new(1, 2)
local x = 0
local reverse = false

SCALE = 5
WIDTH = love.graphics.getWidth()/SCALE
HEIGHT = love.graphics.getHeight()/SCALE

love.mouse.setVisible(false)

-- #TODO Add in functionality to scale size when using scroll wheel and when press in scroll wheel reset back to 8
local size = 8 -- This variable is used to determine how much of a particle should spawn around mouse
local base_size = 8 -- This variable wont change, but will allow for resetting the size of placement

-- #region Particle_table will hold onto the data of where particles are, with a 0 for none, 1 for sand, 
local particle_table = {}
for i=1, WIDTH do
    particle_table[i] = {}
    for j=0,HEIGHT + 1 do
        particle_table[i][j] = nil
    end
end
-- #endregion

local particles = {}


local sand1 = Sand.new(100,1)
-- local sand2 = Sand.new(100,8)

particles[#particles+1] = sand1
-- particles[#particles+1] = sand2
particle_table[sand1.position.y][sand1.position.x] = sand1


local selected_particle = Sand

-- Sprite batch will hold onto the particle draw data and then draw them all at once in one call --
local sprite_batch = love.graphics.newSpriteBatch(love.graphics.newImage("particle.png"), 1000, "dynamic")
local mouse_batch = love.graphics.newSpriteBatch(love.graphics.newImage("particle.png"), 1000, "dynamic")


-- Caps the framerate to 60 fps
function love.load(arg)
  tick.framerate = 120000 -- Limit framerate to 60 frames per second.
end


-- #region Previews the area where the particles will spawn around the mouse --
local function preview_mouse(x, y)

    local radius = size/2

    -- Spawns a circle of the selected particle around the cursor
    for i=-radius,radius do
        for j=-radius,radius do

            if i * i + j * j <= radius * radius then
                mouse_batch:setColor(1, 0.25, 0.25, 0.45)
                mouse_batch:add((x+j)*SCALE, (y+i)*SCALE, 0, SCALE, SCALE, 0)
            end     
        end
        
        
    end


    -- for i=0,4 do
    --     for j=0,4 do
    --         mouse_batch:setColor(1, 0.25, 0.25, 0.45)
    --         mouse_batch:add((x+j)*SCALE, (y+i)*SCALE, 0, SCALE, SCALE, 0)
    --     end
    -- end
end
-- #endregion


-- region Function will check if input position is occupied --
function IsSpaceOccupied(y, x)
    return particle_table[ClampHeight(y)][ClampWidth(x)] ~= nil
end
-- endregion

-- The queue for particles that should be deleted
local deletion_queue = {}

function AddToDeleteQueue(temp)
    deletion_queue[#deletion_queue+1] = temp
end


function DeleteParticle(temp)
    for x=1,#particles do
        ::continue::
        for j=1, #temp do
            
            if particles[x] == temp[j] then
                particle_table[temp[j].position.y][temp[j].position.x] = nil
                table.remove(particles, x)
                table.remove(temp, j)
                
                goto continue
            end
        end
        -- if particles[x] == temp then
            -- table.remove(particles, x)
        -- end
    end
    
end

-- Will Check if the input y and x are InBounds in relation to the particle_table and the screen size
function InBounds(y, x)
    return y > 0 and y <= HEIGHT-1 and x > 0 and x <= WIDTH
end

-- #region Will delete a clump of particles at the mouse position --
local function delete_particle_mouse(x, y)
    local radius = size/2
    local to_be_deleted = {}
    -- Spawns a circle of the selected particle around the cursor
    for i=-radius,radius do
        for j=-radius,radius do

            -- Check the radius to see if particle should be deleted
            if i * i + j * j <= radius * radius then
                -- Make sure y and x are inBounds and make sure Space is occupied. Dont call InBounds Function because it will not account for bottom most row for deletion
                if y+i <= HEIGHT and x+j <= WIDTH and IsSpaceOccupied(y+i, x+j)  then
                    local temp = particle_table[ClampHeight(y+i)][Clampf(x+j, 1, WIDTH+1)]
                    to_be_deleted[#to_be_deleted+1] = temp
                    --particles:remove(particle_table[y+i][x+j])

                    -- Need to clampf for x because erasing the right side wont work without it
                    particle_table[ClampHeight(y+i)][Clampf(x+j, 1, WIDTH+1)] = nil
                end
            end   
        end
    end

    DeleteParticle(to_be_deleted)
end
-- #endregion

-- #region Will spawn a clump of particles at the mouse position --
local function spawn_particle(x, y, can_spawn)
    if not can_spawn then
        return
    end

    
    local radius = size/2

    -- Spawns a circle of the selected particle around the cursor
    for i=-radius,radius do
        for j=-radius,radius do

            if i * i + j * j <= radius * radius then
                if not IsSpaceOccupied(y+i, x+j) then
                    local temp = selected_particle.new(ClampWidth(x+j), ClampHeight(y+i))
                    particle_table[ClampHeight(y+i)][ClampWidth(x+j)] = temp
                    particles[#particles+1] = temp
                end
            end

            -- if (i > -radius or i < radius) and (j > (last-(last*(sca)))/2 and j < last-(last-(last*(sca)))/2) then
            --     if not IsSpaceOccupied(y+i, x+j) then
            --         local temp = selected_particle.new(x+j, y+i)
            --         particle_table[Clampf(y+i, 1, HEIGHT)][Clampf(x+j, 1, WIDTH)] = temp
            --         particles[#particles+1] = temp
            --     end
            -- -- elseif (i > start and i < last) then
            -- --     if not IsSpaceOccupied(y+i, x+j) then
            -- --         local temp = selected_particle.new(x+j, y+i)
            -- --         particle_table[Clampf(y+i, 1, HEIGHT)][Clampf(x+j, 1, WIDTH)] = temp
            -- --         particles[#particles+1] = temp
            -- --     end
            -- end
            
            
            
        end
        
        
    end
end
-- #endregion

-- #region Mouse Wheel related to particle spawn size --

-- Will reset the size of the particle spawning --
local function resetSize()
    size = base_size
end

-- Will check if the scroll wheel has been move
function love.wheelmoved(x, y)

    -- If scrolled up
    if y > 0 then
        -- Increase size
        size = Clampf(size + 1, 2, 256)
    -- if scrolled down
    elseif y < 0 then
        -- Decrease size, and clamp to min of 2
        size = Clampf(size - 1, 2, 256)
    end
end

-- #endregion


-- Checks the event when a key on the keyboard is pressed
function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
       love.event.quit()
    end
    if key == "1" then
        selected_particle = Sand
    elseif key == "2" then
        selected_particle = Water
    elseif key == "3" then
        selected_particle = Stone
    end
 end


local frame_draw = 0
local frame_update = 0

-- Set the background color of the game
--love.graphics.setBackgroundColor( 0.17647058823529413, 0.7294117647058823, 0.8392156862745098, 0.5 )
-- love.graphics.setBackgroundColor( 0.1411764705882353, 0.5333333333333333, 0.611764705882353, 0.5 )
love.graphics.setBackgroundColor( 0.4235294117647059, 0.5882352941176471, 0.7294117647058823, 0.5 )

function love.update(dt)
	

    -- Catches the event when the mouse button 1 is pressed --
    if love.mouse.isDown(1) then
        -- Calls the function to spawn particles at the mouse location --
        spawn_particle(ClampWidth(love.mouse.getX()/SCALE),  ClampHeight(love.mouse.getY()/SCALE), true)

    -- Catches the event when the mouse button 2 is pressed --
    elseif love.mouse.isDown(2) then
        -- Calls the function to delete particles at the mouse location --
        delete_particle_mouse(ClampWidth(love.mouse.getX()/SCALE),  ClampHeight(love.mouse.getY()/SCALE))
    -- If the scroll wheel is pressed down
    elseif love.mouse.isDown(3) then
        resetSize() -- Reset the spawning size back to its base value
    end

    -- Chunk into 6, 2 vertical and 3 horizontal

    -- Update the particles in chunks
    -- for x = 1,32 do
    --     for i = HEIGHT, 1, -1 do
    --         for j = WIDTH/32, 1, -1 do
    --             if IsSpaceOccupied(i,j+(WIDTH/32 * (x-1))) then
    --                 particle_table[i][j+(WIDTH/32 * (x-1))]:Update(particle_table)
    --             elseif IsSpaceOccupied(i,j) and x%2 == 1 then
    --                 particle_table[i][j]:Update(particle_table)
    --             end
    --         end
    --     end
    -- end


    -- if frame_update % 1 == 0 then
    --     for i=1,#particle_table do
    --         for j = 1, WIDTH do
    --             if IsSpaceOccupied(i,j) then
    --                 -- Checks to see if a particle has been overridden but is still taking processing power, and removes them if they're not found
    --                 -- if particle_table[Clampf(particles[i].position.y, 1, HEIGHT)][particles[i].position.x] ~= particles[i] then
    --                 --     particle_table:remove(particles[i])
    --                 --     particles:remove(particles[i])
    --                 -- end
    --                 particle_table[i][j]:Update(particle_table)
    --                 -- particles[i]:Update(particle_table)
    --             end
    --         end
    --     end
    --     frame_update = 0
    -- end
    -- frame_update = frame_update + 1
    --if frame_update % 1 == 0 then
    -- Updates each particle
    for i=1,#particles do
        particles[i]:Update(particle_table)
    end

    
    DeleteParticle(deletion_queue)
    
    deletion_queue = {}
    -- for i=1,#particle_table do
    --     for j = 1, #particle_table[i] do
    --         if IsSpaceOccupied(i,j) then
    --             -- Checks to see if a particle has been overridden but is still taking processing power, and removes them if they're not found
    --             -- if particle_table[Clampf(particles[i].position.y, 1, HEIGHT)][particles[i].position.x] ~= particles[i] then
    --             --     particle_table:remove(particles[i])
    --             --     particles:remove(particles[i])
    --             -- end
    --             particle_table[i][j]:Update(particle_table)
    --             --particles[i]:Update(particle_table)
    --         end

            

            
    --     end

            
        -- end
        --frame_update = 0
    --end
    --frame_update = frame_update + 1
end


-- Make Thread to update Particles
local t = love.thread.newThread("ThreadUpdateParticles.lua")
local c1 = love.thread.getChannel("particles")





-- -- Main Loop, Probably dont mess with this
-- function love.run()
-- 	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

-- 	-- We don't want the first frame's dt to include time taken by love.load.
-- 	if love.timer then love.timer.step() end

-- 	local dt = 0

-- 	-- Main loop time.
-- 	return function()
-- 		-- Process events.
-- 		if love.event then
-- 			love.event.pump()
-- 			for name, a,b,c,d,e,f in love.event.poll() do
-- 				if name == "quit" then
-- 					if not love.quit or not love.quit() then
-- 						return a or 0
-- 					end
-- 				end
-- 				love.handlers[name](a,b,c,d,e,f)
-- 			end
-- 		end

-- 		-- Update dt, as we'll be passing it to update
-- 		if love.timer then 
--             dt = love.timer.step() 
--         end

-- 		-- Call update and draw
-- 		if love.update then 
--             love.update(dt) 

--             --if c1:peek() ~= nil then
                
--             if not t:isRunning() then
--                 -- t:start(c1)
--                 -- c1:push(particles)
--                 -- c1:push(particle_table)
--             end
            
            


--         end -- will pass 0 if love.timer is disabled

-- 		if love.graphics and love.graphics.isActive() then
-- 			love.graphics.origin()
-- 			love.graphics.clear(love.graphics.getBackgroundColor())

-- 			if love.draw then 
--                 love.draw() 
--             end

-- 			love.graphics.present()
-- 		end

-- 		if love.timer then love.timer.sleep(0.001) end
-- 	end
-- end


function love.draw()
    mouse_batch:clear()

    -- #region Bounces the words "Hello Word" back and forth on the x-axis --
    love.graphics.print("Hello World", x, 300)
    if reverse == false then
        x = x + 0.5
    else
        x = x - 0.5
    end

    if x >= love.graphics.getWidth()-70 then
        reverse = true
    else if x <= 0 + 0 then
        reverse = false
        end
    end
    -- #endregion

    if frame_draw % math.floor(love.timer.getFPS()/30) == 0 then
        -- #region Goes through all the particles that are created and updates them, and adds them to the draw call --

        sprite_batch:clear()

        -- Adds all the particles to the sprite batch to prepare for draw
        for i=1,#particles do
            particles[i]:Draw(sprite_batch, particle_table)
        end
        -- endregion
        frame_draw = 0
    end
    frame_draw = frame_draw + 1

    -- Previews where the mouse is so you know where you will destroy or place particles --
    preview_mouse(Clampf(love.mouse.getX()/SCALE, 1, WIDTH)-1,  Clampf(love.mouse.getY()/SCALE, 1, HEIGHT))

    
    -- Draws the entire Batch array in one call --
    love.graphics.draw(sprite_batch)
    love.graphics.draw(mouse_batch)


    love.graphics.print(Clampf(love.mouse.getX()/SCALE, 1, WIDTH) .. ", " .. Clampf(love.mouse.getY()/SCALE, 1, HEIGHT), 100, 20)
    love.graphics.print(love.graphics.getWidth().."x"..love.graphics.getHeight(), 10, 10)
    love.graphics.print("("..vec2.x .. "," .. vec2.y.. ")", 10, 50)
    love.graphics.print(vec2:getString(), 10, 90)

    love.graphics.print("Sand1: "..sand1:getPosition():getString(), 10, 110)
    love.graphics.print("Particles: ".. #particles, 10, 150)
    love.graphics.print("SCALE: ".. SCALE, 10, 170)
    love.graphics.print("Size: ".. size, 10, 190)
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 300, 10)

    
end






-- #region Start of ending required Statement --
local love_errorhandler = love.errorhandler

function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end
-- #endregion