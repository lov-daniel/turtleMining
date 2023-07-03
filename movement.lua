--variable setup
local direction = 1
local locationVector = nil
--rednet setup (this section sets up the wireless capabilities of the robot)
rednet.open("left")
repeat
    local _, message = rednet.receive("locationVector") --receives a message from the pocket computer
    locationVector = message
until locationVector ~= nil

--calibration sequence (section that setup the robots ability to read cardinal directions)
local directionChange = {
    [1] = vector.new(0, 0, -1), -- North
    [2] = vector.new(1, 0, 0), -- East
    [3] = vector.new(0, 0, 1), -- South
    [4] = vector.new(-1, 0, 0) -- West
}

local currentLocation = vector.new(gps.locate())
while turtle.detect() do
    turtle.dig()
end
turtle.forward()
local newLocation = vector.new(gps.locate())

local vectorDiff = newLocation - currentLocation

local function directionCalc() --calculates the current cardinal direction of the turtle using change in coordinate movement
    for k, v in pairs(directionChange) do
        if vectorDiff == directionChange[k] then
            direction = k
        end
    end
end

local function correctDirection() -- resets direction
    if direction == 0 then
        direction = 4
    end
    if direction == 5 then
        direction = 1
    end
    print("I am currently facing ", direction)
end

directionCalc()


--basic movement section
local function right()
    turtle.turnRight()
    direction = direction + 1
    if direction > 4 then
        direction = 1
    end
end

local function left()
    turtle.turnLeft()
    direction = direction - 1
    if direction < 1 then
        direction = 4
    end
    correctDirection()
end


--movement calculation
local diffLocation = vector.new(locationVector.x - currentLocation.x, locationVector.y - currentLocation.y, locationVector.z - currentLocation.z)


local function calcDiffX()
    if diffLocation.x > 0 then

        while direction ~= 2 do
            left()
        end
        while diffLocation.x ~= 0 do
            while turtle.detect() do
                turtle.dig()
            end
            turtle.forward()
            currentLocation = vector.new(gps.locate())
            diffLocation = locationVector - currentLocation
        end
    end

    if diffLocation.x < 0 then

        while direction ~= 4 do
            left()
        end

        while diffLocation.x ~= 0 do
            while turtle.detect() do
                turtle.dig()
            end
            turtle.forward()
            currentLocation = vector.new(gps.locate())
            diffLocation = locationVector - currentLocation
        end
    end
end

local function calcDiffY()
    if diffLocation.y > 0 then
        while diffLocation.y ~= 0 do
            while turtle.detectUp() do
                turtle.digUp()
            end
            turtle.up()
            currentLocation = vector.new(gps.locate())
            diffLocation = locationVector - currentLocation
        end
    end

    if diffLocation.y < 0 then
        while diffLocation.y ~= 0 do
            while turtle.detectDown() do
                turtle.digDown()
            end
            turtle.down()
            currentLocation = vector.new(gps.locate())
            diffLocation = locationVector - currentLocation
        end
    end
end
local function calcDiffZ()
    if diffLocation.z > 0 then
        while direction ~= 3 do
            left()
        end
        while diffLocation.z ~= 0 do
            while turtle.detect() do
                turtle.dig()
            end
            turtle.forward()
            currentLocation = vector.new(gps.locate())
            diffLocation = locationVector - currentLocation
        end           
    end

    if diffLocation.z < 0 then
        while direction ~= 1 do
            left()
        end
        while diffLocation.z ~= 0 do
            while turtle.detect() do
                turtle.dig()
            end
            turtle.forward()
            currentLocation = vector.new(gps.locate())
            diffLocation = locationVector - currentLocation
        end
    end
end



while diffLocation ~= vector.new(0, 0, 0) do
    calcDiffX()
    calcDiffY()
    calcDiffZ()
end

--[[mining sequence
local currentLocation = vector.new(gps.locate())

while currentLocation.y < 15 do
    while turtle.detect() == true do
        turtle.dig()
    end
    turtle.forward()
    turtle.digUp()
    turtle.digDown()
    if turtle.detectDown() == false then
        turtle.placeDown()
    end
    local currentLocation = vector.new(gps.locate())
end
]]--

