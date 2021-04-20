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

const categoricalscale = CategoricalScale()

struct ContinuousScale end
const continuousscale = ContinuousScale()

isacontinuousscale(::Function) = true
isacontinuousscale(::Any) = false

isacategoricalscale(::CategoricalScale) = true
isacategoricalscale(::Any) = false

# FIXME: move the piracy bit to AbstractPlotting
Broadcast.broadcastable(a::Union{CategoricalScale, ContinuousScale, Automatic}) = Ref(a)

# should this be done in place for efficiency?
function merge_scales(sc1::CategoricalScale, sc2::CategoricalScale) 
    uniquevalues = union(sc1.uniquevalues, sc2.uniquevalues)
    # FIXME: check that palettes are consistent?
    palette = sc2.palette === automatic ? sc1.palette : sc2.palette
    return CategoricalScale(uniquevalues, palette)
end

function merge_scales(f1::Function, f2::Function)
    @assert f1 === f2
    return f1
end

rescale(values, scale::Function) = values # AbstractPlotting will take care of the rescaling

to_function(v::AbstractArray) = Base.Fix1(cycle, v)
to_function(v::Automatic) = something
to_function(f::Function) = f

function rescale(values, scale::CategoricalScale)
    uniquevalues, palette = scale.uniquevalues, scale.palette
    idxs = indexin(values, uniquevalues)
    f = to_function(palette)
    return f.(idxs)
end

rescale(scale::CategoricalScale) = rescale(scale.uniquevalues, scale)

function default_scale(column, scale, palette)
    scale === automatic && (scale = iscontinuous(column) ? continuousscale : categoricalscale)
    scale isa NamedTuple && (scale = CategoricalScale(; scale...)) # Do we want this?
    scale isa ContinuousScale && (scale = identity)
    scale isa Function && return scale
    @assert scale isa CategoricalScale
    cs = scale === automatic ? categoricalscale : scale
    uv = cs.uniquevalues === automatic ? uniquesort(column) : cs.uniquevalues
    labels = cs.labels === automatic ? string.(uv) : cs.labels
    p = cs.palette === automatic ? palette : cs.palette
    return CategoricalScale(uv, p, labels)
end

# Logic to infer good scales
function default_scales(mappings, scales)
    palettes = mergewith!((_, b) -> b, map(_ -> automatic, mappings), default_palettes())
    return map(default_scale, mappings, scales, palettes)
end