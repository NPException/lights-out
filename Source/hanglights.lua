local gfx <const> = playdate.graphics
local math <const> = math

local hanglights = {}

local imgLight = gfx.image.new("gfx/hanglight")

class("Hanglight").extends()

function Hanglight:init(x, y, min, max, time, wid)
    self.x = x * 2
    self.y = y
    self.wid = wid
    self.amount = max - min
    self.animator = gfx.animator.new(time, min, max, playdate.easingFunctions.inOutQuad)
    self.animator.reverses = true
    self.animator.repeatCount = -1
    hanglights[#hanglights + 1] = self
end

function Hanglight:drawBeam()
    local rad = math.rad(self.animator:currentValue())
    local sin = math.sin(rad) * self.amount
    gfx.fillTriangle(self.x, self.y * 2, self.x + 20 * self.wid - sin, 200, self.x - 20 * self.wid - sin, 200)
end
function Hanglight:drawLight()
    imgLight:drawCentered(self.x / 2, self.y)
end

function updateBeams()
    for i = 1, #hanglights do
        local l = hanglights[i]
        l:drawBeam()
    end
end

function rmLights()
    for i = 1, #hanglights do
        table.remove(hanglights)
    end
end

function updateLights()
    for i = 1, #hanglights do
        local l = hanglights[i]
        l:drawLight()
    end
end

function killAll()
    rmLights()
    curBG:remove()
end
