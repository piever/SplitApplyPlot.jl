# Conservative 7-color palette
# Wong, Bang. "Points of view: Color blindness." (2011): 441.
# https://www.nature.com/articles/nmeth.1618?WT.ec_id=NMETH-201106

function default_palettes()
    return arguments(
        color=[
            RGB(0/255, 114/255, 178/255), # dark blue
            RGB(230/255, 159/255, 0/255), # orange
            RGB(0/255, 158/255, 115/255), # green
            RGB(204/255, 121/255, 167/255), # pink
            RGB(213/255, 94/255, 0/255), # red
            RGB(86/255, 180/255, 233/255), # light blue
            RGB(240/255, 228/255, 66/255), # yellow
        ],
        marker=[:circle, :utriangle, :cross, :rect, :diamond, :dtriangle, :pentagon, :xcross],
        linestyle=[:solid, :dash, :dot, :dashdot, :dashdotdot],
        side=[:left, :right],
        layout=wrap,
    )
end

# Batlow colormap
# Crameri, Fabio, Grace E. Shephard, and Philip J. Heron. "The misuse of colour in science communication." Nature communications 11.1 (2020): 1-10.
# https://www.nature.com/articles/s41467-020-19160-7?source=techstories.org

function default_styles()
    return (
        color=:gray25,
        strokecolor=RGBA(0, 0, 0, 0),
        outlierstrokecolor=RGBA(0, 0, 0, 0),
        mediancolor=:white,
        marker=:circle,
        markersize=15,
        linewidth=1.5,
        medianlinewidth=1.5,
        colormap=:batlow,
    )
end

# axis defaults

function default_axis(::Type{Axis})
    return (
        xgridvisible=false,
        ygridvisible=false,
        topspinevisible=false,
        rightspinevisible=false,
        bottomspinecolor=:darkgray,
        leftspinecolor=:darkgray,
        xtickcolor=:darkgray,
        ytickcolor=:darkgray,
        xticklabelfont="Noto Sans Light",
        yticklabelfont="Noto Sans Light",
    )
end

function default_axis(::Type{Axis3})
    return (
        xgridvisible=false,
        ygridvisible=false,
        zgridvisible=false,
        xspinecolor=:darkgray,
        yspinecolor=:darkgray,
        zspinecolor=:darkgray,
        xtickcolor=:darkgray,
        ytickcolor=:darkgray,
        ztickcolor=:darkgray,
        xticklabelfont="Noto Sans Light",
        yticklabelfont="Noto Sans Light",
        zticklabelfont="Noto Sans Light",
    )
end

# default figure (may be better to only change on the axes.)

function default_figure()
    return (
        font = "Noto Sans",
    )
end
