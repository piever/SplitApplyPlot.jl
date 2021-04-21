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
    df = LittleDict{Symbol, AbstractVector}()
    mappings = entry.mappings
    new_mappings = map(mappings) do m
        c, t, l = column_transformation_label(cols, m)
        df[l] = map(t, c)
        return l
    end
    new_entry = Entry(entry.plottype, new_mappings, entry.attributes)
    return (df, new_entry)
end

function consume(spec::Spec)
    init = Spec((), spec.data, spec.entry)
    return foldl(consume, spec.transformations; init)
end

consume(specs::SpecList, f) = SpecList([consume(f, spec) for spec in specs])

consume(spec::Spec, f) = f(spec)

function analyze(spec::Spec)::SpecList
    data, entry = process_columns(spec.data, spec.entry)
    s = Spec(spec.transformations, data, entry)
    return consume(s)
end

function analyze(specs::SpecList)::SpecList
    results = map(analyze, specs.specs)
    return SpecList(reduce(vcat, results))
end
