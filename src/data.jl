apply_context(cols, columnname::Union{Symbol, String}) = getcolumn(cols, columnname)

function apply_context(cols, entry::Entry)
    new_mappings = map(entry.mappings) do m
        return apply_context(cols, m)
    end
    return Entry(entry.plottype, new_mappings, entry.attributes)
end

function column_transformation_label(cols, x::Pair{<:Any, <:Union{AbstractString, Symbol}})
    columnname, label = x
    return column_transformation_label(cols, columnname => identity => label)
end

function column_transformation_label(cols, x::Pair{<:Any, <:Any})
    columnname, transformation = x
    return column_transformation_label(cols, columnname => transformation => columnname)
end

function column_transformation_label(cols, x::Pair{<:Any, <:Pair})
    columnname, transformation_label = x
    transformation, label = transformation_label
    return apply_context(cols, columnname), transformation, Symbol(label)
end

column_transformation_label(cols, x) = column_transformation_label(cols, x => identity => x)

function process_columns(data, entry)
    cols = columns(data)
    df = Dict{Symbol, AbstractVector}()
    mappings = entry.mappings
    new_mappings = map(mappings) do m
        c, t, l = column_transformation_label(cols, m)
        df[l] = map(t, c)
        return l
    end
    new_entry = Entry(entry.plottype, new_mappings, entry.attributes)
    return (NamedTuple(df), new_entry)
end
