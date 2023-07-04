rednet.open("back") --opening wireless capabilities for the pocket computer (must be wireless/ender)

local locationVector = vector.new(gps.locate())

locationVector.x = math.floor(locationVector.x)
locationVector.y = math.floor(locationVector.y)
locationVector.z = math.floor(locationVector.z)

print("Turtle ID: ")
local id = tonumber(io.read())

print("Length: ") 
local length = io.read() --z value

print("Height: ")
local height = io.read() --y value

print("Width: ")
local width = io.read() --x value

local volume = vector.new(length, height, width)

--sub area calculations

local numTurtles = 2

local startingBlock = vector.new(locationVector.x, (locationVector.y - 2), locationVector.z)

print("Starting Block:", startingBlock)

local finalBlock = vector.new(startingBlock.x + (volume.z - 1), startingBlock.y - volume.y, locationVector.z - (volume.x - 1))

print("Final Block:", finalBlock)

local sectionSizeX = math.floor((startingBlock.x + finalBlock.x + 1) / numTurtles)

print("Section Size X:", sectionSizeX)

local sectionSizeZ = finalBlock.z - (startingBlock.z + 1)

print("Section Size Z:", sectionSizeZ)

local function calculateSubArea(turtleIndex)
  local subAreaStartX = startingBlock.x - (turtleIndex - 1) * sectionSizeX
  local subAreaEndX = subAreaStartX - sectionSizeX - 1

  return subAreaStartX, startingBlock.z, subAreaEndX, finalBlock.z
end

for i = 1, numTurtles do
    local subAreaStartX, subAreaStartZ, subAreaEndX, subAreaEndZ = calculateSubArea(i)
    print("Turtle " .. i .. " Sub-Area: (" .. subAreaStartX .. "," .. subAreaStartZ .. ") to (" .. subAreaEndX .. "," .. subAreaEndZ .. ")")
end

--[[
local function sendSegment()
    local segment = vector.new()
end


local volume = vector.new(length, height, width)
rednet.send(id, location, "locationVector")
rednet.send(id, volume, "dimVector") 
]]--