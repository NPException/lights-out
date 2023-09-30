import "CoreLibs/math"

local math <const> = playdate.math

local durationInTicks = nil -- how long the duration lasts
local deltaPerTick = nil -- range of 0.0 - 1.0 to shift per update
local tick = nil -- current tick in the update
local transitioned = false -- true when next() has been called

local next = nil -- function to call mid-transition

function transitionTo(nextFunc, duration, startTick)
    durationInTicks = duration or 30
    deltaPerTick = 1.0 / durationInTicks
    transitioned = false
    tick = startTick or 0
    next = nextFunc
end

function updateTransition()
    if tick >= durationInTicks then
        return
    end

    local delta = deltaPerTick * tick
    if not transitioned and delta >= 0.5 then
        next()
        transitioned = true
    end
    -- increment tick after current delta has been calculated
    tick = tick + 1

    local x = nil
    if not transitioned then
        x = math.lerp(200, -300, delta)
    else
        x = math.lerp(-300, 200, delta)
    end

    playdate.graphics.fillRect(x,0,300,160)
end

function sign(number)
    return (number > 0 and 1) or (number == 0 and 0) or -1
end