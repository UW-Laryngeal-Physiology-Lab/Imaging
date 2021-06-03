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

def plotMotion(data):
    numPoints = data.shape[1]

    if numPoints == 1:
        plt.plot(data[:,0])
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
            max = np.amax(data[:,i])
            min = np.amin(data[:,i])
            top = math.ceil(max + 0.5 * (max - min))
            bottom = math.floor(min - 0.5 * (max - min))
            axs[i].set_ylim(bottom, top)
    plt.show()

def plotAveraged(data):
    plt.plot(data)
    plt.show()
