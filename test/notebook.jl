### A Pluto.jl notebook ###
# v0.14.4

using Markdown
using InteractiveUtils

# ╔═╡ 6c9811e0-998b-4f20-b5d7-61ca7c8340c0
begin
	using Pkg
	Pkg.activate(temp = true)
	
	Pkg.add(["Revise", "CairoMakie", "StructArrays", "PlutoUI", "UnPack"])
	Pkg.develop(url = "https://github.com/piever/SplitApplyPlot.jl")

	using Revise
	using CairoMakie, SplitApplyPlot, StructArrays
	using PlutoUI, UnPack
end

# ╔═╡ 9f27fe58-e7d6-4ef6-805e-d45bed3ac0c6
begin

using SplitApplyPlot: ContinuousScale, CategoricalScale, legend_element
	
end

# ╔═╡ 98c3879c-a4ff-11eb-09f9-6500b35f764f
md"""
# Legends for AlgebraOfGraphics
"""

# ╔═╡ f9749592-5dbc-4b21-8c43-e3afbd722950
md"""
## Some data
"""

# ╔═╡ 4dea857d-165c-4f27-9b98-6ef251631ee9
N = 30

# ╔═╡ 249f877d-3fa7-45da-9b8e-39c729484d22
tbl2 = (x = [1:N; 1:N; 1:N; 1:N],
		zz = [fill(2, N); fill(-2, N); fill(2.5, N); fill(0, N)],
		y = [2 .+ cumsum(randn(N)); -2 .+ cumsum(randn(N)); 2.5 .+ cumsum(randn(N)); cumsum(randn(N))],
	    grp1 = [fill("a", 2N); fill("b", 2N)],
		grp2 = [fill("c", N); fill("d", N); fill("c", N); fill("d", N)],
		z = 20 .* rand(4N)
	
	)

# ╔═╡ f93e6381-f241-4e36-b625-cdca800e66da
tbl1 = let
	N = 100
	grp1 = rand(["a", "b"], N)
	z1 = rand(N) .+ 0.75 .* (grp1 .== "a")
	(; x = rand(N), y = rand(N), z = 20 .* rand(N), grp1, z1, grp2 = rand(["c", "d"], N))
end

# ╔═╡ 9355d98f-73a5-4c56-ae6e-76f24b797dae
md"""
## Some Tests
"""

# ╔═╡ ab61d343-d860-411d-9c11-80a24aa6b5f3
aog2 = let
	aog = data(tbl2) * 
	mapping(:x, :y) *
	mapping(color = :grp1) *
	(
	visual(Lines, linewidth = 2) * mapping(linestyle = :grp2, group = :grp1)
	+ 
	visual(Scatter) * mapping(marker = :grp1, markersize = :z)
	)
	
	aog
end

# ╔═╡ 30c4148c-8fe4-4307-afac-361bec54b6e2
aog = let
	cols = mapping(:x => "The X", :y => "The Y");
	grp = mapping(
		color = :grp1 => "Group 1",
		markersize = :z => "Group 2",
		col = :grp2
	)
	scat = visual(Scatter)
	pipeline = cols * scat * grp
	aog = data(tbl1) * pipeline
end

# ╔═╡ 59b7c174-7917-4a72-9598-4779fa14b304
aog3 = let
	cols = mapping(:x => "The X", :y => "The Y");
	grp = mapping(marker = :grp2, color = :z1, col = :grp1);
	scat = visual(Scatter)
	pipeline = cols * scat * grp
	aog3 = data(tbl1) * pipeline
end

# ╔═╡ 52b39db4-16c3-4519-beaf-10859e09c7d7
Entries(aog3)

# ╔═╡ a2d895c1-87fc-41a2-b3e3-c8024f2c3f74
md"""
# Implementation
"""

# ╔═╡ 3a721166-c019-48d1-9df2-71d6ffd8741f
md"""
## Guide
"""

# ╔═╡ 770e20c3-c400-492d-9dfe-4991aa05364a
md"""
## Colorbar
"""

# ╔═╡ af0186a3-4bf1-453b-a131-bb32f005c163
function colorbar_(entries::Entries)
	titles, keys, scales = filter_entries(entries, ContinuousScale, keep_only = [:color])
	
	if length(scales) == 0
		return nothing
	end

	scale = only(scales) |> last
	colorrange = scale.extrema
	
	(title = only(titles), colorrange = scale.extrema)
end

# ╔═╡ ee2e13e6-874f-4f4f-a73d-79b0ab7bbae4
function colorbar_titleposition(cbpos, titlepos, has_legend)
	if titlepos == :top
		cbtitlepos = cbpos[0,1]
	elseif titlepos == :left
		cbtitlepos = cbpos[1,0]
	end
end

# ╔═╡ 98cc4c63-59e8-4baa-9af4-febf3862bf28
function colorbar_attributes(orientation)
	vertical = orientation == :vertical
	horizontal = !vertical
	
	if horizontal
		cb_attributes = (height = 18, width = Relative(1.0),
			tellwidth = true,
			vertical = vertical,
			valign = :center,
			ticksize = 5,
  			ticklabelpad = 1.5)
	else
		cb_attributes = (width = 18, height = Relative(1.0),
			vertical = vertical,
			halign = :center,
	)
		
	end
end

# ╔═╡ fefe87f2-f0b8-4fcc-9292-965ae442f896
md"""
## Legend
"""

# ╔═╡ 6de1d586-f399-4d92-93f7-f9883829c0a6
md"""
## Continuous legend
"""

# ╔═╡ 0e08f486-acb1-4385-8c38-89fceffaffd2
md"""
## Categorical legend
"""

# ╔═╡ 95bac7d2-606d-43d8-b5d2-600b2420478b
md"""
## Guide layout
"""

# ╔═╡ b80f57b6-dd97-4f96-8b97-ac9afd153882
begin
#	has_legend_or_colorbar(spec) = (length(spec.group_dict) > 0) || (length(spec.style_dict) > 0)

function outer_legend_position(fig, has_legend_or_colorbar, legend_position)
	if has_legend_or_colorbar
		if legend_position == :bottom
			ax_pos 	 = fig[1,1] 
			legs_pos = fig[2,1]
		elseif legend_position == :top
			ax_pos 	 = fig[2,1] 
			legs_pos = fig[1,1]
		elseif legend_position == :right
			ax_pos   = fig[1,1]
			legs_pos = fig[1,2]
		elseif legend_position == :left
			ax_pos   = fig[1,2]
			legs_pos = fig[1,1]
		end
	else
        ax_pos = fig[1,1]
        legs_pos = nothing
	end
	
	(; ax_pos,  legs_pos)
end

function inner_legend_positions(has_legend, has_colorbar, orientation, legs_pos)
    vertical = orientation == :vertical
    i = 1

    if has_legend
		leg_pos = vertical ? legs_pos[i,1] : legs_pos[1,i]
		i += 1
	else
		leg_pos = nothing
	end
	if has_colorbar
		cb_pos = vertical ? legs_pos[i,1] : legs_pos[1,i]
	else
		cb_pos = nothing
    end
    (; leg_pos, cb_pos)
end


default_orientation(legend_position) = legend_position in [:top, :bottom] ? :horizontal : :vertical

default_nbanks(orientation, has_colorbar) = has_colorbar && (orientation == :horizontal) ? 2 : 1

default_titleposition(orientation) = orientation == :horizontal ? :left : :top
end

# ╔═╡ 0050224d-14d0-4334-afe3-0ca497287950
function Colorbar_(cbpos, entries::Entries;
		orientation = :vertical,
		titlepos = default_titleposition(orientation),
		titlevisible=true,
		has_legend
	)
	
	vertical = orientation == :vertical
	
	content = colorbar_(entries)
	
	@show content.colorrange
	
	squeeze_label_height = titlepos == :top 
	squeeze_label_width  = vertical || titlepos == :left

	if !isnothing(content)
		cb_attr = colorbar_attributes(orientation)
		# FIXME can we explicitly use the colormap?
		# FIXME use transformation
		MakieLayout.Colorbar(cbpos[1,1]; colormap = :batlow, limits = content.colorrange, cb_attr...)
	end


	if !isnothing(content.title) && titlevisible
		cbtitlepos = colorbar_titleposition(cbpos, titlepos, has_legend)
		Label(cbtitlepos, content.title, 
			tellheight = squeeze_label_height, tellwidth = squeeze_label_width
		)
	end
	
	
end

# ╔═╡ f946377c-39d0-4459-b787-45837009d7ae
md"""
## Helpers: Prepare Entries
"""

# ╔═╡ 8d4105bf-2a8b-4476-8ad7-7245c9e84377
md"""
### Legend helpers
"""

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

# ╔═╡ 902bf55a-c2af-4410-a737-9091dc487088
md"""
## Legend
"""

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

# ╔═╡ 58fac7b8-f045-43db-8e6f-b3ae7597f233
md"""
### Consolidate
"""

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

# ╔═╡ b3b5a971-d752-4be9-a33c-38264c4256ec
function _Legend_(entries::Entries)
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

# ╔═╡ fcf11d1b-b0e7-4d04-a170-88cd81186532
function guides(guides_pos, entries::Entries; orientation = :vertical)
	leg_content = _Legend_(entries)
	cb_content = nothing # colorbar_(entries)
	
	has_legend   = !isnothing(leg_content)
	has_colorbar = !isnothing(cb_content)
		
	@unpack leg_pos, cb_pos = inner_legend_positions(has_legend, has_colorbar, orientation, guides_pos)

	if has_legend
		MakieLayout.Legend(leg_pos, leg_content.elements, leg_content.label, leg_content.title)
	end
	
	if has_colorbar
		Colorbar_(cb_pos, entries; orientation, has_legend)
	end
	
end

# ╔═╡ f89ca7fd-66e4-4bda-bb1e-4d1e256cd7aa
let
	fig = aog2 |> draw
	guides(fig.figure[1,end+1], Entries(aog2))	
	
	fig
end

# ╔═╡ 50e8ea1a-0565-4fc3-bff2-7b1240fa39fb
let
	fig = aog |> draw
	guides(fig.figure[1,end + 1], Entries(aog))
	fig
end

# ╔═╡ 9ae7570c-61a8-4db2-9eaf-7daa21029f70
let
	cols = mapping(:x => "The X", :y => "The Y");
	grp = mapping(
		color = :z => "Fancy",
		col = :grp2);
	scat = visual(Scatter)
	pipeline = cols * scat * grp
	aog = data(tbl1) * pipeline
	
	fig = aog |> draw
	guides(fig.figure[1,end + 1], Entries(aog))
	fig
	
end

# ╔═╡ 47e6bbb7-9a2c-47f6-ab33-7d6d33bbb4c7
fig = let aog = aog3
	fig = aog |> draw
	guides(fig.figure[1,end+1], Entries(aog))
	fig
end

# ╔═╡ 987c0dcc-bf86-4994-b19e-861ab9d3f657
fig |> typeof |> fieldnames

# ╔═╡ 19a9249a-9288-4138-b328-77d3ff3df270
let
	aog = data(tbl2) * 
	mapping(:x, :y) *
	mapping(group = :grp2) *
	(
	visual(Lines, linewidth = 2) * mapping(linestyle = :grp1, color = :zz)
	+ 
	visual(Scatter) * mapping(marker = :grp1, color = :zz)
	)
	
	
	fig = draw(aog)
	guides(fig.figure[1,end+1], Entries(aog))
	
	fig
end

# ╔═╡ b3ae6153-ca9a-48ca-b517-14ab85eb89aa
function Legend1(figpos, entries::Entries)
	
	out = _Legend_(entries)
	
	if !isnothing(out)
		MakieLayout.Legend(figpos, out.elements, out.label, out.title)
	end
end

# ╔═╡ b112711d-5e41-462b-a137-5a6d4bbe840c
let
	fig = Figure()
	Legend1(fig[1,1], Entries(aog2))
	fig
end

# ╔═╡ 5c4d951f-47b2-4f30-aaeb-fe9ec84ae1a7
md"""
# Appendix
"""

# ╔═╡ 1755e5f6-18a3-48b6-afff-678417be8c8e
TableOfContents()

# ╔═╡ Cell order:
# ╟─98c3879c-a4ff-11eb-09f9-6500b35f764f
# ╟─f9749592-5dbc-4b21-8c43-e3afbd722950
# ╠═4dea857d-165c-4f27-9b98-6ef251631ee9
# ╠═249f877d-3fa7-45da-9b8e-39c729484d22
# ╠═f93e6381-f241-4e36-b625-cdca800e66da
# ╟─9355d98f-73a5-4c56-ae6e-76f24b797dae
# ╠═ab61d343-d860-411d-9c11-80a24aa6b5f3
# ╠═f89ca7fd-66e4-4bda-bb1e-4d1e256cd7aa
# ╠═30c4148c-8fe4-4307-afac-361bec54b6e2
# ╠═50e8ea1a-0565-4fc3-bff2-7b1240fa39fb
# ╠═9ae7570c-61a8-4db2-9eaf-7daa21029f70
# ╠═59b7c174-7917-4a72-9598-4779fa14b304
# ╠═47e6bbb7-9a2c-47f6-ab33-7d6d33bbb4c7
# ╠═52b39db4-16c3-4519-beaf-10859e09c7d7
# ╠═987c0dcc-bf86-4994-b19e-861ab9d3f657
# ╠═19a9249a-9288-4138-b328-77d3ff3df270
# ╟─a2d895c1-87fc-41a2-b3e3-c8024f2c3f74
# ╟─3a721166-c019-48d1-9df2-71d6ffd8741f
# ╠═fcf11d1b-b0e7-4d04-a170-88cd81186532
# ╟─770e20c3-c400-492d-9dfe-4991aa05364a
# ╠═af0186a3-4bf1-453b-a131-bb32f005c163
# ╠═0050224d-14d0-4334-afe3-0ca497287950
# ╠═ee2e13e6-874f-4f4f-a73d-79b0ab7bbae4
# ╠═98cc4c63-59e8-4baa-9af4-febf3862bf28
# ╟─fefe87f2-f0b8-4fcc-9292-965ae442f896
# ╟─6de1d586-f399-4d92-93f7-f9883829c0a6
# ╟─0e08f486-acb1-4385-8c38-89fceffaffd2
# ╟─95bac7d2-606d-43d8-b5d2-600b2420478b
# ╠═b80f57b6-dd97-4f96-8b97-ac9afd153882
# ╟─f946377c-39d0-4459-b787-45837009d7ae
# ╠═b112711d-5e41-462b-a137-5a6d4bbe840c
# ╟─902bf55a-c2af-4410-a737-9091dc487088
# ╠═b3ae6153-ca9a-48ca-b517-14ab85eb89aa
# ╠═b3b5a971-d752-4be9-a33c-38264c4256ec
# ╠═2bcbfb12-47e5-471a-b78f-4dfedaae3a0d
# ╠═e57b567c-3138-4d17-9815-5010a810c77d
# ╟─58fac7b8-f045-43db-8e6f-b3ae7597f233
# ╠═455fdcb0-07f2-4843-81e4-dfca90b0935f
# ╠═74be7730-99a9-4352-8853-f6e4333238a6
# ╠═158284cf-3897-4ab4-ab82-bf5c5c436715
# ╟─8d4105bf-2a8b-4476-8ad7-7245c9e84377
# ╠═c5f98651-b0e8-4eda-a501-e942d619cc82
# ╠═3c3fd66f-9c80-4df6-8eb6-91bd086d31c6
# ╠═9f27fe58-e7d6-4ef6-805e-d45bed3ac0c6
# ╠═bbffd9ac-70e8-49bd-83ed-7d79cf836596
# ╠═18873a6a-fce4-4565-862d-081df6dffb40
# ╟─5c4d951f-47b2-4f30-aaeb-fe9ec84ae1a7
# ╠═6c9811e0-998b-4f20-b5d7-61ca7c8340c0
# ╠═1755e5f6-18a3-48b6-afff-678417be8c8e
