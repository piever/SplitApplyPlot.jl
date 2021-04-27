### A Pluto.jl notebook ###
# v0.14.3

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

function legend(P, attribute, scale::ContinuousScale, title)
	extrema = scale.extrema
	#@unpack f, extrema = scale
	n_ticks = 4
	
	ticks = MakieLayout.locateticks(extrema..., n_ticks)

	elements = LegendElement[legend_element(P; attribute => s) for s in ticks]
	labels = string.(ticks)
	
	(; elements, labels, title)
end	

function legend(P, attribute, scale::CategoricalScale, title)
	
	labels = string.(scale.data)
	attributes = scale.plot
	
	elements = LegendElement[legend_element(P; attribute => att) for att in attributes]
	
	(; elements, labels, title)
end	
	
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
		y = [cumsum(randn(N)); cumsum(randn(N)); cumsum(randn(N)); cumsum(randn(N))],
	    grp1 = [fill("a", 2N); fill("b", 2N)],
		grp2 = [fill("c", N); fill("d", N); fill("c", N); fill("d", N)],
		z = 20 .* rand(4N)
	
	)

# ╔═╡ f93e6381-f241-4e36-b625-cdca800e66da
tbl1 = (x = rand(100), y = rand(100), z = 20 .* rand(100), grp1 = rand(["a", "b"], 100), grp2 = rand(["c", "d"], 100))

# ╔═╡ 9355d98f-73a5-4c56-ae6e-76f24b797dae
md"""
## Some Tests
"""

# ╔═╡ ab61d343-d860-411d-9c11-80a24aa6b5f3
aog2 = let
	aog = data(tbl2) * 
	mapping(:x, :y) * #mapping(col = :grp) *
	mapping(color = :grp1) *
	(
	visual(Lines, linewidth = 2) * mapping(linestyle = :grp2)
	+ 
	visual(Scatter) * mapping(marker = :grp1, markersize = :z)
	)
	
	aog
end

# ╔═╡ 30c4148c-8fe4-4307-afac-361bec54b6e2
begin
	cols = mapping(:x => "The X", :y => "The Y");
	grp = mapping(color = :grp1, markersize = :z, col = :grp2);
	scat = visual(Scatter)
	pipeline = cols * scat * grp
	aog = data(tbl1) * pipeline
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

# ╔═╡ f946377c-39d0-4459-b787-45837009d7ae
md"""
## Helpers: Prepare Entries
"""

# ╔═╡ 9bb12bd8-5f18-4adc-8c8d-ea8d6a41096f
function filter_scales(scales, S)
	named_scales = [scales.named...]
	
	scales = last.(named_scales)
	
	inds = findall(s -> s isa S, scales)
	
	Dict(named_scales[inds]...)
end

# ╔═╡ c4f0d4ea-f2df-44ec-93cf-2694e96541d4
function Base.pairs(scale::SplitApplyPlot.CategoricalScale)
	(d => p for (d, p) in zip(scale.data, scale.plot))
end

# ╔═╡ 677ed91e-204d-435b-a98b-0afb6be1d289
function dict(scale::SplitApplyPlot.CategoricalScale)
	Dict(pairs(scale)...)
end

# ╔═╡ ed5b90cf-e918-4846-a57e-19bf13051574
function invert_pairs(pairs) 
	pairs = pairs |> collect
	
	attrs = first.(pairs)
	vars = last.(pairs)
	
	map(unique(vars)) do var
		inds = findall(==(var), vars)	
		var => attrs[inds]
	end
end

# ╔═╡ 30c0576c-ff55-4180-aa26-a6b4a4da4d50
function filter_entries(entries, S)
	named_scales = filter_scales(entries.scales, S)
	
	named_labels = entries.labels.named
	named_labels = filter(x -> first(x) in keys(named_scales), named_labels)
	inv_labels = invert_pairs(named_labels)
	
	titles = first.(inv_labels)
	keys_ = last.(inv_labels)
	
	(; titles, keys = keys_, scales = named_scales)
end

# ╔═╡ 8d4105bf-2a8b-4476-8ad7-7245c9e84377
md"""
## New legend helpers
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

# ╔═╡ 9bc38473-7719-4fd1-8fb2-4314afcb5c6a
function continuous_legend(entries)
	scale2Ps = Dict(scale_to_Ps(entries.entries)...)
	
	titles, keys, scales = filter_entries(entries, ContinuousScale)
	
	if length(scales) == 0
		return nothing
	end
	
	title_dict = Dict(only(k) => t for (k, t) in zip(keys, titles))
	
	elements = map([scales...]) do (key, scale)
		
		P = scale2Ps[key] |> only
		ticks = MakieLayout.locateticks(scale.extrema..., 4)
		elements = [legend_element(P; key => t) for t in ticks]
		(; title = title_dict[key], labels = string.(ticks), elements)
	end |> StructArray
	
end	

# ╔═╡ 6e62f9b1-1bf4-477b-8eed-270ca5cf4077
function P_to_scales(entries)
	invert_pairs(scale_to_P(entries))
end

# ╔═╡ b7cbf70f-1db5-4837-9c93-d3708b35c909
function categorical_legend0(entries)
	
	P2scales = P_to_scales(entries.entries)
	
	titles, keys, scales = filter_entries(entries, CategoricalScale)
	
	if length(scales) == 0
		return nothing
	end
	
	map(zip(titles, keys)) do (t, kk)
	
		labels = mapreduce(∪, kk) do k
			scales[k].data
		end

		out = map(labels) do l
			P_kws = map(P2scales) do (P, kkk)
				filter!(in(∪(keys...)), kkk)
				kws = (;)
				for k in kkk
					ii = findall(l .== scales[k].data)
					if length(ii) > 0
						i = only(ii)
						kws = (; kws..., k => scales[k].plot[i])
					end
				end
				P => kws
			end
			filter!(x-> !isempty(last(x)), P_kws)
			
			l => P_kws
		end

		t => out

	end
end

# ╔═╡ fa0a9b43-639b-4523-bde5-05dff5c324a5
function categorical_legend1(entries)
	out2 = categorical_legend0(entries)
	
	titles = first.(out2)
	rests = last.(out2)
	
	legends = map(zip(titles, rests)) do (title, rest)
	
		labels = first.(rest)
		Ps_kwss = last.(rest)
	
		legend = map(zip(labels, Ps_kwss)) do (label, Ps_kws)
			combined_element = map(Ps_kws) do (P, kws)
				legend_element(P; kws...)
			end
			(; label, combined_element = Array{LegendElement}(combined_element))
		end |> StructArray
		(; title, labels = legend.label, elements = legend.combined_element)
	end |> StructArray	
end

# ╔═╡ 31e97f45-57b9-45c9-aebb-c20d9a68db42
function Legend_(figpos, entries::Entries)
		
	cat_leg = categorical_legend1(entries)
	cont_leg = continuous_legend(entries)
	
	if !isnothing(cont_leg) && !isnothing(cat_leg)
		out = [cat_leg; cont_leg]
	elseif !isnothing(cont_leg)
		out = cont_leg
	elseif !isnothing(cat_leg)
		out = cat_leg
	end
			
	MakieLayout.Legend(figpos, out.elements, out.labels, out.title)
end

# ╔═╡ f89ca7fd-66e4-4bda-bb1e-4d1e256cd7aa
let
	fig = aog2 |> draw
	Legend_(fig.figure[1,end+1], Entries(aog2))	
	
	fig
end

# ╔═╡ 50e8ea1a-0565-4fc3-bff2-7b1240fa39fb
begin
	fig = aog |> draw
	Legend_(fig.figure[1,end + 1], Entries(aog))
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
# ╟─fefe87f2-f0b8-4fcc-9292-965ae442f896
# ╠═31e97f45-57b9-45c9-aebb-c20d9a68db42
# ╟─6de1d586-f399-4d92-93f7-f9883829c0a6
# ╠═9bc38473-7719-4fd1-8fb2-4314afcb5c6a
# ╟─0e08f486-acb1-4385-8c38-89fceffaffd2
# ╠═b7cbf70f-1db5-4837-9c93-d3708b35c909
# ╠═fa0a9b43-639b-4523-bde5-05dff5c324a5
# ╟─f946377c-39d0-4459-b787-45837009d7ae
# ╠═30c0576c-ff55-4180-aa26-a6b4a4da4d50
# ╠═9bb12bd8-5f18-4adc-8c8d-ea8d6a41096f
# ╠═c4f0d4ea-f2df-44ec-93cf-2694e96541d4
# ╠═677ed91e-204d-435b-a98b-0afb6be1d289
# ╠═ed5b90cf-e918-4846-a57e-19bf13051574
# ╟─8d4105bf-2a8b-4476-8ad7-7245c9e84377
# ╠═c5f98651-b0e8-4eda-a501-e942d619cc82
# ╠═3c3fd66f-9c80-4df6-8eb6-91bd086d31c6
# ╠═6e62f9b1-1bf4-477b-8eed-270ca5cf4077
# ╠═9f27fe58-e7d6-4ef6-805e-d45bed3ac0c6
# ╟─5c4d951f-47b2-4f30-aaeb-fe9ec84ae1a7
# ╠═6c9811e0-998b-4f20-b5d7-61ca7c8340c0
# ╠═1755e5f6-18a3-48b6-afff-678417be8c8e
