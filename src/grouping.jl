struct Mapping{S, T}
    keys::Vector{S}
    values::Vector{T}
end
function mapping(args...; kwargs...)
    k = vcat(collect(keys(args)), collect(keys(kwargs)))
    v = vcat(collect(values(args)), collect(values(kwargs)))
    return Mapping(k, v)
end

Base.map(f, m::Mapping) = Mapping(m.keys, map(f, m.values))
Base.Tuple(m::Mapping) = Tuple(m.values)
Base.Dict(m::Mapping) = Dict(zip(m.keys, m.values))

function getcolumns(cols, m::Mapping)
    return map(name -> getcolumn(cols, name), m)
end

function palettes()
    defaults = Dict{Symbol, Any}(AbstractPlotting.current_default_theme()[:palette])
    defaults[:layout_x] = Observable(Counter())
    defaults[:layout_y] = Observable(Counter())
    defaults[:title] = Observable(string)
    return defaults
end

function draw(f, fig, data, by::Mapping, select::Mapping; kwargs...)

    axis_dict = Dict{Tuple{Int, Int}, Axis}()
    
    cols = columns(data)
    by_cols = getcolumns(cols, by)
    uniquevalues = map(collect∘uniquesorted, by_cols.values)

    palette = palettes()

    iter = isempty(by.keys) ? [((), Colon())] : finduniquesorted(StructArray(Tuple(by_cols)))

    foreach(iter) do (val, idxs)
        selected_cols = map(v -> v[idxs], getcolumns(cols, select))
        discrete_attr_values = map(by.keys, by.values, uniquevalues, val) do k, v, unique, vv
            scale = get(palette, k, Observable(nothing))[]
            return apply_scale(scale, unique, vv)
        end
        discrete_attr = Dict(zip(by.keys, discrete_attr_values))
        
        layout = (pop!(discrete_attr, :layout_x, 1), pop!(discrete_attr, :layout_y, 1))
        ax = get!(axis_dict, layout) do
            axis = Axis(fig[layout...])
            return axis
        end
        args = selected_cols.values[isa.(selected_cols.keys, Integer)]
        actual_keys = isa.(selected_cols.keys, Symbol)
        m_attrs = Dict(zip(selected_cols.keys[actual_keys], selected_cols.values[actual_keys]))
        g_attrs = discrete_attr
        attrs = merge(m_attrs, g_attrs)
        f(ax, args, attrs)
    end
end