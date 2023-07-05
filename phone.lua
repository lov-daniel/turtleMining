
local id = 0

local idTable = {}
local areaTable = {}
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
local length = tonumber(io.read()) --z value

print("Height: ")
local height = tonumber(io.read()) --y value

print("Width: ")
local width = tonumber(io.read()) --x value

local volume = vector.new(length, height, width)


--sub area calculations
local numTurtles = #idTable

local XBlocksRemaining = 0
local XPreviousMining = 0
local previousClear = 0

local startingBlock = vector.new(locationVector.x, (locationVector.y - 1), locationVector.z)
local finalBlock = vector.new(startingBlock.x - (volume.z - 1), startingBlock.y - volume.y, locationVector.z - (volume.x - 1))

local XBlocksRemaining = width

local sectionSizeX = math.floor(((startingBlock.x - finalBlock.x)) / numTurtles)
local sectionSizeZ = finalBlock.z - (startingBlock.z + 1)

print("Section Size X: ", sectionSizeX)

local function calculateSubArea(turtleIndex)
  local subAreaStartX = startingBlock.x - (turtleIndex - 1) * (sectionSizeX + 1)
  local subAreaEndX = subAreaStartX - sectionSizeX

  if turtleIndex == 1 then
    table.insert(areaTable, subAreaStartX)
  end

  return subAreaStartX, startingBlock.z, subAreaEndX, finalBlock.z
end

local function calculateRemaining(subStart, remainder)
  local finalValue = subStart - remainder
  table.insert(areaTable, finalValue)
  return finalValue
end

-- -1, -4 

--wirelessly sending coordinates
local function sendSegment(x, y, z, idNum, turtleOrder)
  local segmentStart = vector.new(x, y, z)

  if turtleOrder > 1 then
    segmentStart.x = calculateRemaining(areaTable[turtleOrder - 1], sectionSizeX)
    print("Next Starting Segment:", segmentStart.x)
    end

  local sizeVector = vector.new(length, height, sectionSizeX)

  if XBlocksRemaining >= sectionSizeX then
    XBlocksRemaining = XBlocksRemaining - (sectionSizeX)
  end

  if XBlocksRemaining ~= 0 and turtleOrder == #idTable then
    sizeVector.z = XBlocksRemaining + sectionSizeX 
  end

 
  print("Blocks left over:", XBlocksRemaining)
  

  print("Turtle " .. turtleOrder .. " will mine " .. sizeVector.z .. " blocks.")

  rednet.send(idNum, segmentStart, "locationVector")

  print(segmentStart.x, segmentStart.y, segmentStart.z)

  rednet.send(idNum, sizeVector, "dimVector")
end


for i = 1, numTurtles do
    local subAreaStartX, subAreaStartZ, subAreaEndX, subAreaEndZ, dimX = calculateSubArea(i)
    if i ~= numTurtles then
      local turtleID = tonumber(idTable[i])
      print("Turtle " .. i .. " Sub-Area: (" .. subAreaStartX .. "," .. subAreaStartZ .. ") to (" .. subAreaEndX .. "," .. subAreaEndZ .. ")")
      sendSegment(subAreaStartX, startingBlock.y, subAreaStartZ, turtleID, i)
  end
    if i == numTurtles then
      print("Turtle " .. i .. " Sub-Area: (" .. subAreaStartX .. "," .. subAreaStartZ .. ") to (" .. finalBlock.x .. "," .. finalBlock.z .. ")")
      local turtleID = tonumber(idTable[i])
      sendSegment(subAreaStartX, startingBlock.y, subAreaStartZ, turtleID, i)
    end
end

--[[
local volume = vector.new(length, height, width)
rednet.send(id, location, "locationVector")
rednet.send(id, volume, "dimVector") 
]]--