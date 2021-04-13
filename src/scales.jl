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

struct CategoricalScale end
const categoricalscale = CategoricalScale()

struct ContinuousScale end
const continuousscale = ContinuousScale()

isacontinuousscale(::Pair{<:NTuple{2, Any}, <:Function}) = true
isacontinuousscale(::Any) = false

isadiscretescale(::AbstractDict) = true
isadiscretescale(::Any) = false

extend_extrema((l1, u1), (l2, u2)) = min(l1, l2), max(u1, u2)

# should this be done in place for efficiency?
merge_scales(sc1::AbstractDict, sc2::AbstractDict) = merge(sc1, sc2)
merge_scales((i1, f1)::Pair, (i2, f2)::Pair) = extend_extrema(i1, i2) => f2

rescale(value, scale) = value
rescale(value, scale::AbstractDict) = [scale[val] for val in value]

# Logic to infer good scales
function default_scales(mappings, scales)
    palettes = mergewith!((_, b) -> b, map(_ -> automatic, mappings), default_palettes())
    return map(mappings, scales, palettes) do v, scale, palette
        if isadiscretescale(scale) || isacontinuousscale(scale)
            # fully specified scale
            return scale
        elseif iscontinuous(v) && (scale in (automatic, continuousscale) || scale isa Function)
            # unspecified continuous scale
            f = scale isa Function ? scale : identity
            return extrema(v) => f
        else
            # unspecified categorical scale
            keys = scale isa AbstractVector ? scale : uniquesort(v)
            values = palette === automatic ? eachindex(keys) : cycle.(Ref(palette), eachindex(keys))
            return LittleDict(keys, values)
        end
    end
end