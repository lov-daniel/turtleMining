
local id = 0

local idTable = {}

rednet.open("back") --opening wireless capabilities for the pocket computer (must be wireless/ender)

print(rednet.isOpen("back"))

-- determining location and dimensions
local locationVector = vector.new(gps.locate())

locationVector.x = math.floor(locationVector.x)
locationVector.y = math.floor(locationVector.y)
locationVector.z = math.floor(locationVector.z)

print("Turtle ID(s):")
print("(-1) to stop")
while id ~= -1 do
  id = tonumber(io.read())
  table.insert(idTable, id)
end

table.remove(idTable, #idTable)

print("Length: ") 
local length = io.read() --z value

print("Height: ")
local height = io.read() --y value

print("Width: ")
local width = io.read() --x value

local volume = vector.new(length, height, width)


--sub area calculations
local numTurtles = #idTable

local startingBlock = vector.new(locationVector.x, (locationVector.y - 1), locationVector.z)
local finalBlock = vector.new(startingBlock.x - (volume.z - 1), startingBlock.y - volume.y, locationVector.z - (volume.x - 1))
local sectionSizeX = math.floor(((startingBlock.x - finalBlock.x)) / numTurtles)
local sectionSizeZ = finalBlock.z - (startingBlock.z + 1)

local function calculateSubArea(turtleIndex)
  local subAreaStartX = startingBlock.x - (turtleIndex - 1) * sectionSizeX
  local subAreaEndX = subAreaStartX - sectionSizeX + 1

  return subAreaStartX, startingBlock.z, subAreaEndX, finalBlock.z
end


--wirelessly sending coordinates
local function sendSegment(x, y, z, idNum)
  local segmentStart = vector.new(x, y, z)
  print(segmentStart)
  print(idNum)
  rednet.send(idNum, segmentStart, "locationVector")
end


for i = 1, numTurtles do
    local subAreaStartX, subAreaStartZ, subAreaEndX, subAreaEndZ = calculateSubArea(i)
    local turtleID = tonumber(idTable[i])
    if i ~= numTurtles then
      print(turtleID)
      print("Turtle " .. turtleID .. " Sub-Area: (" .. subAreaStartX .. "," .. subAreaStartZ .. ") to (" .. subAreaEndX .. "," .. subAreaEndZ .. ")")
      sendSegment(subAreaStartX, startingBlock.y, subAreaStartZ, turtleID)
  end
    if i == numTurtles then
      print("Turtle " .. i .. " Sub-Area: (" .. subAreaStartX .. "," .. subAreaStartZ .. ") to (" .. finalBlock.x .. "," .. finalBlock.z .. ")")
      sendSegment(subAreaStartX, startingBlock.y, subAreaStartZ, turtleID)
    end
end

--[[
local volume = vector.new(length, height, width)
rednet.send(id, location, "locationVector")
rednet.send(id, volume, "dimVector") 
]]--