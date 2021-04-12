struct Arguments
    positional::Vector{Any}
    named::Dict{Symbol, Any}
end

function arguments(args...; kwargs...)
    positional = collect(Any, args)
    named = Dict{Symbol, Any}(kwargs)
    return Arguments(positional, named)
end

Base.getindex(args::Arguments, i::Int) = args.positional[i]
Base.getindex(args::Arguments, sym::Symbol) = args.named[sym]
Base.setindex!(args::Arguments, val, i::Int) = (args.positional[i] = val)
Base.setindex!(args::Arguments, val, sym::Symbol) = (args.named[sym] = val)
Base.pop!(args::Arguments, i::Int, default) = pop!(args.positional, i, default)
Base.pop!(args::Arguments, sym::Symbol, default) = pop!(args.named, sym, default)

Base.copy(args::Arguments) = Arguments(copy(args.positional), copy(args.named))

function Base.map(f, a::Arguments, as::Arguments...)
    is = eachindex(a.positional)
    ks = keys(a.named)
    function g(i)
        vals = map(t -> t[i], (a, as...))
        return f(vals...)
    end
    positional = collect(Any, Iterators.map(g, is))
    named = Dict{Symbol, Any}(k => g(k) for k in ks)
    return Arguments(positional, named)
end

function Base.mergewith!(op, a::Arguments, b::Arguments)
    la, lb = length(a.positional), length(b.positional)
    for i in 1:lb
        (i ≤ la) ? (a[i] = op(a[i], b[i])) : push!(a.positional, b[i])
    end
    mergewith!(op, a.named, b.named)
    return a
end