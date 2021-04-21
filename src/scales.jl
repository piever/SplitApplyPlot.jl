#=
Conservative 7-color palette from Points of view: Color blindness, Bang Wong - Nature Methods
https://www.nature.com/articles/nmeth.1618?WT.ec_id=NMETH-201106
=#
const default_colors = [
    RGB(230/255, 159/255, 0/255),
    RGB(86/255, 180/255, 233/255),
    RGB(0/255, 158/255, 115/255),
    RGB(240/255, 228/255, 66/255),
    RGB(0/255, 114/255, 178/255),
    RGB(213/255, 94/255, 0/255),
    RGB(204/255, 121/255, 167/255),
]

function default_palettes()
    return arguments(
        color=default_colors,
        marker=[:circle, :xcross, :utriangle, :diamond, :dtriangle, :star8, :pentagon, :rect],
        linestyle=[:solid, :dash, :dot, :dashdot, :dashdotdot],
        side=[:left, :right],
        layout=wrap,
    )
end

Base.@kwdef struct CategoricalScale
    uniquevalues=automatic
    palette=automatic
    labels=automatic
end

function CategoricalScale(d::AbstractDict)
    uniquevalues, palette = collect(keys(d)), collect(values(d))
    return CategoricalScale(; uniquevalues, palette)
end

CategoricalScale(uniquevalues, palette) = CategoricalScale(; uniquevalues, palette)
CategoricalScale(v::AbstractVector) = CategoricalScale(uniquevalues=v)

uniquevalues(c::CategoricalScale) = c.uniquevalues

const categoricalscale = CategoricalScale()

struct ContinuousScale end
const continuousscale = ContinuousScale()

isacontinuousscale(::Function) = true
isacontinuousscale(::Any) = false

isacategoricalscale(::CategoricalScale) = true
isacategoricalscale(::Any) = false

rescale(values, scale::Function) = values # AbstractPlotting will take care of the rescaling

apply_palette(p::AbstractArray, idxs, _) = [cycle(p, idx) for idx in idxs]
apply_palette(::Automatic, idxs, _) = map(something, idxs)
apply_palette(p, idxs, _) = map(p, idxs)

# TODO: add more customizations?
struct Wrap end

const wrap = Wrap()

function apply_palette(::Wrap, idxs, uniquevalues)
    ncols = ceil(Int, sqrt(length(uniquevalues)))
    return [fldmod1(idx, ncols) for idx in idxs]
end

function rescale(values, scale::CategoricalScale)
    uniquevalues, palette = scale.uniquevalues, scale.palette
    idxs = indexin(values, uniquevalues)
    return apply_palette(palette, idxs, uniquevalues)
end

rescale(scale::CategoricalScale) = rescale(scale.uniquevalues, scale)

function default_scale(summary, palette)
    iscont = summary isa Tuple
    return if iscont
        identity
    else
        uv = sort!(collect(summary))
        labels = string.(uv)
        CategoricalScale(uv, palette, labels)
    end
end

# Logic to infer good scales
function default_scales(summaries, palettes)
    palettes = mergewith!((_, b) -> b, map(_ -> automatic, summaries), palettes)
    return map(default_scale, summaries, palettes)
end