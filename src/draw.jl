function palettes()
    abstractplotting_palette = AbstractPlotting.current_default_theme()[:palette]
    return Dict(k => to_value(v) for (k, v) in abstractplotting_palette)
end

function axisplots(plottype, fig, data, by::NamedTuple, select::Arguments)
    positional, named = select.positional, select.named

    axisplots = Dict{Tuple{Int, Int}, AxisPlot}()

    cols = columns(data)
    by_cols = getcolumns(cols, by)
    uniquevalues = map(uniquesort, by_cols)
    extremas = map(select) do s
        min, max = extrema(getcolumn(cols, s))
        return min..max
    end
    palette = palettes()
    iter = isempty(by) ? [((), Colon())] : finduniquesorted(StructArray(Tuple(by_cols)))

    foreach(iter) do (val, idxs)
        # Initialize `trace` with views of columns from `select`
        trace = map(select) do s
            col = getcolumn(cols, s)
            return view(col, idxs)
        end
        # Add arguments from grouping
        for (k, v) in zip(keys(by), val)
            trace[k] = v
        end
        # Remove layout information
        layout = map((:layout_y, :layout_x)) do sym
            l = pop!(trace, sym, 1)
            ls = get(uniquevalues, sym, [1])
            return findfirst(==(l), ls)
        end
        
        axisplot = get!(axisplots, layout) do
            axis = Axis(fig[layout...])
            scales = map(extremas) do extrema
                return ContinuousScale(identity, extrema)
            end
            for (key, val) in pairs(uniquevalues)
                scale = get(palette, key, Counter)
                scales[key] = DiscreteScale(scale, val)
            end
            labels = map(select) do s
                sym = s isa Symbol ? s : columnnames(cols)[s]
                return string(sym)
            end
            return AxisPlot(axis, Trace[], scales, labels)
        end

        push!(axisplot.tracelist, Trace(plottype, trace))
    end
    M, N = maximum(first, keys(axisplots)), maximum(last, keys(axisplots))
    return [get(axisplots, Tuple(c), missing) for c in CartesianIndices((M, N))]
end
