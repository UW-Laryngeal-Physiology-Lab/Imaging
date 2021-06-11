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

df = pd.read_csv('./assets/motionData.csv')
data = df.to_numpy()

maxIndices = process.getMaxIndices(data)

graphs.plotMotion(data, maxIndices)
# graphs.plotAveraged(averagedData)