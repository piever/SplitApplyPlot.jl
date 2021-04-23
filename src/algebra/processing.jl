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

compute_label(data, name::StringLike) = string(name)
compute_label(data, name::Integer) = string(columnnames(data)[name])
compute_label(data, name::DimsSelector) = ""

struct NameTransformationLabel
    name::Any
    transformation::Any
    label::String
end

getname(ntl::NameTransformationLabel) = ntl.name
gettransformation(ntl::NameTransformationLabel) = ntl.transformation
getlabel(ntl::NameTransformationLabel) = ntl.label

function NameTransformationLabel(name, transformation, label::Symbol)
    return NameTransformationLabel(name, transformation, string(label))
end

function NameTransformationLabel(data, x::Union{StringLike, Integer, DimsSelector})
    return NameTransformationLabel(x, identity, compute_label(data, x))
end

function NameTransformationLabel(data, x::Pair{<:Any, <:StringLike})
    name, label = x
    return NameTransformationLabel(name, identity, label)
end

function NameTransformationLabel(data, x::Pair{<:Any, <:Any})
    name, transformation = x
    label = compute_label(data, name)
    return NameTransformationLabel(name, transformation, label)
end

function NameTransformationLabel(data, x::Pair{<:Any, <:Pair})
    name, transformation_label = x
    transformation, label = transformation_label
    return NameTransformationLabel(name, transformation, label)
end

maybewrap(x::ArrayLike) = x
maybewrap(x) = fill(x)

apply_context(data, names::ArrayLike) = map(Base.Fix1(apply_context, data), names)

apply_context(data, name::StringLike) = getcolumn(data, Symbol(name))

function apply_context(data, idx::Integer)
    name = columnnames(data)[idx]
    return getcolumn(data, name)
end

# function apply_context(data, name::DimsSelector)
#     val = name(c)
#     l = length(rows(data))
#     return fill(val, l)
# end

struct LabeledArray
    label::AbstractString
    array::AbstractArray
end

getlabel(x::LabeledArray) = x.label
getarray(x::LabeledArray) = x.array

function process_data(data, mappings)
    labeledarrays = map(mappings) do x
        ntls = map(Base.Fix1(NameTransformationLabel, data), maybewrap(x))
        names = map(getname, ntls)
        transformations = map(gettransformation, ntls)
        labels = map(getlabel, ntls)
        res = map(transformations, names) do transformation, name
            cols = apply_context(data, maybewrap(name))
            map(transformation, cols...)
        end
        return LabeledArray(join(labels, ' '), unnest(res))
    end
    labels, arrays = map(getlabel, labeledarrays), map(getarray, labeledarrays)
    return LabeledEntry(Any, arrays, labels, Dict{Symbol, Any}())
end

function process_transformations(layers::Layers)
    nested = map(process_transformations, layers)
    return reduce(vcat, nested)
end

function process_transformations(layer::Layer)
    init = [process_data(layer.data, layer.mappings)]
    return foldl(process_transformations, layer.transformations; init)
end

function process_transformations(v::AbstractArray{LabeledEntry}, f)
    results = [process_transformations(le, f) for le in v]
    return reduce(vcat, results)
end

process_transformations(le::LabeledEntry, f) = vec(maybewrap(f(le)))
