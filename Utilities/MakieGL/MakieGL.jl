# --------------- #
#  G L M A K I E  #
# --------------- #

using GLMakie
set_theme!(theme_dark())
update_theme!(
	Axis = (
    	leftspinevisible = true,
    	rightspinevisible = true,
    	topspinevisible = true,
    	bottomspinevisible = true,
    	bottomspinecolor = :gray90,
    	topspinecolor = :gray90,
    	leftspinecolor = :gray90,
    	rightspinecolor = :gray90,
		cycle = []
		),
	Legend = (
		# framevisible = true,
    	leftspinevisible = true,
    	rightspinevisible = true,
    	topspinevisible = true,
    	bottomspinevisible = true,
    	bottomspinecolor = :gray90,
    	topspinecolor = :gray90,
    	leftspinecolor = :gray90,
    	rightspinecolor = :gray90,
		backgroundcolor = :gray90,
		)
	)

# --------------------- #
#  P A R A M E T E R S  #
# --------------------- #

textSize = 23
lineThickness = 4
dashThickness = 2.5
dotSize = 8
originThickness = 2

# ------- #
#  E O F  #
# ------- #