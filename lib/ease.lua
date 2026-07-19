Ease = {}

function Ease.linear(t)
    return t
end

function Ease.inQuad(t)
    return t^2
end

function Ease.outQuad(t)
    return 1 - (1 - t)^2
end

function Ease.inOutQuad(t)
    if t < 0.5 then
        return 2 * t * t
    end
    return 1 - ((-2 * t + 2)^2) / 2
end

function Ease.inCubic(t)
    return t^3
end

function Ease.outCubic(t)
    return 1 - (1 - t)^3
end

function Ease.inOutCubic(t)
    if t < 0.5 then
        return 4 * t^3
    end
    return 1 - ((-2 * t + 2)^3) / 2
end

return Ease