################################################################################
#
#   Program Purpose: This program generates a graph from input array data
#
#   Primary Author:  Ben Wurster
#
################################################################################

import math
import numpy as np
import matplotlib.pyplot as plt

def plotMotion(data, maxIndices):
    numPoints = data.shape[1]

    maxVals = []
    for i in range(len(maxIndices)):
        subList = []
        for j in range(len(maxIndices[i])):
            subList.append(data[maxIndices[i][j],i])
        maxVals.append(subList)

    if numPoints == 1:
        plt.plot(data[:,0])
        plt.scatter(maxIndices[0], maxVals[0], c="#ff0000")
        ax = plt.gca()
        max = np.amax(data[:,0])
        min = np.amin(data[:,0])
        top = math.ceil(max + 0.5 * (max - min))
        bottom = math.floor(min - 0.5 * (max - min))
        ax.set_ylim(bottom, top)
    else:
        fig, axs = plt.subplots(numPoints)
        for i in range(numPoints):
            axs[i].plot(data[:,i], '-')
            axs[i].scatter(maxIndices[i], maxVals[i], c="#ff0000")
            max = np.amax(data[:,i])
            min = np.amin(data[:,i])
            top = math.ceil(max + 0.5 * (max - min))
            bottom = math.floor(min - 0.5 * (max - min))
            axs[i].set_ylim(bottom, top)
    plt.show()

def plotAveraged(data):
    plt.plot(data)
    plt.show()
