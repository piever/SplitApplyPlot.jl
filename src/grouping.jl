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

function draw(f, fig, data, by::NamedTuple, positional...; named...)

    axis_dict = Dict{Tuple{Int, Int}, Axis}()
    
    cols = columns(data)
    by_cols = getcolumns(cols, by)
    uniquevalues = map(collect∘uniquesorted, values(by_cols))

    palette = palettes()

    iter = isempty(by) ? [((), Colon())] : finduniquesorted(StructArray(Tuple(by_cols)))

    foreach(iter) do (val, idxs)
        discrete_attr_values = map(keys(by), uniquevalues, val) do k, unique, v
            scale = get(palette, k, Observable(nothing))[]
            return apply_scale(scale, unique, v)
        end
        discrete_attr = Dict(zip(keys(by), discrete_attr_values))
        
        layout = (pop!(discrete_attr, :layout_x, 1), pop!(discrete_attr, :layout_y, 1))
        ax = get!(axis_dict, layout) do
            return Axis(fig[layout...])
        end
        args = map(v -> view(v, idxs), getcolumns(cols, positional))
        m_attrs = map(v -> view(v, idxs), getcolumns(cols, values(named)))
        attrs = merge(m_attrs, discrete_attr)
        f(ax, Attributes(attrs), args)
    end
end

function draw(T::Type, fig, data, by::NamedTuple, positional...; named...)
    return draw(fig, data, by::NamedTuple, positional...; named...) do ax, attrs, args
        plot!(ax, T, attrs, args)
    end
end