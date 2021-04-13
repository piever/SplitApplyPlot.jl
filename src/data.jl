function default_palettes()
    abstractplotting_palette = AbstractPlotting.current_default_theme()[:palette]
    return Dict(k => to_value(v) for (k, v) in abstractplotting_palette)
end

function apply_palettes(k, v; palettes, summaries, iscontinuous)
    summary = summaries[k]
    r = apply_summary(summary, v)
    (iscontinuous || !haskey(palettes, k)) && return r
    return cycle(palettes[k], r)
end

function entries(plottype::PlotFunc, data, group, select; attributes...)
    # Get one or more labeled entries from data
    # Idea: maybe put together 

end