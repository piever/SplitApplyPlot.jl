struct Spec
    transformation::Any
    data::Any
    mappings::Arguments
end

Spec(transformation=identity) = Spec(transformation, nothing, arguments())

data(df) = Spec(identity, df, arguments())
mapping(args...; kwargs...) = Spec(identity, nothing, arguments(args...; kwargs...))

function compose(f, g)
    f === identity && return g
    g === identity && return f
    return f∘g # should this be switched?
end

# FIXME: better name?
function combine(a1::Arguments, a2::Arguments)
    return Arguments(
        vcat(a1.positional, a2.positional),
        merge(a1.named, a2.named)
    )
end

function Base.:*(spec1::Spec, spec2::Spec)
    t1, t2 = spec1.transformation, spec2.transformation
    d1, d2 = spec1.data, spec2.data
    m1, m2 = spec1.mappings, spec2.mappings
    transformation = compose(t1, t2)
    data = isnothing(d2) ? d1 : d2
    mappings = combine(m1, m2)
    return Spec(transformation, data, mappings)
end

function (e::Entries)(s::Spec)
    return e(s.transformation, s.data, s.mappings.positional...; s.mappings.named...)
end