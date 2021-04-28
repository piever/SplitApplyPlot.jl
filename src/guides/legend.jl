MakieLayout.Legend(figpos, aog::Layer) = 
    Legend(figpos, Entries(aog))

function MakieLayout.Legend(figpos, entries::Entries)
	named_scales = entries.scales.named
	named_labels = entries.labels.named
	
	attribute_keys = collect(keys(named_scales))
	
	out = map(attribute_keys) do key
		title =	named_labels[key]
		scale = named_scales[key]
	
		legend(key, scale, title)
	end |> StructArray
		
	Legend(figpos, out.elements, out.labels, out.title)
end

function legend(attribute, scale::ContinuousScale, title)
	extrema = scale.extrema
	#@unpack f, extrema = scale
	n_ticks = 4
	
	ticks = MakieLayout.locateticks(extrema..., n_ticks)

	elements = [legend_element(Scatter; attribute => s) for s in ticks]
	labels = string.(ticks)
	
	(; elements, labels, title)
end	

function legend(attribute, scale::CategoricalScale, title)
	
	labels = string.(scale.data)
	attributes = scale.plot
	
	elements = [legend_element(Scatter; attribute => att) for att in attributes]
	
	(; elements, labels, title)
end	

# ------------------------------------------------
# ----- LegendElements with more defaults --------
# ------------------------------------------------

from_default_theme(attr) = AbstractPlotting.current_default_theme()[attr]

line_element(; color     = :black, #default_theme(:color),
           linestyle = nothing,
           linewidth = 1.5,
           kwargs...) = 
    LineElement(; color, linestyle, linewidth, kwargs...)

marker_element(; color       = from_default_theme(:color),
            marker       = from_default_theme(:marker),
            strokecolor  = :black,
            markerpoints = [Point2f0(0.5, 0.5)],
            kwargs...) =
    MarkerElement( ; color, marker, strokecolor, markerpoints, kwargs...)

poly_element(; color = from_default_theme(:color),
            strokecolor = :transparent,
           kwargs...) = 
    PolyElement(; color, strokecolor, kwargs...)

legend_element(::Type{Scatter}; kwargs...) = marker_element(; kwargs...)

legend_element(::Type{Lines}; kwargs...) = line_element(; kwargs...)

legend_element(::Type{BarPlot}; linewidth = 0, strokecolor=:green, kwargs...) = poly_element(; linewidth, kwargs...)