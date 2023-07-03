rednet.open("back") --opening wireless capabilities for the pocket computer (must be wireless/ender)

local location = vector.new(gps.locate())

location.x = math.floor(location.x)
location.y = math.floor(location.y)
location.z = math.floor(location.z)

print("Turtle ID: ")
local id = tonumber(io.read())

rednet.send(id, location, "locationVector")