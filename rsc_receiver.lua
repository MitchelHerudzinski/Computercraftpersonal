local rsc = peripheral.find("Create_RotationSpeedController")
if not rsc then
    error("No Rotation Speed Controller found!")
end

local modem = peripheral.find("modem", function(name, m) return m.isWireless() end)
if not modem then
    error("No wireless modem found!")
end

local CHANNEL = 123

modem.open(CHANNEL)

local function clamp(n, min, max)
    if n < min then return min end
    if n > max then return max end
    return n
end

print("RSC receiver started")
print("Listening on channel " .. CHANNEL)

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    if channel == CHANNEL then
        if type(message) == "number" then
            local speed = clamp(math.floor(message), -256, 256)
            rsc.setTargetSpeed(speed)
            print("Set speed to " .. speed .. " RPM")
        elseif type(message) == "table" and message.command == "set" and type(message.speed) == "number" then
            local speed = clamp(math.floor(message.speed), -256, 256)
            rsc.setTargetSpeed(speed)
            print("Set speed to " .. speed .. " RPM")
        elseif message == "get" then
            modem.transmit(replyChannel, CHANNEL, rsc.getTargetSpeed())
        elseif message == "stop" then
            rsc.setTargetSpeed(0)
            print("Stopped controller")
        end
    end
end