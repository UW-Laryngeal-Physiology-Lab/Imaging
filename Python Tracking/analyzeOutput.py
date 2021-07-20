################################################################################
#
#   Program Purpose: This program is the third of three programs necessary for 
#                    processing videos. This program generates insightful graphs
#                    and processes data to extract useful metrics.
#
#   Primary Author:  Ben Wurster
#
################################################################################

# necessary imports
from src import *
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

df = pd.read_csv('./assets/motionData.csv')
"data variable is indexed data[frame #, point #]"
data = df.to_numpy()
graphs.basicPlot(data)

from src.smooth import smoothData
smoothData()
df_smooth = pd.read_csv('./assets/motionDataSmooth.csv')
"data variable is indexed data[frame #, point #]"
data_smooth = df_smooth.to_numpy()
graphs.basicPlot(data_smooth)

input("<Enter>")

'''
maxIndices is a 2D list with the first dimension being the point and the next 
being the index; maxIndices[point][maxVals]
'''
maxIndices = process.getMaxIndices(data)

# derivative call
deltaData = np.empty((data.shape[0] - 1, data.shape[1]))
for i in range(data.shape[1]):
    deltaData[:, i] = np.diff(data[:,i])
derivCurves = graphs.fitSingleCurves(deltaData)

singleCurves = graphs.fitSingleCurves(data, derivCurves) 
    # can add '=None' to remove derivative function
graphs.plotMotion(data, maxIndices, singleCurves)
