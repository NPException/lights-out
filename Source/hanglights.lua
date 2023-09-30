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
    self.currentFrame = 0;
    self.lastFrame = frameCount
    self.reverse = false

    local delta = time / frameCount
    local sharpConeImage = gfx.image.new(240, 160, gfx.kColorBlack)

    local atlasPath = "gfx/baked_lights/hanglight_atlas_" .. x .. "_" .. y .. "_" .. min .. "_" .. max .. "_" .. time .. "_" .. wid .. ".pdi"
    -- TODO: maybe for a cleaner solution this could use imagetable instead
    self.atlas = gfx.image.new(atlasPath)
    if self.atlas then
        return
    end

    -- throw error if an image is missing and we're not in the simulator
    assert(not playdate.getStats(), "missing pre-built image: " .. atlasPath)

    -- pre-generate a strip of the blurred light cone
    self.atlas = gfx.image.new(240, 160 * (frameCount + 1), gfx.kColorWhite)

    for i = 0, frameCount do
        -- render sharp light cone
        gfx.pushContext(sharpConeImage)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(0, 0, 240, 160)
        gfx.setColor(gfx.kColorWhite)
        self:drawBeam(self.animator:valueAtTime(delta * i))
        gfx.popContext()

        -- render blurred light cone
        local frame = gfx.image.new(240, 160, gfx.kColorWhite)
        gfx.pushContext(frame)
        sharpConeImage:drawBlurred(0, 0, 3, 2, gfx.image.kDitherTypeBayer2x2)
        gfx.popContext()

        -- copy frame into atlas
        gfx.pushContext(self.atlas)
        frame:draw(0, i * 160)
        gfx.popContext()
    end

    -- store to disk for manual copy later
    datastore.writeImage(self.atlas, atlasPath)
end

function Hanglight:drawFrame()
    self.atlas:draw(0, -160 * self.currentFrame)
    self.currentFrame = self.currentFrame + (self.reverse and -1 or 1)
    if self.currentFrame == 0 then
        self.reverse = false
    elseif self.currentFrame == self.lastFrame then
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
