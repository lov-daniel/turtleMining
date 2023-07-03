rednet.open("back") --opening wireless capabilities for the pocket computer (must be wireless/ender)

local location = vector.new(gps.locate())

location.x = math.floor(location.x)
location.y = math.floor(location.y)
location.z = math.floor(location.z)

print("Turtle ID: ")
local id = tonumber(io.read())

print("Length: ")
local length = io.read()

print("Height: ")
local height = io.read()

print("Width: ")
local width = io.read()

local volume = vector.new(length, height, width)

rednet.send(id, location, "locationVector")
rednet.send(id, volume, "dimVector") 