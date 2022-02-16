# ----------------------------- #
#  G L M A K I E   T H E M E S  #
# ----------------------------- #

# using GLMakie
using CairoMakie
CairoMakie.activate!(type = "pdf")

#  D A R K   T H E M E  #

# set_theme!(theme_dark())
# update_theme!(
# 	Axis = (
#     	leftspinevisible = true,
#     	rightspinevisible = true,	
#     	topspinevisible = true,
#     	bottomspinevisible = true,
#     	bottomspinecolor = :gray90,
#     	topspinecolor = :gray90,
#     	leftspinecolor = :gray90,
#     	rightspinecolor = :gray90,
# 		cycle = []
# 		),
# 	Legend = (
#     	leftspinevisible = true,
#     	rightspinevisible = true,
#     	topspinevisible = true,
#     	bottomspinevisible = true,
#     	bottomspinecolor = :gray90,
#     	topspinecolor = :gray90,
#     	leftspinecolor = :gray90,
#     	rightspinecolor = :gray90,
# 		backgroundcolor = :gray90,
# 		),
# 	fontsize = 50,
# 	textcolor = :gray90
# )

# originColor = :gray90
# lineThickness = 7
# dashThickness = 2.5
# dotSize = 8
# originThickness = 2

#  D E F A U L T   T H E M E  #

update_theme!(
	Axis = (
    	leftspinevisible = true,
    	rightspinevisible = true,
    	topspinevisible = true,
    	bottomspinevisible = true,
    	bottomspinecolor = :black,
    	topspinecolor = :black,
    	leftspinecolor = :black,
    	rightspinecolor = :black,
		xgridcolor = :gray70, 
		ygridcolor = :gray70,
		cycle = [],
		yticklabelpad = 20,
		ylabelpadding = 15
		),
	Legend = (
    	leftspinevisible = true,
    	rightspinevisible = true,
    	topspinevisible = true,
    	bottomspinevisible = true,
    	bottomspinecolor = :gray90,
    	topspinecolor = :gray90,
    	leftspinecolor = :gray90,
    	rightspinecolor = :gray90,
		backgroundcolor = :gray90,
		),
	fontsize = 65,
	textcolor = :black,
	font ="Fonts/ComputerModern/cmunrm.ttf",
)

originColor = :black
lineThickness = 6
dashThickness = 2.5
dotSize = 8
originThickness = 2

# ------- #
#  E O F  #
# ------- #