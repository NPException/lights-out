local gfx <const> = playdate.graphics
local math <const> = math

local fireflies = {}

function createFireflies(amnt, _size)
    amnt = amnt or 20
    _size = _size or 15
    for i = 1, amnt do
        local dir = math.random(0,359)
        local firefly = {
            x = math.random(0,200),
            y = math.random(0,120),
            aniOffset = math.random(0,200)/100,
            dx = math.sin(dir),
            dy = -math.cos(dir),
            size = _size
        }
        fireflies[#fireflies+1] = firefly
    end
end

function updateFireflies()
    for i = 1, #fireflies do
        local ffly = fireflies[i]
        gfx.fillCircleAtPoint(ffly.x,ffly.y,math.sin(playdate.getElapsedTime()+ffly.aniOffset)*2+ffly.size)
        ffly.x = ffly.x + (ffly.dx * 0.5)
        ffly.y = ffly.y + (ffly.dy * 0.5)

        if ffly.x > 235 then ffly.x = -30 elseif ffly.x < -30 then ffly.x = 235 end
        if ffly.y > 145 then ffly.y = -30 elseif ffly.y < -30 then ffly.y = 145 end
    end
end

function killFireflies()
    fireflies = {}
end
