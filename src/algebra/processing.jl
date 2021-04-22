const ArrayLike = Union{AbstractArray, Tuple}
const StringLike = Union{AbstractString, Symbol}

struct DimsSelector{N}
    dims::NTuple{N, Int}
end
dims(args...) = DimsSelector(args)

function (d::DimsSelector)(c::CartesianIndex{N}) where N
    t = ntuple(N) do n
        return n in d.dims ? c[n] : 1
    end
    return CartesianIndex(t)
end

struct NameTransformationLabel
    name::Any
    transformation::Any
    label::String
end

# Also support integer column names?
NameTransformationLabel(x::StringLike) = NameTransformationLabel(x => identity => x)

NameTransformationLabel(x::DimsSelector) = NameTransformationLabel(x => identity => "")

function NameTransformationLabel(x::Pair{<:Any, <:StringLike})
    columnname, label = x
    return NameTransformationLabel(columnname => identity => label)
end

function NameTransformationLabel(x::Pair{<:Any, <:Any})
    columnname, transformation = x
    return NameTransformationLabel(columnname => transformation => columnname)
end

function NameTransformationLabel(x::Pair{<:Any, <:Pair})
    columnname, transformation_label = x
    transformation, label = transformation_label
    return NameTransformationLabel(columnname, transformation, string(label))
end

maybewrap(x::ArrayLike) = x
maybewrap(x) = fill(x)

apply_context(data, c::CartesianIndex, name) = getcolumn(data, Symbol(name))

function apply_context(data, c::CartesianIndex, name::DimsSelector)
    val = name(c)
    l = length(rows(data))
    return fill(val, l)
end

struct LabeledArray
    label::AbstractString
    array::AbstractArray
end

getlabel(x::LabeledArray) = x.label
getarray(x::LabeledArray) = x.array

# FIXME: improve automatic labeling for broadcasted case
function process_data(data, mappings′)
    mappings = map(mappings′) do x
        return map(NameTransformationLabel, maybewrap(x))
    end
    ax = Broadcast.combine_axes(mappings.positional..., values(mappings.named)...)
    return map(CartesianIndices(ax)) do c
        labeledarrays = map(mappings) do m
            ntl = m[Broadcast.newindex(m, c)]
            name, transformation, label = ntl.name, ntl.transformation, ntl.label
            names = maybewrap(name)
            cols = map(name -> apply_context(data, c, name), names)
            res = map(transformation, cols...)
            return LabeledArray(label, res)
        end
        labels, arrays = map(getlabel, labeledarrays), map(getarray, labeledarrays)
        return LabeledEntry(Any, arrays, labels, Dict{Symbol, Any}())
    end
end

function process_transformations(layers::Layers)
    nested = map(process_transformations, layers)
    return reduce(vcat, nested)
end

function process_transformations(layer::Layer)
    init = vec(process_data(layer.data, layer.mappings))
    return foldl(process_transformations, layer.transformations; init)
end

function process_transformations(v::AbstractArray{LabeledEntry}, f)
    results = [process_transformations(le, f) for le in v]
    return reduce(vcat, results)
end

process_transformations(le::LabeledEntry, f) = vec(maybewrap(f(le)))
