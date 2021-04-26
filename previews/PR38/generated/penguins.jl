# # Tutorial 🐧

# This is a gentle and lighthearted tutorial on how to use tools from SplitApplyPlot,
# using as example dataset a collection of measurements on penguins[^1]. See 
# the [Palmer penguins website](https://allisonhorst.github.io/palmerpenguins/index.html)
# for more information.
#
# [^1]: Gorman KB, Williams TD, Fraser WR (2014) Ecological Sexual Dimorphism and Environmental Variability within a Community of Antarctic Penguins (Genus Pygoscelis). PLoS ONE 9(3): e90081. [DOI](https://doi.org/10.1371/journal.pone.0090081)

using CSV, DataFrames, HTTP

url = "https://cdn.jsdelivr.net/gh/allisonhorst/palmerpenguins@433439c8b013eff3d36c847bb7a27fa0d7e353d8/inst/extdata/penguins.csv"

penguins = dropmissing(CSV.read(HTTP.get(url).body, DataFrame, missingstring="NA"))
first(penguins, 6)

# ## Frequency plots
#
# Let us start by getting a rough idea of how the data is distributed

using SplitApplyPlot, CairoMakie

specs = data(penguins) * frequency() * mapping(:species)
draw(specs)

# Next, let us see whether the distribution is the same across islands.

specs * mapping(color = :island) |> draw

# Ups! The bars are in the same spot and are hiding each other. We need to specify
# how we want to fix this. Bars can either `dodge` each other, or be `stack`ed on top
# of each other.

specs * mapping(color = :island, dodge = :island) |> draw

# This is our first finding. `Adelie` is the only species of penguins that can be
# found on all three islands. To be able to see both which species is more numerous
# and how different species are distributed across islands in a unique plot, 
# we could have used `stack`.

specs * mapping(color = :island, stack = :island) |> draw

# ## Correlating two variables
#
# Now that we have understood the distribution of these three penguin species, we can
# start analyzing their features.

specs = data(penguins) * mapping(:bill_length_mm, :bill_depth_mm)
draw(specs)

# We would actually prefer to visualize these measures in centimeters, and to have
# cleaner axes labels. As we want this setting to be preserved in all of our `bill`
# visualizations, let us save it in the variable `specs`.

specs = data(penguins) * mapping(
    :bill_length_mm => (t -> t / 10) => "bill length (cm)",
    :bill_depth_mm => (t -> t / 10) => "bill depth (cm)",
)
draw(specs)

# Much better! Note the parentheses around the function `t -> t / 10`. They are
# necessary to specify that the function maps `t` to `t / 10`, and not to
# `t / 10 => "bill length (cm)"`.

# There does not seem to be a strong correlation between the two dimensions, which
# is odd. Maybe dividing the data by species will help.

specs * mapping(color = :species) |> draw

# Ha! Within each species, penguins with a longer bill also have a deeper bill.
# We can confirm that with a linear regression

an = linear()
specs * an * mapping(color = :species) |> draw

# This unfortunately no longer shows our data!
# We can use `+` to plot both things on top of each other:

specs * an * mapping(color = :species) + specs * mapping(color = :species) |> draw

# Note that the above expression seems a bit redundant, as we wrote the same thing twice.
# We can "factor it out" as follows

specs * (an + mapping()) * mapping(color = :species) |> draw

# where `mapping()` is a neutral multiplicative element.
# Of course, the above could be refactored as

ans = linear() + mapping()
specs * ans * mapping(color = :species) |> draw

# We could actually take advantage of the spare `mapping()` and use it to pass some
# extra info to the scatter, while still using all the species members to compute
# the linear fit. 

ans = linear() + mapping(marker = :sex)
specs * ans * mapping(color = :species) |> draw

# This plot is getting a little bit crowded. We could instead analyze female and
# male penguins in separate subplots.

ans = linear() + mapping(col = :sex)
specs * ans * mapping(color = :species) |> draw

# ## Smooth density plots
#
# An alternative approach to understanding the joint distribution is to consider the
# joint probability density distribution (pdf) of the two variables.

using SplitApplyPlot: density
an = density()
specs * an * mapping(col = :species) |> draw

# A `Heatmap` (the default visualization for a 2D density) is a bit unfortunate if
# we want to mark species by color. In that case, one can use `visual` to change
# the default visualization and, optionally, fine tune some arguments.
# In this case, a `Wireframe` with thin lines looks quite nice. (Note that, for the
# moment, we must specify explicitly that we require a 3D axis.)

using SplitApplyPlot: density
an = visual(Wireframe, linewidth=0.1) * density()
plt = specs * an * mapping(color = :species)
draw(plt, axis = (type = Axis3,))

# Of course, a more traditional approach would be to use a `Contour` plot instead:

using SplitApplyPlot: density
an = visual(Contour) * density()
plt = specs * an * mapping(color = :species)
draw(plt)

# The data and the linear fit can also be added back to the plot:

ans = visual(Contour) * density() + linear() + mapping()
plt = specs * ans * mapping(color = :species)
draw(plt)

# ## Correlating three variables
#
# We are now mostly up-to-speed with `bill` size, but we could consider how it interacts
# with the weight of the penguins. For that, it may be better to use a continuous color
# on a gradient to denote weight, and a marker shape to denote species.

ans = linear() + mapping(color = :body_mass_g) # FIXME: colorranges do not match!!
specs * ans * mapping(marker = :species) |> draw

# Naturally, heavier penguins have bigger bills. We could also try and see the interplay
# of these three variables in a 3D plot.
#' (FIXME: implement linear in 3D)

specs3D = specs * mapping(:body_mass_g => (t -> t / 1000) => "body mass (Kg)")
plt = specs3D * mapping(color = :species) * visual(Scatter) # FIXME: add default to Makie
draw(plt, axis = (type = Axis3,))

#

specs3D = specs * mapping(:body_mass_g => (t -> t / 1000) => "body mass (Kg)")
plt = specs3D * mapping(color = :species, layout = :sex) * visual(Scatter)
draw(plt, axis = (type = Axis3,), figure = (resolution = (1200, 400),))
