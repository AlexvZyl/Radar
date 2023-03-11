# ----------------------------- #
#  G L M A K I E   T H E M E S  #
# ----------------------------- #

glmakie = false
# glmakie = true
cairomakie = !glmakie

if glmakie

	using GLMakie

	#  D A R K   T H E M E  #

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
			cycle = [],
			),
		Axis3 = (
			# Visibility.
	    	xspinesvisible = true,
	    	yspinesvisible = true,	
			zspinesvisible = true,	
			# Colors.
	    	xspinecolor_1 = :gray90,
			xspinecolor_2 = :gray90,
			xspinecolor_3 = :gray90,
			yspinecolor_1 = :gray90,
			yspinecolor_2 = :gray90,
			yspinecolor_3 = :gray90,
			zspinecolor_1 = :gray90,
			zspinecolor_2 = :gray90,
			zspinecolor_3 = :gray90,
			# Label padding.
			xlabeloffset = 70,
			ylabeloffset = 70,
			zlabeloffset = 70,
			# Ticks.
			xticksvisible = true,
			yticksvisible = true,
			zticksvisible = true,
			xtickcolor = :grey90,
			ytickcolor = :grey90,
			ztickcolor = :grey90,
			cycle = []
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
		# fontsize = 50,
		textcolor = :gray90
	)

	originColor = :gray90
	lineThickness = 1
	dashThickness = 2.5
	dotSize = 8
	originThickness = 2

end

#  PUBLISH THEME  #

if cairomakie

	using CairoMakie
	CairoMakie.activate!(type = "pdf")
	# CairoMakie.activate!(type = "png")

	update_theme!(
		Axis = (
		    font = "Latin Modern Math",
            titlefont = "Latin Modern Math",
            xlabelfont = "Latin Modern Math",
            ylabelfont = "Latin Modern Math",
            xticklabelfont = "Latin Modern Math",
            yticklabelfont = "Latin Modern Math",
			leftspinevisible = true,
			rightspinevisible = true,
			topspinevisible = true,
			bottomspinevisible = true,
			bottomspinecolor = :black,
			topspinecolor = :black,
			leftspinecolor = :black,
			rightspinecolor = :black,
			# xgridcolor = :gray80, 
			# ygridcolor = :gray80,
			xgridcolor = :gray50, 
			ygridcolor = :gray50,
			cycle = [],
			yticklabelpad = 20,
			ylabelpadding = 30,
            xlabelpadding = 20,
			xtickwidth = 3,
			ytickwidth = 3,
			xticksize = 24,
			yticksize = 24,
			xtickalign = 0,
			ytickalign = 1,
			spinewidth = 3,
			titlegap = 40,
		),
		Axis3 = (
            font = "Latin Modern Math",
            titlefont = "Latin Modern Math",
            xlabelfont = "Latin Modern Math",
            ylabelfont = "Latin Modern Math",
            zlabelfont = "Latin Modern Math",
            xticklabelfont = "Latin Modern Math",
            yticklabelfont = "Latin Modern Math",
            zticklabelfont = "Latin Modern Math",
			# Visibility.
	    	xspinesvisible = true,
	    	yspinesvisible = true,	
			zspinesvisible = true,	
			# Colors.
	    	xspinecolor_1 = :black,
			xspinecolor_2 = :black,
			xspinecolor_3 = :black,
			yspinecolor_1 = :black,
			yspinecolor_2 = :black,
			yspinecolor_3 = :black,
			zspinecolor_1 = :black,
			zspinecolor_2 = :black,
			zspinecolor_3 = :black,
			xgridcolor = :gray80, 
			ygridcolor = :gray80,
			zgridcolor = :gray80,
			# Label.
			xlabeloffset = 130,
			ylabeloffset = 130,
			zlabeloffset = 130,
			titlegap = -160,
			# Ticks.
			xticksvisible = true,
			yticksvisible = true,
			zticksvisible = true,
			xtickcolor = :grey10,
			ytickcolor = :grey10,
			ztickcolor = :grey10,
			cycle = [],
			viewmode = :fit,
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
			framewidth = 2,
		),
		# fontsize = 50, # 3D
		fontsize = 65, # 2D
		textcolor = :black,
		font = "Latin Modern Math", # Linux.
		titlefont = "Latin Modern Math", # Linux.
		figure_padding = (20, 40, 10, 10)
	)

	originColor = :black
	lineThickness = 1
	dashThickness = 2.5
	dotSize = 8
	originThickness = 2

end

# ------- #
#  E O F  #
# ------- #
