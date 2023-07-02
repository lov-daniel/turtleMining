--variable setup
local direction = 1


--calibration sequence
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

local function directionCalc() --calculates the direction of the turtle
    for k, v in pairs(directionChange) do
        if vectorDiff == directionChange[k] then
            direction = k
        end
    end
end

local function correctDirection() -- resets direction
    if direction == -1 then
        direction = 4
    end
    direction = direction % 4
end

directionCalc()


--movement section
local function right()
    turtle.turnRight()
    direction = direction + 1
    correctDirection()
end

local function left()
    turtle.turnleft()
    direction = direction - 1
    correctDirection()
end

print("I am currently facing ", direction)
--functions
