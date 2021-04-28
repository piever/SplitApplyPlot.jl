# Conservative 7-color palette from Points of view: Color blindness, Bang Wong - Nature Methods
# https://www.nature.com/articles/nmeth.1618?WT.ec_id=NMETH-201106

using AbstractPlotting: RGB

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

function opinionated_defaults()
    return (strokecolor=:white, color=:gray15, marker=:circle, markersize=15, linewidth=1.5)
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

rescale(values, c::ContinuousScale) = values # Is this ideal?

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