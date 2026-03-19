local modem = peripheral.find("modem", function(_, m) return m.isWireless() end)
if not modem then
    error("No wireless modem found!")
end

local CHANNEL = 123
local REPLY_CHANNEL = 124

modem.open(REPLY_CHANNEL)

local speed = 0

local buttons = {
    { label = "-64", x1 = 1,  y1 = 4, x2 = 8,  y2 = 6, action = function() speed = speed - 64 end },
    { label = "-16", x1 = 10, y1 = 4, x2 = 17, y2 = 6, action = function() speed = speed - 16 end },

    { label = " 0 ", x1 = 1,  y1 = 8, x2 = 8,  y2 = 10, action = function() speed = 0 end },
    { label = "+16", x1 = 10, y1 = 8, x2 = 17, y2 = 10, action = function() speed = speed + 16 end },

    { label = "+64", x1 = 1,  y1 = 12, x2 = 8,  y2 = 14, action = function() speed = speed + 64 end },
    { label = "MAX", x1 = 10, y1 = 12, x2 = 17, y2 = 14, action = function() speed = 256 end },

    { label = "MIN", x1 = 1,  y1 = 16, x2 = 8,  y2 = 18, action = function() speed = -256 end },
    { label = "STOP",x1 = 10, y1 = 16, x2 = 17, y2 = 18, action = function() speed = 0 end },
}

local function clamp(n, min, max)
    if n < min then return min end
    if n > max then return max end
    return math.floor(n)
end

local function sendSpeed()
    speed = clamp(speed, -256, 256)
    modem.transmit(CHANNEL, REPLY_CHANNEL, {
        command = "set",
        speed = speed
    })
end

local function centerText(y, text)
    local w = term.getSize()
    local x = math.floor((w - #text) / 2) + 1
    term.setCursorPos(x, y)
    term.write(text)
end

local function drawBox(x1, y1, x2, y2, text)
    for y = y1, y2 do
        term.setCursorPos(x1, y)
        term.write(string.rep(" ", x2 - x1 + 1))
    end

    local textX = x1 + math.floor(((x2 - x1 + 1) - #text) / 2)
    local textY = y1 + math.floor((y2 - y1) / 2)
    term.setCursorPos(textX, textY)
    term.write(text)
end

local function drawUI()
    term.clear()
    term.setCursorPos(1, 1)
    centerText(1, "RSC Remote")
    centerText(2, "RPM: " .. tostring(speed))

    for _, b in ipairs(buttons) do
        drawBox(b.x1, b.y1, b.x2, b.y2, b.label)
    end
end

local function inside(x, y, b)
    return x >= b.x1 and x <= b.x2 and y >= b.y1 and y <= b.y2
end

drawUI()

while true do
    local event, button, x, y = os.pullEvent()

    if event == "mouse_click" then
        for _, b in ipairs(buttons) do
            if inside(x, y, b) then
                b.action()
                speed = clamp(speed, -256, 256)
                sendSpeed()
                drawUI()
                break
            end
        end

    elseif event == "key" then
        if button == keys.q then
            term.clear()
            term.setCursorPos(1, 1)
            print("Closed")
            break
        end
    end
end
