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

to_columns(cols, name::Union{Symbol, Integer}) = Tables.getcolumn(cols, name)
function to_columns(cols, m::Union{Group, Mapping, NamedTuple})
    return map(name -> to_columns(cols, name), m)
end

to_structarray(nt::NamedTuple) = StructArray(map(to_structarray, nt))
to_structarray(v::AbstractVector) = v

function palettes()
    defaults = AbstractPlotting.current_default_theme()[:palette]
    return (;
        defaults...,
        layout_x=Counter(),
        layout_y=Counter(),
        axis=(
            title=string,
        ),
    )
end

function draw(f, fig, data, grp::Group, m::Mapping)

    LayoutType = @NamedTuple{layout_x::Int, layout_y::Int}
    axis_dict = Dict{LayoutType, Axis}()
    
    cols = Tables.columns(data)
    grp_cols = to_columns(cols, grp)
    options = to_structarray(grp_cols.options)
    uniquevalues = recurse_values(collect∘uniquesorted, grp_cols.options)
    scales = recurse_extract(palettes(), uniquevalues)

    trivial_iter = [(NamedTuple(), Colon())]
    iter = isempty(components(options)) ? trivial_iter : finduniquesorted(options)

    foreach(iter) do (val, idxs)
        m_cols = map(v -> v[idxs], to_columns(cols, m))
        discrete_attr = recurse_values(apply_scale, scales, uniquevalues, val)
        layout = (
            layout_x = get(discrete_attr, :layout_x, 1),
            layout_y = get(discrete_attr, :layout_y, 1)
        )
        axis_attr = (axis = get(discrete_attr, :axis, NamedTuple()),)
        ax = get!(axis_dict, layout) do
            axis = Axis(fig[layout...])
            for (k, v) in pairs(axis_attr.axis)
                getproperty(axis, k)[] = v
            end
            return axis
        end
        args = m_cols.positional
        attrs = merge(m_cols.named, remove_fields(discrete_attr, layout, axis_attr))
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