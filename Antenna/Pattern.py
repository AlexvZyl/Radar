import pandas as pd
import matplotlib.pyplot as mp
import math
import numpy as np

# Load data.
data = pd.read_csv("Data/ASP.csv")
gain = data.iloc[1810:1990, 3]
gain = gain.values
theta = data.iloc[1810:1990, 2] * math.pi / 180
theta = theta.values

theta_int = np.arange(-math.pi, math.pi, 2*math.pi/1000)
gain_int = np.interp(theta_int, theta, gain)

# Theme.
params = {"ytick.color" : "black",
          "xtick.color" : "black",
          "axes.labelcolor" : "black",
          "axes.edgecolor" : "black",
          "text.usetex" : True,
          "font.family" : "serif",
          "font.serif" : ["Computer Modern Serif"]}
mp.rcParams.update(params)

# Plot.
ax = mp.axes(projection='polar')
ax.set_ylim(-40, 5)
mp.title("LP0965 Radiation Pattern (1.1 GHz)")
mp.polar(theta_int, gain_int)
ax.set_rlabel_position(90)
ax.tick_params(axis='both', which='major', labelsize=8)

# Save.
mp.savefig("LP0965_1.1GHz_Pattern.pdf", bbox_inches='tight')
