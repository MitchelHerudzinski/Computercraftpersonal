local modem = peripheral.find("modem", function(name, m) return m.isWireless() end)
if not modem then
    error("No wireless modem found!")
end

local CHANNEL = 123
local REPLY_CHANNEL = 124

modem.open(REPLY_CHANNEL)

local function sendSpeed(speed)
    modem.transmit(CHANNEL, REPLY_CHANNEL, {
        command = "set",
        speed = speed
    })
end

local function requestSpeed()
    modem.transmit(CHANNEL, REPLY_CHANNEL, "get")

    local timer = os.startTimer(2)
    while true do
        local event, p1, p2, p3, p4, p5 = os.pullEvent()
        if event == "modem_message" then
            local side, channel, replyChannel, message, distance = p1, p2, p3, p4, p5
            if channel == REPLY_CHANNEL then
                return message
            end
        elseif event == "timer" and p1 == timer then
            return nil
        end
    end
end

while true do
    term.clear()
    term.setCursorPos(1, 1)
    print("=== RSC REMOTE ===")
    print("1) Set RPM")
    print("2) Get RPM")
    print("3) Stop")
    print("4) Exit")
    print()
    write("> ")

    local choice = read()

    if choice == "1" then
        write("Enter RPM (-256 to 256): ")
        local input = read()
        local speed = tonumber(input)

        if speed then
            speed = math.floor(speed)
            if speed < -256 then speed = -256 end
            if speed > 256 then speed = 256 end
            sendSpeed(speed)
            print("Sent: " .. speed .. " RPM")
        else
            print("Invalid number")
        end
        sleep(1.5)

    elseif choice == "2" then
        print("Requesting current RPM...")
        local current = requestSpeed()
        if current ~= nil then
            print("Current target speed: " .. tostring(current) .. " RPM")
        else
            print("No response")
        end
        sleep(2)

    elseif choice == "3" then
        modem.transmit(CHANNEL, REPLY_CHANNEL, "stop")
        print("Stop signal sent")
        sleep(1.5)

    elseif choice == "4" then
        break
    else
        print("Invalid option")
        sleep(1.2)
    end
end