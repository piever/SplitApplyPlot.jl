function centers(edges::AbstractRange)
    s = step(edges)
    min, max = extrema(edges)
    return range(min + s / 2, step=s, length=length(edges) - 1)
end

edges(v::AbstractVector) = edges(range(extrema(v)...; length=length(v)))

function edges(centers::AbstractRange)
    s = step(centers)
    min, max = extrema(centers)
    return range(min - s / 2, step=s, length=length(centers) + 1)
end
