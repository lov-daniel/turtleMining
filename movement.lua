--variable setup
local direction = 1
local locationVector = nil
local dimVector = nil
local row = 0
local layerCount = 0


--rednet setup (this section sets up the wireless capabilities of the robot)
rednet.open("left")
repeat
    local _, message = rednet.receive("locationVector") --receives a message from the pocket computer
    locationVector = message
until locationVector ~= nil -- will repeat until locationVector is assigned a value

print(locationVector)

repeat
    local _, message = rednet.receive("dimVector") --receives a message from the pocket computer
    dimVector = message
until dimVector ~= nil

print(dimVector)


--check for turtle
local function inspectBlock()
    local has_frontBlock, frontBlock = turtle.inspect()
    if has_frontBlock == false then
        return
    end

    if frontBlock.name == "computercraft:turtle_advanced" then
        print("Turtle in front!")
        os.sleep(1)
    end

    local has_upBlock, upBlock = turtle.inspectUp()
    if has_upBlock == false then
        return
    end

    if upBlock.name == "computercraft:turtle_advanced" then
        print("Turtle above")
        os.sleep(1)
    end


    local has_downBlock, downBlock = turtle.inspectDown()
    if has_upBlock == false then
        return
    end

    if downBlock.name == "computercraft:turtle_advanced" then
        print("Turtle below!")
        os.sleep(1)
    end
end


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
local newLocation = vector.new(gps.locate())

local vectorDiff = newLocation - currentLocation

local function directionCalc() --calculates the current cardinal direction of the turtle using change in coordinate movement
    for k, v in pairs(directionChange) do
        if vectorDiff == directionChange[k] then
            direction = k
        end
    end
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
end


--movement calculation
local diffLocation = vector.new(locationVector.x - currentLocation.x, locationVector.y - currentLocation.y, locationVector.z - currentLocation.z)


local function calcDiffX() --calculates the difference between the current location and the desired location (x)
    if diffLocation.x > 0 then 

        while direction ~= 2 do --turns left until direction is correct (east)
            left()
        end
        while diffLocation.x ~= 0 do
            while turtle.detect() do
                turtle.dig()
            end
            turtle.forward()
            currentLocation = vector.new(gps.locate()) --constantly updates the current location once a cycle has completed
            diffLocation = locationVector - currentLocation
        end
    end

    if diffLocation.x < 0 then

        while direction ~= 4 do --turns left until direction is correct (west)
            left()
        end

        while diffLocation.x ~= 0 do
            while turtle.detect() do
                turtle.dig()
            end
            turtle.forward()
            currentLocation = vector.new(gps.locate()) --constantly updates the current location once a cycle has completed
            diffLocation = locationVector - currentLocation
        end
    end
end

local function calcDiffY() --calculates the difference between the current location and the desired location (y)
    if diffLocation.y > 0 then --if the target is above ground, then the turtle will begin to move upwards
        while diffLocation.y ~= 0 do 
            while turtle.detectUp() do
                turtle.digUp()
            end
            turtle.up()
            currentLocation = vector.new(gps.locate()) --constantly updates the current location once a cycle has completed
            diffLocation = locationVector - currentLocation
        end
    end

    if diffLocation.y < 0 then --if the target is below ground, then the turtle will begin to move downwards
        while diffLocation.y ~= 0 do
            while turtle.detectDown() do
                turtle.digDown()
            end
            turtle.down()
            currentLocation = vector.new(gps.locate()) --constantly updates the current location once a cycle has completed
            diffLocation = locationVector - currentLocation
        end
    end
end

local function calcDiffZ() --calculates the difference between the current location and the desired location (z)
    if diffLocation.z > 0 then
        while direction ~= 3 do --turns left until direction is correct (south)
            left()
        end
        while diffLocation.z ~= 0 do
            while turtle.detect() do
                turtle.dig()
            end
            turtle.forward()
            currentLocation = vector.new(gps.locate()) --constantly updates the current location once a cycle has completed
            diffLocation = locationVector - currentLocation
        end           
    end

    if diffLocation.z < 0 then
        while direction ~= 1 do --turns left until direction is correct (north)
            left()
        end
        while diffLocation.z ~= 0 do
            while turtle.detect() do
                turtle.dig()
            end
            turtle.forward()
            currentLocation = vector.new(gps.locate()) --constantly updates the current location once a cycle has completed
            diffLocation = locationVector - currentLocation
        end
    end
end

while diffLocation ~= vector.new(0, 0, 0) do
    calcDiffX()
    calcDiffY()
    calcDiffZ()
end


--mining calculations

local startingBlock = vector.new(locationVector.x, locationVector.y, locationVector.z)
print(startingBlock)
local finalBlock = vector.new(startingBlock.x - (dimVector.z - 1), startingBlock.y - dimVector.y, locationVector.z + (dimVector.x - 1))
print(finalBlock)

--mining functions
local function clearLength()
    print("Clearing a row")
    for i = 1, dimVector.x - 1, 1 do
        while turtle.detect() do
            inspectBlock()
            turtle.dig()
        end
        turtle.forward()
    end
    row = row + 1
end

local function depositLayer()
    if row % 2 == 0 then
        right()
        turtle.forward()
        left()
        print("Depositing")
    end

    if row % 2 == 1 then
        left()
        turtle.forward()
        right()
        print("Depositing")
    end

    turtle.select(1)
    turtle.place()
    turtle.refuel()
    for i = 1, 16, 1 do
        turtle.select(i)
        turtle.drop()
    end
    turtle.select(1)
    turtle.dig()
end

local function clearLayer()
    for i = 1, dimVector.z, 1 do
        clearLength()
        if row % 2 == 0 then
            right()
            while turtle.detect() do
                inspectBlock()
                turtle.dig()
            end
            turtle.forward()
            right()
        end

        if row % 2 == 1 then
            left()
            while turtle.detect() do
                inspectBlock()
                turtle.dig()
            end
            turtle.forward()
            left()
        end
    end
            
    depositLayer()
    turtle.digDown()
    turtle.down()
    layerCount = layerCount + 1
    row = row - 1
end


--exection
turtle.digDown()
turtle.down()
while layerCount ~= dimVector.y do
    clearLayer()
end


