function apply_context(t, cols, columnname::Union{Symbol, String})
    c = getcolumn(cols, Symbol(columnname))
    return map(t, c)
end

function apply_context(t, cols, columnnames::Union{AbstractArray, Tuple})
    cs = map(Base.Fix1(getcolumn, cols), columnnames)
    return map(t, cs...)
end

function oldlabel_f_newlabel(x::Pair{<:Any, <:Union{AbstractString, Symbol}})
    columnname, label = x
    return oldlabel_f_newlabel(columnname => identity => label)
end

function oldlabel_f_newlabel(x::Pair{<:Any, <:Any})
    columnname, transformation = x
    return oldlabel_f_newlabel(columnname => transformation => columnname)
end

function oldlabel_f_newlabel(x::Pair{<:Any, <:Pair})
    columnname, transformation_label = x
    transformation, label = transformation_label
    return columnname, transformation, string(label)
end

oldlabel_f_newlabel(x) = oldlabel_f_newlabel(x => identity => x)

function transformedcolumn_label(cols, x)
    name, t, l = oldlabel_f_newlabel(x)
    newcol = apply_context(t, cols, name)
    return newcol, l
end

function transformedcolumns_labels(cols, xs)
    return map(Base.Fix1(transformedcolumn_label, cols), maybewrap(xs))
end

maybewrap(x::Union{AbstractArray, Tuple}) = x
maybewrap(x) = [x]

function process_columns(data, mappings)
    cols = columns(data)
    mappingslabels = map(Base.Fix1(transformedcolumns_labels, cols), mappings)
    npos = length(mappingslabels.positional)
    reshaped = broadcast(mappingslabels.positional..., values(mappingslabels.named)...) do args...
        positional = args[1:npos]
        named = args[npos+1:end]
        return Arguments(collect(positional), Dict(zip(keys(mappingslabels.named), named)))
    end
    return map(reshaped) do m
        local mappings, labels = map(first, m), map(last, m)
        return LabeledEntry(Any, mappings, labels, Dict{Symbol, Any}())
    end
end
