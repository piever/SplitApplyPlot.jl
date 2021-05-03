# Components

Here we will see what are the basic building blocks of AlgebraOfGraphics, and how to
combine them to create complex plots based on tables or other formats.

## Basic building blocks

The most important functions are `mapping`, and `visual`.
`mapping` determines the mappings from data to plot. Its positional arguments correspond to
the `x`, `y` or `z` axes of the plot, whereas the keyword arguments correspond to plot
attributes that can vary continuously or discretely, such as `color` or `markersize`.
Variables in `mapping`  are split according to the categorical attributes in it, and then converted
to plot attributes using a default palette.
Finally `visual` can be used to give data-independent visual information about the plot
(plotting function or attributes).
`mapping` and `visual` work in various context. In the following we will explore
`DataContext`, which is introduced doing `data(df)` for any tabular mapping structure `df`.
In this context, `mapping` accepts symbols and integers, which correspond to
columns of the data.

## Operations

The outputs of `mapping`, `visual`, and `data` can be combined with `+` or `*`,
to generate an `AlgebraicList` object, which can then be plotted using the
function `draw`. The actual drawing is done by AbstractPlotting.
The operation `+` is used to create separate layer. `a + b` has as many layers as `la + lb`,
where `la` and `lb` are the number of layers in `a` and `b` respectively.
The operation `a * b` create `la * lb` layers, where `la` and `lb` are the number of layers
in `a` and `b` respectively. Each layer of `a * b` contains the combined information of
the corresponding layer in `a` and the corresponding layer in `b`. In simple cases,
however, both `a` and `b` will only have one layer, and `a * b` simply combines the
information.
