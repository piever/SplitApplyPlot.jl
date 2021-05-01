# # Tutorial 🐧

# This is a gentle and lighthearted tutorial on how to use tools from SplitApplyPlot,
# using as example dataset a collection of measurements on penguins[^1]. See 
# the [Palmer penguins website](https://allisonhorst.github.io/palmerpenguins/index.html)
# for more information.
#
# [^1]: Gorman KB, Williams TD, Fraser WR (2014) Ecological Sexual Dimorphism and Environmental Variability within a Community of Antarctic Penguins (Genus Pygoscelis). PLoS ONE 9(3): e90081. [DOI](https://doi.org/10.1371/journal.pone.0090081)

using PalmerPenguins, DataFrames

penguins = dropmissing(DataFrame(PalmerPenguins.load()))
first(penguins, 6)

# ## Frequency plots
#
# Let us start by getting a rough idea of how the data is distributed

using SplitApplyPlot, CairoMakie

figure = (resolution = (400, 300),)
specs = data(penguins) * frequency() * mapping(:species)
draw(specs; figure)

# Next, let us see whether the distribution is the same across islands.

plt = specs * mapping(color = :island)
draw(plt; figure)

# Ups! The bars are in the same spot and are hiding each other. We need to specify
# how we want to fix this. Bars can either `dodge` each other, or be `stack`ed on top
# of each other.

plt = specs * mapping(color = :island, dodge = :island)
draw(plt; figure)

# This is our first finding. `Adelie` is the only species of penguins that can be
# found on all three islands. To be able to see both which species is more numerous
# and how different species are distributed across islands in a unique plot, 
# we could have used `stack`.

plt = specs * mapping(color = :island, stack = :island)
draw(plt; figure)

# ## Correlating two variables
#
# Now that we have understood the distribution of these three penguin species, we can
# start analyzing their features.

specs = data(penguins) * mapping(:bill_length_mm, :bill_depth_mm)
draw(specs; figure)

# We would actually prefer to visualize these measures in centimeters, and to have
# cleaner axes labels. As we want this setting to be preserved in all of our `bill`
# visualizations, let us save it in the variable `specs`.

specs = data(penguins) * mapping(
    :bill_length_mm => (t -> t / 10) => "bill length (cm)",
    :bill_depth_mm => (t -> t / 10) => "bill depth (cm)",
)
draw(specs; figure)

# Much better! Note the parentheses around the function `t -> t / 10`. They are
# necessary to specify that the function maps `t` to `t / 10`, and not to
# `t / 10 => "bill length (cm)"`.

# There does not seem to be a strong correlation between the two dimensions, which
# is odd. Maybe dividing the data by species will help.

plt = specs * mapping(color = :species)
draw(plt; figure)

# Ha! Within each species, penguins with a longer bill also have a deeper bill.
# We can confirm that with a linear regression

an = linear()
plt = specs * an * mapping(color = :species)
draw(plt; figure)

# This unfortunately no longer shows our data!
# We can use `+` to plot both things on top of each other:

plt = specs * an * mapping(color = :species) + specs * mapping(color = :species)
draw(plt; figure)

# Note that the above expression seems a bit redundant, as we wrote the same thing twice.
# We can "factor it out" as follows

plt = specs * (an + mapping()) * mapping(color = :species)
draw(plt; figure)

# where `mapping()` is a neutral multiplicative element.
# Of course, the above could be refactored as

ans = linear() + mapping()
plt = specs * ans * mapping(color = :species)
draw(plt; figure)

# We could actually take advantage of the spare `mapping()` and use it to pass some
# extra info to the scatter, while still using all the species members to compute
# the linear fit. 

ans = linear() + mapping(marker = :sex)
plt = specs * ans * mapping(color = :species)
draw(plt; figure)

# This plot is getting a little bit crowded. We could instead analyze female and
# male penguins in separate subplots. Let us set a wider figure for that.

figure = (resolution = (600, 300),)
ans = linear() + mapping(col = :sex)
plt = specs * ans * mapping(color = :species)
draw(plt; figure)

# ## Smooth density plots
#
# An alternative approach to understanding how two variables interact is to consider
# their joint probability density distribution (pdf).

using SplitApplyPlot: density
figure = (resolution = (700, 300),)
an = density(npoints=50)
plt = specs * an * mapping(col = :species)
draw(plt; figure)

# The default colormap is multi-hue, but it is possible to pass single-hue colormaps as well:

draw(visual(colormap = :grayC) * plt; figure)

# A `Heatmap` (the default visualization for a 2D density) is a bit unfortunate if
# we want to mark species by color. In that case, one can use `visual` to change
# the default visualization and, optionally, fine tune some arguments.
# In this case, a `Wireframe` with thin lines looks quite nice. (Note that, for the
# time being, we must specify explicitly that we require a 3D axis.)

using SplitApplyPlot: density
figure = (resolution = (600, 400),)
axis = (type = Axis3,)
an = visual(Wireframe, linewidth=0.1) * density()
plt = specs * an * mapping(color = :species)
draw(plt; figure, axis)

# Of course, a more traditional approach would be to use a `Contour` plot instead:

using SplitApplyPlot: density
figure = (resolution = (400, 300),)
an = visual(Contour) * density()
plt = specs * an * mapping(color = :species)
draw(plt; figure)

# The data and the linear fit can also be added back to the plot:

ans = visual(Contour) * density() + linear() + mapping()
plt = specs * ans * mapping(color = :species)
draw(plt; figure)

# In the case of many layers (contour, density and scatter) it is important to think
# about balance. In the above plot, the markers are quite heavy and can obscure the linear
# fit and the contour lines.
# We can lighten the markers using alpha transparency.

ans = visual(Contour, linewidth = 1.5) * density() + linear() + visual(alpha = 0.5)
plt = specs * ans * mapping(color = :species)
draw(plt; figure)

# ## Correlating three variables
#
# We are now mostly up to speed with `bill` size, but we have not consider how
# it relates to other penguin features, such as their weight.
# For that, a possible approach is to use a continuous color
# on a gradient to denote weight and different marker shapes to denote species.

body_mass = :body_mass_g => (t -> t / 1000) => "body mass (kg)"
ans = linear() + mapping(color = body_mass)
plt = specs * ans * mapping(marker = :species)
draw(plt; figure)

# Naturally, within each species, heavier penguins have bigger bills, but perhaps
# counter-intuitively the species with the shallowest bills features the heaviest penguins.
# We could also try and see the interplay of these three variables in a 3D plot.

figure = (resolution = (600, 400),)
axis = (type = Axis3,)
specs3D = specs * mapping(body_mass)
plt = specs3D * mapping(color = :species)
draw(plt; figure, axis)

#

figure = (resolution = (1200, 400),)
plt = specs3D * mapping(color = :species, layout = :sex)
draw(plt; figure, axis)

# Note that static 3D plot can be misleading, as they only show one projection
# of 3D data. They are mostly useful when shown interactively.
