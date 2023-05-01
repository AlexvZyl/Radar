import pandas as pd
import matplotlib.pyplot as mp
import math
import numpy as np

def find_eff_region(theta, gain):
    zero_index = math.ceil(len(theta)/2)
    print(zero_index)
    theta_1_ind = zero_index
    theta_2_ind = zero_index
    while(gain[theta_1_ind] > -3):
        theta_1_ind += 1
    while(gain[theta_2_ind] > -3):
        theta_2_ind -= 1
    return theta[theta_1_ind], theta[theta_2_ind], gain[theta_1_ind], gain[theta_2_ind]

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

# Plot effective region.
theta_1, theta_2, gain_1, gain_2 = find_eff_region(theta_int, gain_int)
mp.polar([0, theta_1], [-40, 5], color = 'gray', alpha = 0.65)
mp.polar([0, theta_2], [-40, 5], color = 'gray', alpha = 0.65)
ax.fill([theta_1, theta_2, theta_2, theta_1], [-40, -40, 50, 50], color='gray', alpha=0.45)

# Plot entire pattern.
mp.polar(theta_int, gain_int)
ax.set_rlabel_position(90)
ax.tick_params(axis='both', which='major', labelsize=8)

# Save.
mp.savefig("LP0965_1.1GHz_Pattern.pdf", bbox_inches='tight')
