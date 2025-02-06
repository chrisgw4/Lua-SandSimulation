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
local Acid = require("particles.AcidScript")
local Wood = require("particles.WoodScript")
local Fire = require("particles.FireScript")
local Oil = require("particles.OilScript")
-- End Particle Requires

local clamp = require("Clamp")
local text = require("TextScript")
local tick = require("tick")
local profi = require("ProFi")
local love = love
local cron = require("Cron.cron")
-- #endregion End of required Class Scripts --

local vec2 = vector2.new(1, 2)
local x = 0
local reverse = false

SCALE = 10
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

-- This variable keeps track of which particle is selected and what particle to spawn
local selected_particle = Sand
local available_particles = {Sand, Water, Stone, Acid, Wood, Fire, Oil} -- This variable keeps track of the particles that are able to be selected

-- Sprite batch will hold onto the particle draw data and then draw them all at once in one call --
local sprite_batch = love.graphics.newSpriteBatch(love.graphics.newImage("particle.png"), 1000, "dynamic")
local sprite_batch1 = love.graphics.newSpriteBatch(love.graphics.newImage("particle.png"), 1000, "dynamic")
local sprite_batch2 = love.graphics.newSpriteBatch(love.graphics.newImage("particle.png"), 1000, "dynamic")
local sprite_batch3 = love.graphics.newSpriteBatch(love.graphics.newImage("particle.png"), 1000, "dynamic")
local sprite_batch4 = love.graphics.newSpriteBatch(love.graphics.newImage("particle.png"), 1000, "dynamic")
local sprite_batch_arr = {sprite_batch1, sprite_batch2, sprite_batch3, sprite_batch4}
local mouse_batch = love.graphics.newSpriteBatch(love.graphics.newImage("particle.png"), 1000, "dynamic")


-- Caps the framerate to 60 fps
function love.load(arg)
  tick.framerate = 60 -- Limit framerate to 60 frames per second.
end


-- #region Previews the area where the particles will spawn around the mouse --
local function preview_mouse(x, y)

    local radius = size/2
    local SCALE = SCALE

    -- Spawns a circle of the selected particle around the cursor
    for i=-radius,radius do
        for j=-radius,radius do

            if i * i + j * j <= radius * radius then
                mouse_batch:setColor(1, 0.25, 0.25, 0.45)
                mouse_batch:add((x+j)*SCALE, (y+i)*SCALE, 0, SCALE, SCALE, 0)
            end     
        end
        
        
    end
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
    table.insert( deletion_queue, temp )
end


local function DeleteParticle(temp)
    for x=1,#particles do
        ::continue::
        for j=1, #deletion_queue do
            
            if particles[x] == deletion_queue[j] then
                particle_table[deletion_queue[j].position.y][deletion_queue[j].position.x] = nil
                table.remove(particles, x)
                table.remove(deletion_queue, j)
                
                goto continue
            end
        end
        -- if particles[x] == temp then
            -- table.remove(particles, x)
        -- end
    end
    deletion_queue = {}
    
end

-- Will Check if the input y and x are InBounds in relation to the particle_table and the screen size
function InBounds(y, x, height, width)
    return y > 0 and y <= height-1 and x > 0 and x <= width
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
                if y+i <= HEIGHT and x+j <= WIDTH+1 and IsSpaceOccupied(y+i, x+j)  then
                    local temp = particle_table[ClampHeight(y+i)][Clampf(x+j, 1, WIDTH+1)]
                    -- to_be_deleted[#to_be_deleted+1] = temp
                    deletion_queue[#deletion_queue+1] = temp
                    --particles:remove(particle_table[y+i][x+j])

                    -- Need to clampf for x because erasing the right side wont work without it
                    --particle_table[ClampHeight(y+i)][Clampf(x+j, 1, WIDTH+1)] = nil
                end
            end   
        end
    end

    -- DeleteParticle(to_be_deleted)
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
                    local temp = selected_particle.new(ClampWidth(x+j), ClampHeight(y+i), nil)
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


local profi_started = true
local profi_ended = true
local profiles = 0
local profi_started2 = true
local profi_ended2 = true
local profiles2 = 0


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
    elseif key == "4" then
        selected_particle = Acid
    elseif key == "5" then
        selected_particle = Wood
    elseif key == "6" then
        selected_particle = Fire
    elseif key == "7" then
        selected_particle = Oil
    end

    if key == "f" then
        profi_started = false
        profi_started2 = false
        profi_ended2 = false
        profi_ended = false
    end
 end


local frame_draw = 0
local frame_update = 0

-- Set the background color of the game
--love.graphics.setBackgroundColor( 0.17647058823529413, 0.7294117647058823, 0.8392156862745098, 0.5 )
-- love.graphics.setBackgroundColor( 0.1411764705882353, 0.5333333333333333, 0.611764705882353, 0.5 )
love.graphics.setBackgroundColor( 0.4235294117647059, 0.5882352941176471, 0.7294117647058823, 0.5 )



-- Will sort the particles table periodically to ensure update works properly
local particle_sort_timer = 60
local particle_sort_clock = 0

local function sortParticles() 
    -- Sort the particles table after being sorted
    table.sort(particles, function(a, b)
        return a.position.y > b.position.y
    end)
end

local function updateParticles() 
    if not profi_started2 then
        profi:start()
        profi_started2 = true
    end


    for i=#particles, 1, -1 do
        particles[i]:Update(particle_table)
    end



    if not profi_ended2 then
        profi:stop()
        profi:writeReport("Zupdate_report".. profiles2 ..".txt")
        profi:reset()
        profiles2 = profiles2 + 1
        profi_ended2 = true
    end
end





local c1 = cron.every(0.032, updateParticles)
local c2 = cron.every(0.1, DeleteParticle)

function love.update(dt)
    c1:update(dt)    
    c2:update(dt)

    -- Delete all the particles in the deletion queue before drawing the particles
    -- DeleteParticle(deletion_queue)


end








local orientation_changer = 2*math.pi-math.pi/4
local text_table = {text.new(0,0), text.new(0,0), text.new(0,0), text.new(0,0), text.new(0,0), text.new(0,0), text.new(0,0)}

-- Prints the particle types and sees which one is active
local function printParticleTypes(graphics, width)

    local font = graphics.getFont()

    orientation_changer = orientation_changer
    

    graphics.print("Selected Particle", 10, 250)

    

    for i=1, #available_particles do
        if selected_particle == available_particles[i] then
            --local selected_particle_text = graphics.newText(font, {{1,0.2,0.2,1}, i..": "..selected_particle.name})
            text_table[i].text = graphics.newText(font, {{1,0.2,0.2,1}, i..": "..selected_particle.name})
            love.graphics.draw(text_table[i].text, 10,250+25*i, text_table[i].orientation, 1.2,1.2)
        else
            --local selected_particle_text = graphics.newText(font, {{1,1,1,1}, i..": ".. available_particles[i].name})
            text_table[i].text = graphics.newText(font, {{1,1,1,1}, i..": ".. available_particles[i].name})
            love.graphics.draw(text_table[i].text, 10,250+25*i, 0, 0.9, 0.9)
        end
    end

    if orientation_changer >= math.pi/4 then
        orientation_changer = 2*math.pi-math.pi/4
    end

end



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


    frame_draw = frame_draw + 1
    if frame_draw % math.ceil(love.timer.getFPS()/20) == 0 then
        if not profi_started then
            profi:start()
            profi_started = true
        end
        

        -- #region Goes through all the particles that are created and updates them, and adds them to the draw call --

        sprite_batch:clear()

        -- Adds all the particles to the sprite batch to prepare for draw
        for i=1, #particles do
            particles[i]:Draw(sprite_batch, particle_table)
        end


        if not profi_ended then
            profi:stop()
            profi:writeReport("Zdraw_report".. profiles ..".txt")
            profi:reset()
            profiles = profiles + 1
            profi_ended = true
        end


        -- endregion
        frame_draw = 0
    end


    -- Catches the event when the mouse button 2 is pressed --
    if love.mouse.isDown(2) then
        -- Calls the function to delete particles at the mouse location --
        delete_particle_mouse(ClampWidth(love.mouse.getX()/SCALE),  ClampHeight(love.mouse.getY()/SCALE))
    end

    -- Catches the event when the mouse button 1 is pressed --
    if love.mouse.isDown(1) then
        -- Calls the function to spawn particles at the mouse location --
        spawn_particle(ClampWidth(love.mouse.getX()/SCALE),  ClampHeight(love.mouse.getY()/SCALE), true)
    end

    -- If the scroll wheel is pressed down
    if love.mouse.isDown(3) then
        resetSize() -- Reset the spawning size back to its base value
    end

    

    -- for i=1, #sprite_batch_arr-1 do
    --     love.graphics.draw(sprite_batch_arr[i])
    -- end
    

    -- Previews where the mouse is so you know where you will destroy or place particles --
    preview_mouse(Clampf(love.mouse.getX()/SCALE, 1, WIDTH)-1,  Clampf(love.mouse.getY()/SCALE, 1, HEIGHT))

    
    -- Draws the entire Batch array in one call --
    love.graphics.draw(sprite_batch)
    love.graphics.draw(mouse_batch)

    
    printParticleTypes(love.graphics, love.graphics.getWidth())


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