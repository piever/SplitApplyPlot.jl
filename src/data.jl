apply_context(cols, columnname::Union{Symbol, String}) = getcolumn(cols, columnname)

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

function process_columns(data, oldmappings)
    cols = columns(data)
    mappingslabels = map(oldmappings) do m
        c, t, l = column_transformation_label(cols, m)
        return map(t, c) => string(l)
    end
    mappings, labels = map(first, mappingslabels), map(last, mappingslabels)
    return LabeledEntry(Any, mappings, labels, Dict{Symbol, Any}())
end
