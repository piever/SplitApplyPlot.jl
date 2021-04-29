# ------------------------------------------------
# -------------- Some helpful types --------------
# ------------------------------------------------

# ╔═╡ bbffd9ac-70e8-49bd-83ed-7d79cf836596
begin
	struct KW
		key::Symbol # e.g. :color | :linestyle | :markersize
		attribute   # e.g.  :red  |   :dash    |    1.4
	end
	pair(kw::KW) = kw.key => kw.attribute
end

# ╔═╡ 18873a6a-fce4-4565-862d-081df6dffb40
begin
	struct L
		label::Union{String,Number}
	end

	L(l::L) = l
	
	Base.get(l::L) = l.label
	Base.string(l::L) = string(l.label)
end

# ------------------------------------------------
# -------------------- Legend --------------------
# ------------------------------------------------

MakieLayout.Legend(figpos, aog::Union{Layer,Layers}) = 
	Legend(figpos, Entries(aog))
	
function MakieLayout.Legend(figpos, entries::Entries)
	out = _Legend_(entries)
	
	if figpos isa FigureGrid
		figpos_new = figpos.figure[:,end+1]
	else
		figpos_new = figpos
	end

	if !isnothing(out)
		MakieLayout.Legend(figpos_new, out.elements, out.label, out.title)
	end
end

function _Legend_(entries)
	named_scales = entries.scales.named
	named_labels = entries.labels.named
	
	# remove keywords that don't support legends
	attribute_keys = collect(keys(named_scales))
	filter!(!in([:row, :col, :layout, :stack, :dodge, :group]), attribute_keys)
	
	if haskey(named_scales, :color) && named_scales[:color] isa ContinuousScale
		filter!(!=(:color), attribute_keys)
	end
	
	# if no legend-worthy keyword remains return nothing
	if length(attribute_keys) == 0
		return nothing
	end
	
	key2Ps = scale_to_Ps(entries.entries) |> Dict
	
	out = mapreduce(vcat, attribute_keys) do key
		title =	named_labels[key]
		scale = named_scales[key]
			
		map(key2Ps[key]) do P
			_legend(P, key, scale, title)
		end
	end |> StructArray
	
	consolidate_legends(out)
end

# ╔═╡ 2bcbfb12-47e5-471a-b78f-4dfedaae3a0d
function _legend(P, attribute, scale::ContinuousScale, title)
	extrema = scale.extrema
	#@unpack f, extrema = scale
	n_ticks = 4
	
	ticks = MakieLayout.locateticks(extrema..., n_ticks)

	label_kw = [(label = L(tick), kw = KW(attribute, tick)) for tick in ticks]
	
	(; title, P, label_kw)
end	

# ╔═╡ e57b567c-3138-4d17-9815-5010a810c77d
function _legend(P, attribute, scale::CategoricalScale, title)
	
	labels = string.(scale.data)
	attributes = scale.plot
	
	label_kw = [(label = L(l), kw = KW(attribute, att)) for (l, att) in zip(labels, attributes)]
		
	(; title, P, label_kw)
end	

# ------------------------------------------------
# ------------- Consolidate legends --------------
# ------------------------------------------------

# ╔═╡ 455fdcb0-07f2-4843-81e4-dfca90b0935f
function consolidate_legends(out)
	## Step 1: Combine multiple keywords per PlotType and variable
	## e.g. (Scatter, "grp a", [color => :red, marker => :circle]
	groupby1 = StructArray((; title = out.title, P_str = string.(Symbol.(out.P))))
	grps1 = StructArrays.finduniquesorted(groupby1)

	out1 = map(grps1) do (grp, inds)
		@unpack label_kw = out[inds]
		@unpack title = grp	
		P = out[inds].P |> unique |> only
		
		kws = consolidate_kws(P, label_kw)
	
		(; title, kws)
	end |> StructArray

	## Step 2: Combine PlotTypes per variable and label
	## e.g. (:variable1, "grp a", [(Scatter, [color => :red, marker => :circle])
    ##							   (Lines,   [color = :red, linestyle => :dash])]
	grps2 = StructArrays.finduniquesorted(out1.title)
	
	out2 = map(grps2) do (title, inds)
		tmp = vcat(out1[inds].kws...) |> StructArray |> consolidate_plots
	
		(; title, tmp...)
	end |> StructArray
	
	(; out2.elements, out2.label, out2.title)
end

# ╔═╡ 74be7730-99a9-4352-8853-f6e4333238a6
function consolidate_kws(P, label_kw)
	label_kw = StructArray(vcat(label_kw...))
	
	grps = StructArrays.finduniquesorted(get.(label_kw.label))

	map(grps) do (label, inds)
		kws = label_kw[inds].kw .|> pair |> Array{Pair{Symbol,Any}}
		(; P, label = L(label), kws = kws)
	end
end

# ╔═╡ 158284cf-3897-4ab4-ab82-bf5c5c436715
function consolidate_plots(tmp)
	grps = 	StructArrays.finduniquesorted(get.(tmp.label))
	
	out = map(grps) do (label, inds)
		elements = map(tmp[inds]) do (P, _, kws)
			legend_element(P; kws...)
		end
		(; label = string.(label), elements = Vector{LegendElement}(elements))	
	end |> StructArray
	
	(; out.label, out.elements)
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

# ------------------------------------------------
# --------------- Some helpers -------------------
# ------------------------------------------------

# ╔═╡ c5f98651-b0e8-4eda-a501-e942d619cc82
function scale_to_P(entries)
	mapreduce(∪, entries) do entry
		P = entry.plottype
		attrs = entry.mappings.named |> keys |> collect
		[attr => P for attr in attrs]
	end
end

# ╔═╡ 3c3fd66f-9c80-4df6-8eb6-91bd086d31c6
function scale_to_Ps(entries)
	all_scales = scale_to_P(entries)
	scales = unique(first.(all_scales))
	map(scales) do s
		Ps = filter(x -> first(x) == s, all_scales) .|> last
		s => Ps
	end
end