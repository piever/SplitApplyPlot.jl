# ------------------------------------------------
# -------------- Some helpful types --------------
# ------------------------------------------------

struct SubLegendEntry
    label::String
    visuals::Vector{Visual} # each plottype has its own attributes
end

struct SubLegend
    title::String
    entries::Vector{SubLegendEntry}
end

# ------------------------------------------------
# -------------------- Legend --------------------
# ------------------------------------------------

MakieLayout.Legend(figpos, aog::Union{Layer,Layers}) = 
    Legend(figpos, Entries(aog))
    
function MakieLayout.Legend(figpos, entries::Entries)
    out = _Legend_(entries)
    isnothing(out) && return
    
    if figpos isa FigureGrid
        figpos_new = figpos.figure[:,end + 1]
    else
        figpos_new = figpos
    end

    MakieLayout.Legend(figpos_new, out.elements, out.label, out.title)
end

# Legend(f,
#     [group_size, group_color],
#     [string.(markersizes), string.(colors)],
#     ["Size", "Color"])

function _Legend_(entries)
    named_scales = entries.scales.named
    named_labels = entries.labels.named

    continuous_color = get(named_scales, :color, nothing) isa ContinuousScale
    
    # remove keywords that don't support legends
    attribute_keys = collect(keys(named_scales))
    filter!(attribute_keys) do key
        continuous_color && key == :color && return false
        return key ∉ [:row, :col, :layout, :stack, :dodge, :group]
    end
    
    # if no legend-worthy keyword remains return nothing
    isempty(attribute_keys) && return nothing

	scales_dict = get_scales_dict(entries.entries)



	out = mapreduce(vcat, attribute_keys) do key
		title =	named_labels[key]
		scale = named_scales[key]
			
		map(key2Ps[key]) do P
			_legend(P, key, scale, title)
		end
	end |> StructArray
	

    sublegends = Dict{String,SubLegend}()

    key2Ps = scale_to_Ps(entries.entries) |> Dict
    
    out = mapreduce(vcat, attribute_keys) do key
        title =    named_labels[key]
        scale = named_scales[key]
            
        map(key2Ps[key]) do P
            _legend(P, key, scale, title)
        end
    end |> StructArray
    
    consolidate_legends(out)
end

function _legend(P, attribute, scale::ContinuousScale, title)
    extrema = scale.extrema
    # @unpack f, extrema = scale
    n_ticks = 4
    
    ticks = MakieLayout.locateticks(extrema..., n_ticks)

    label_kw = [(label = L(tick), kw = KW(attribute, tick)) for tick in ticks]
    
    (; title, P, label_kw)
end    

function _legend(P, attribute, scale::CategoricalScale, title)
    
    labels = string.(scale.data)
    attributes = scale.plot
    
    label_kw = [(label = L(l), kw = KW(attribute, att)) for (l, att) in zip(labels, attributes)]
        
    (; title, P, label_kw)
end

# ------------------------------------------------
# ----- LegendElements with more defaults --------
# ------------------------------------------------

function from_default_theme(attr)
    theme = default_styles()
    return get(theme, attr) do
        AbstractPlotting.current_default_theme()[attr]
    end
end

line_element(;
             color=from_default_theme(:color),
             linestyle=from_default_theme(:linestyle),
             linewidth=from_default_theme(:linewidth),
             kwargs...) = 
    LineElement(; color, linestyle, linewidth, kwargs...)

marker_element(;
               color=from_default_theme(:color),
               marker=from_default_theme(:marker),
               strokecolor=from_default_theme(:strokecolor),
               markerpoints=[Point2f0(0.5, 0.5)],
               kwargs...) =
    MarkerElement( ; color, marker, strokecolor, markerpoints, kwargs...)

poly_element(;
             color=from_default_theme(:color),
             strokecolor=:transparent,
             kwargs...) = 
    PolyElement(; color, strokecolor, kwargs...)

legend_element(::Type{Scatter}; kwargs...) = marker_element(; kwargs...)

legend_element(::Type{Lines}; kwargs...) = line_element(; kwargs...)
legend_element(::Type{Contour}; kwargs...) = line_element(; kwargs...)

legend_element(::Any; linewidth=0, strokecolor=:transparent, kwargs...) = poly_element(; linewidth, kwargs...)

# ------------------------------------------------
# --------------- Some helpers -------------------
# ------------------------------------------------

function get_scales_dict(entries)
    return mapreduce((a, b) -> mergewith!(union, a, b), entries) do entry
        P = entry.plottype
		attrs = keys(entry.mappings.named)
		return Dict(attr => [P] for attr in attrs)
    end
end