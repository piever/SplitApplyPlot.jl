struct Group{NT<:NamedTuple}
    options::NT
    function Group(; kwargs...)
        nt = values(kwargs)
        return new{typeof(nt)}(nt)
    end
end

Base.map(f, g::Group) = Group(; map(f, g.options)...)

struct Mapping{T<:Tuple, NT<:NamedTuple}
    positional::T
    named::NT
    function Mapping(args...; kwargs...)
        t, nt = args, values(kwargs)
        return new{typeof(t), typeof(nt)}(t, nt)
    end
end

Base.map(f, m::Mapping) = Mapping(map(f, m.positional)...; map(f, m.named)...)

to_columns(cols, m::Union{Group, Mapping}) = map(n -> Tables.getcolumn(cols, n), m)

function draw(f, fig, data, grp::Group, m::Mapping)

    LayoutType = @NamedTuple{layout_x::Int, layout_y::Int}
    axis_dict = Dict{LayoutType, Axis}()
    
    cols = Tables.columns(data)
    grp_cols = map(n -> Tables.getcolumn(cols, n), grp)
    options = StructArray(grp_cols.options)
    uniquevalues = map(collect∘uniquesorted, components(options))

    palette = AbstractPlotting.current_default_theme()[:palette]
    scales = map_keys(name -> get(palette, name, nothing), uniquevalues)

    trivial_iter = [(NamedTuple(), Colon())]
    iter = isempty(components(options)) ? trivial_iter : finduniquesorted(options)

    foreach(iter) do (val, idxs)
        st_cols = map(m) do sym
            Tables.getcolumn(cols, sym)[idxs]
        end
        discrete_attr = map(apply_scale, scales, uniquevalues, val)
        layout = (
            layout_x = get(discrete_attr, :layout_x, 1),
            layout_y = get(discrete_attr, :layout_y, 1)
        )
        ax = get!(axis_dict, layout) do
            return Axis(fig[layout...])
        end
        args = st_cols.positional
        attrs = merge(st_cols.named, Base.structdiff(discrete_attr, layout))
        f(ax, args, attrs)
    end

    for ax in values(axis_dict)
        for (name, label, ticks, rot) in zip(m.positional, [:xlabel, :ylabel], [:xticks, :yticks], [:xticklabelrotation, :yticklabelrotation])
            col = Tables.getcolumn(cols, name)
            # FIXME: checkout proper fix in AbstractPlotting
            if !iscontinuous(col)
                u = collect(uniquesorted(col))
                getproperty(ax, ticks)[] = (axes(u, 1), u)
                getproperty(ax, rot)[] = π/3
            end
            getproperty(ax, label)[] = string(name)
        end
    end
end