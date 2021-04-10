function palettes()
    abstractplotting_palette = AbstractPlotting.current_default_theme()[:palette]
    return Dict(k => to_value(v) for (k, v) in abstractplotting_palette)
end

function axisplots(fig, data, by::NamedTuple, select::Arguments)
    positional, named = select.v, select.d

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
            return AxisPlot(axis, Arguments[], scales, labels)
        end

        push!(axisplot.tracelist, trace)
    end
    M, N = maximum(first, keys(axisplots)), maximum(last, keys(axisplots))
    return [get(axisplots, Tuple(c), missing) for c in CartesianIndices((M, N))]
end

# draw!(f, fig, data, select::Arguments) = draw!(f, fig, data, NamedTuple(), select)

# """
#     draw!(f, fig, data, [by::NamedTuple], select::Arguments)

# Group `data` by columns specified in `by`, select columns in `select`, and plot those
# values on `fig` using the function `f`. `f` can also be an `AbstractPlot`, such as `Scatter`
# or `BarPlot`. Return the matrix of axes drawn on `fig` (this may change).

# # Examples

# ```julia
# julia> using SplitApplyPlot, CairoMakie

# julia> data = (a=rand(100), b=rand(100), c=rand(100), d=rand(["a", "b"], 100));

# julia> fig = Figure()

# julia> draw!(Scatter, fig, data, (marker = :d,), mapping(:a, :b, color=:c))

# julia> display(fig)

# julia> fig = Figure()

# julia> mat = draw!(fig, data, (layout_x = :d,), mapping(:a, :b, color=:c)) do ax, select
#     plot!(Scatter, ax, select)
#     ax.xticklabelrotation[] = π/2
# end

# julia> hideinnerdecorations!(mat)

# julia> display(fig)
# ```
# """
# function draw!(f, fig, data, by::NamedTuple, select::Arguments)

#     positional, named = select.v, select.d

#     axis_dict = Dict{Tuple{Int, Int}, Axis}()
    
#     cols = columns(data)
#     by_cols = getcolumns(cols, by)
#     uniquevalues = map(uniquesort, values(by_cols))

#     palette = palettes()

#     iter = isempty(by) ? [((), Colon())] : finduniquesorted(StructArray(Tuple(by_cols)))

#     foreach(iter) do (val, idxs)
#         attrs = Dict{Symbol, Any}()
#         for (k, v) in pairs(getcolumns(cols, named))
#             attrs[k] = view(v, idxs)
#         end
#         for (k, unique, v) in zip(keys(by), uniquevalues, val)
#             scale = get(palette, k, Observable(nothing))[]
#             attrs[k] = apply_scale(scale, unique, v)
#         end
#         layout = (pop!(attrs, :layout_y, 1), pop!(attrs, :layout_x, 1))
#         args = map(v -> view(v, idxs), getcolumns(cols, positional))

#         ax = get!(axis_dict, layout) do
#             axis = Axis(fig[layout...])
#             for prop in propertynames(axis)
#                 val = get(attrs, prop, nothing)
#                 !isnothing(val) && (getproperty(axis, prop)[] = val)
#             end
#             for (name, label, ticks) in zip(positional, [:xlabel, :ylabel], [:xticks, :yticks])
#                 col = getcolumn(cols, name)
#                 # FIXME: checkout proper fix in AbstractPlotting
#                 if !iscontinuous(col)
#                     u = collect(uniquesorted(col))
#                     getproperty(axis, ticks)[] = (axes(u, 1), u)
#                 end
#                 getproperty(axis, label)[] = string(name)
#             end
#             return axis
#         end

#         f(ax, mapping(args...; attrs...))
#     end
#     # TODO: decide exactly what to return here
#     M, N = maximum(first, keys(axis_dict)), maximum(last, keys(axis_dict))
#     return [get(axis_dict, Tuple(c), nothing) for c in CartesianIndices((M, N))]
# end

# function draw!(T::AbstractPlotting.PlotFunc, fig, data, by::NamedTuple, select::Arguments)
#     f(ax, select) = plot!(T, ax, select)
#     return draw!(f, fig, data, by::NamedTuple, select)
# end

# """
#     draw(f, args...; kwargs...)

# Create `fig::Figure` with keyword arguments `kwargs`, then draw on it using [`draw!`](@ref),
# i.e., `draw!(f, fig, args...)`. Return `fig`.

# # Examples

# ```julia
# julia> using SplitApplyPlot, CairoMakie

# julia> data = (a=rand(100), b=rand(100), c=rand(100), d=rand(["a", "b"], 100));

# julia> draw(Scatter, data, (marker = :d,), mapping(:a, :b, color=:c))
# ```
# """
# function draw(f, args...; kwargs...)
#     fig = Figure(; kwargs...)
#     draw!(f, fig, args...)
#     return fig
# end