# Conservative 7-color palette
# Wong, Bang. "Points of view: Color blindness." (2011): 441.
# https://www.nature.com/articles/nmeth.1618?WT.ec_id=NMETH-201106

function default_palettes()
    return arguments(
        color=[
            RGB(0/255, 114/255, 178/255), # dark blue
            RGB(230/255, 159/255, 0/255), # orange
            RGB(0/255, 158/255, 115/255), # green
            RGB(204/255, 121/255, 167/255), # pink
            RGB(213/255, 94/255, 0/255), # red
            RGB(86/255, 180/255, 233/255), # light blue
            RGB(240/255, 228/255, 66/255), # yellow
        ],
        marker=[:circle, :utriangle, :cross, :rect, :diamond, :dtriangle, :pentagon, :xcross],
        linestyle=[:solid, :dash, :dot, :dashdot, :dashdotdot],
        side=[:left, :right],
        layout=wrap,
    )
end

# Batlow colormap
# Crameri, Fabio, Grace E. Shephard, and Philip J. Heron. "The misuse of colour in science communication." Nature communications 11.1 (2020): 1-10.
# https://www.nature.com/articles/s41467-020-19160-7?source=techstories.org

function opinionated_defaults()
    return (
        color=:gray15,
        strokecolor=RGBA(0, 0, 0, 0),
        outlierstrokecolor=RGBA(0, 0, 0, 0),
        mediancolor=:white,
        marker=:circle,
        markersize=15,
        linewidth=1.5,
        medianlinewidth=1.5,
        colormap=:batlow,
    )
end

apply_palette(p::AbstractVector, uv) = [cycle(p, idx) for idx in eachindex(uv)]
apply_palette(::Automatic, uv) = eachindex(uv)
apply_palette(p, uv) = map(p, eachindex(uv))

# TODO: add more customizations?
struct Wrap end

const wrap = Wrap()

function apply_palette(::Wrap, uv)
    ncols = ceil(Int, sqrt(length(uv)))
    return [fldmod1(idx, ncols) for idx in eachindex(uv)]
end

struct ContinuousScale{T, F}
    f::F
    extrema::Tuple{T, T}
end

rescale(values::AbstractVector{<:Number}, c::ContinuousScale) = values # Is this ideal?
function rescale(values::AbstractVector{<:Union{Date, DateTime}}, c::ContinuousScale)
    @assert c.f === identity
    min = minimum(values)
    return @. convert(Millisecond, DateTime(values) - DateTime(min)) / Millisecond(1)
end

struct CategoricalScale{S, T}
    data::S
    plot::T
end

function rescale(values, c::CategoricalScale)
    idxs = indexin(values, c.data)
    return c.plot[idxs]
end

Base.length(c::CategoricalScale) = length(c.data)

function default_scale(summary, palette)
    iscont = summary isa Tuple
    return if iscont
        f = palette isa Function ? palette : identity
        ContinuousScale(f, summary)
    else
        plot = apply_palette(palette, summary)
        return CategoricalScale(summary, plot)
    end
end

# Logic to infer good scales
function default_scales(summaries, palettes)
    palettes = merge!(map(_ -> automatic, summaries), palettes)
    return map(default_scale, summaries, palettes)
end

# Logic to create ticks from a scale
function ticks(scale::CategoricalScale)
    u = map(string, scale.data)
    return (axes(u, 1), u)
end

function ticks(scale::ContinuousScale)
    return continuousticks(scale.extrema...)
end

continuousticks(min, max) = automatic

function continuousticks(min::T, max::T) where T<:Union{Date, DateTime}
    @show dates, _, _ = optimize_ticks(min, max)
    xvalues = rescale(dates, ContinuousScale(identity, (min, max)))
    return (xvalues, string.(T.(dates)))
end