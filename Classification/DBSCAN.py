# Imports.
import h5py
from sklearn.cluster import DBSCAN
import numpy as np
 
# Meta data.
folder = "Test"
file_number = "012"

# Load the data.
file = "Data/" + folder + "/B210_SAMPLES_" + folder + "_" + file_number + ".jld"
file = h5py.File(file, "r")
file_data =  file["Doppler FFT Matrix"]
raw_data = np.matrix(np.array(file_data))

# Convert data to complex type.
complex_data = np.zeros(shape=raw_data.shape, dtype=complex)
for r, row in enumerate(raw_data):
    for c, value in enumerate(row.T):
        complex_data[r][c] = complex(value['re_'], value['im_'])

# Implement DBSCAN.
result = DBSCAN().fit(np.absolute(complex_data))
print(result.labels_)
