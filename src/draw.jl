function getcolumns(cols, m::Union{Tuple, NamedTuple})
    return map(name -> getcolumn(cols, name), m)
end

function palettes()
    defaults = Dict{Symbol, Any}(AbstractPlotting.current_default_theme()[:palette])
    defaults[:layout_x] = Observable(Counter())
    defaults[:layout_y] = Observable(Counter())
    defaults[:title] = Observable(string)
    return defaults
end

draw!(f, fig, data, m::Mapping) = draw!(f, fig, data, NamedTuple(), m)

function draw!(f, fig, data, by::NamedTuple, m::Mapping)

    positional, named = Tuple(m), NamedTuple(m)

    axis_dict = Dict{Tuple{Int, Int}, Axis}()
    
    cols = columns(data)
    by_cols = getcolumns(cols, by)
    uniquevalues = map(collect∘uniquesorted, values(by_cols))

    palette = palettes()

    iter = isempty(by) ? [((), Colon())] : finduniquesorted(StructArray(Tuple(by_cols)))

    foreach(iter) do (val, idxs)
        attrs = Dict{Symbol, Any}()
        for (k, v) in pairs(getcolumns(cols, named))
            attrs[k] = view(v, idxs)
        end
        for (k, unique, v) in zip(keys(by), uniquevalues, val)
            scale = get(palette, k, Observable(nothing))[]
            attrs[k] = apply_scale(scale, unique, v)
        end
        layout = (pop!(attrs, :layout_x, 1), pop!(attrs, :layout_y, 1))
        args = map(v -> view(v, idxs), getcolumns(cols, positional))

        ax = get!(axis_dict, layout) do
            axis = Axis(fig[layout...])
            for prop in propertynames(axis)
                val = get(attrs, prop, nothing)
                !isnothing(val) && (getproperty(axis, prop)[] = val)
            end
            for (name, label, ticks) in zip(positional, [:xlabel, :ylabel], [:xticks, :yticks])
                col = getcolumn(cols, name)
                # FIXME: checkout proper fix in AbstractPlotting
                if !iscontinuous(col)
                    u = collect(uniquesorted(col))
                    getproperty(axis, ticks)[] = (axes(u, 1), u)
                end
                getproperty(axis, label)[] = string(name)
            end
            return axis
        end

        f(ax, mapping(args...; attrs...))
    end
    # TODO: decide exactly what to return here
    M, N = maximum(first, keys(axis_dict)), maximum(last, keys(axis_dict))
    return [get(axis_dict, Tuple(c), nothing) for c in CartesianIndices((M, N))]
end

function draw!(T::Type, fig, data, by::NamedTuple, m::Mapping)
    f(ax, m) = plot!(T, ax, m)
    return draw!(f, fig, data, by::NamedTuple, m)
end

function draw(f, args...; kwargs...)
    fig = Figure(; kwargs...)
    draw!(f, fig, args...)
    return fig
end