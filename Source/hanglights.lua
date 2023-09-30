local gfx <const> = playdate.graphics
local datastore <const> = playdate.datastore
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

    local frameCount = math.floor(time * 30 / 1000)
    self.frames = table.create(frameCount + 1)
    self.tick = 1;
    self.lastTick = frameCount + 1
    self.reverse = false

    local delta = time / frameCount
    local overlay = gfx.image.new(240,160,gfx.kColorBlack)

    for i = 0, frameCount do
        if i % 10 == 0 then
            coroutine.yield()
        end
        local imagePath = "gfx/light_renders/"..tostring(x).."_"..tostring(y).."_"..tostring(min).."_"..tostring(max).."_"..tostring(time).."_"..tostring(wid).."_i"..tostring(i)..".pdi"
        local frame = gfx.image.new(imagePath)

        if not frame then
            -- throw error if we're not in the simulator
            assert(not playdate.getStats(), "missing pre-built image: "..imagePath)
            -- pre-generate the blurred light cone (then copy them by hand from %PLAYDATE_SDK_PATH%/Disk/Data)
            gfx.pushContext(overlay)
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRect(0,0,240,160)
            gfx.setColor(gfx.kColorWhite)
            self:drawBeam(self.animator:valueAtTime(delta * i))
            gfx.popContext()

            frame = gfx.image.new(240,160,gfx.kColorWhite)
            gfx.pushContext(frame)
            overlay:drawBlurred(0,0,3,2,gfx.image.kDitherTypeBayer2x2)
            gfx.popContext()

            datastore.writeImage(frame, imagePath)
        end
        self.frames[i+1] = frame
    end
end

function Hanglight:drawFrame()
    self.frames[self.tick]:draw(0,0)
    self.tick = self.tick + (self.reverse and -1 or 1)
    if self.tick == 1 then
        self.reverse = false
    elseif self.tick == self.lastTick then
        self.reverse = true
    end
end

function Hanglight:drawBeam(animValue)
    local rad = math.rad(animValue)
    local sin = math.sin(rad) * self.amount
    gfx.fillTriangle(self.x, self.y * 2, self.x + 20 * self.wid - sin, 200, self.x - 20 * self.wid - sin, 200)
end

function Hanglight:drawLight()
    imgLight:drawCentered(self.x / 2, self.y)
end

function updateBeams()
    gfx.pushContext()
    gfx.setImageDrawMode(gfx.kDrawModeBlackTransparent)
    for i = 1, #hanglights do
        local l = hanglights[i]
        -- l:drawBeam(l.animator:currentValue())
        l:drawFrame()
    end
    gfx.popContext()
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
