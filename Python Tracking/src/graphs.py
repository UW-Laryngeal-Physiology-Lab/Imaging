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

def plotMotion(locations):
    numPoints = locations.shape[1]

    if numPoints == 1:
        plt.plot(locations[:,0,0])
        ax = plt.gca()
        max = np.amax(locations[:,0,0])
        min = np.amin(locations[:,0,0])
        top = math.ceil(max + 0.5 * (max - min))
        bottom = math.floor(min - 0.5 * (max - min))
        ax.set_ylim(bottom, top)
    else:
        fig, axs = plt.subplots(numPoints)
        for i in range(numPoints):
            axs[i].plot(locations[:,i,0], '-')
            max = np.amax(locations[:,i,0])
            min = np.amin(locations[:,i,0])
            top = math.ceil(max + 0.5 * (max - min))
            bottom = math.floor(min - 0.5 * (max - min))
            axs[i].set_ylim(bottom, top)
    plt.show()