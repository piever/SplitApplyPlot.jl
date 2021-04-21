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
    list = collect(Iterators.flatten(Iterators.map(analyze, specs)))
    return SpecList(list)
end
