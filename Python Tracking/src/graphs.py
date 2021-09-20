################################################################################
#
#   Program Purpose: This program generates a graph from input array data
#
#   Primary Author:  Ben Wurster
#
################################################################################

import math
import matplotlib.pyplot as plt
import numpy as np
from scipy.optimize import curve_fit

def basicPlot(data):
    '''Performs a basic plot of input data. It will create a sub-plot for each column in the input array.

    Args:
        data:   The input array
    '''
    numFrames = data.shape[0]
    numPoints = data.shape[1]
    xVals = np.arange(numFrames)

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

def plotMotion(data, maxIndices, singleCurves):
    '''Plots input data along with the determined max indices and the curves 
    that were fit to the data.

    Args:
        data:           The input array.
        maxIndices:     Array of arrays of indices at which the maximum is 
                        determined to occur.
        singleCurves:   The parameters of a sinusoidal wave for plotting the 
                        best fit sinusoidal function. Takes the form 
                        [...,[a,b,c], ...] in line with the objective function.
    '''
    numFrames = data.shape[0]
    numPoints = data.shape[1]

    maxVals = []
    for i in range(len(maxIndices)):
        subList = []
        for j in range(len(maxIndices[i])):
            subList.append(data[maxIndices[i][j],i])
        maxVals.append(subList)

    xVals = np.arange(numFrames)

    if numPoints == 1:
        plt.plot(data[:,0])
        plt.scatter(maxIndices[0], maxVals[0], c="#ff0000")

        plt.plot(singleCurves[0][0]*np.sin(singleCurves[0][1]*xVals) + singleCurves[0][2])   

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
            axs[i].plot(singleCurves[i][0]*np.sin(singleCurves[i][1]*xVals) + singleCurves[i][2]) 
            max = np.amax(data[:,i])
            min = np.amin(data[:,i])
            top = math.ceil(max + 0.5 * (max - min))
            bottom = math.floor(min - 0.5 * (max - min))
            axs[i].set_ylim(bottom, top)
    plt.show()

def objective(x, a, b, c):
    '''The objective function for the curve fit. Takes the form a*sin(b*x)+c. 
    Values will be fed to function by curve_fit function to determine best fits 
    for constant values.

    Args:
        x:  x-values to feed into function
        a:  amplitude
        b:  frequency/(2*pi)
        c:  vertical offset
    '''
    return a*np.sin(b*x) + c

def extractLobeCurves(data, maxIndices):
    '''Not finished! This is the function that is intended to find the curve 
    fits around individual curve maximums.

    Args:
        data:           The input array.
        maxIndices:     Array of arrays of indices at which the maximum is 
                        determined to occur.
    '''
    allCurves = []
    for i in range(len(maxIndices)):
        curvesForPoint = []
        for j in range(len(maxIndices[i])):
            if(maxIndices[i][j] == maxIndices[i][0]):
                intervalMin = maxIndices[i][j]
            else:
                intervalMin = int( maxIndices[i][j] - (maxIndices[i][j] - maxIndices[i][j-1])/4 )
            
            if(maxIndices[i][j] == maxIndices[i][-1]):
                intervalMax = maxIndices[i][j]
            else:
                intervalMax = int( maxIndices[i][j] + (maxIndices[i][j+1] - maxIndices[i][j])/4 )

            dataWindow = data[intervalMin:intervalMax, i]
            xVals = np.arange(intervalMin, intervalMax, 1)

            popt, _ = curve_fit(objective, xVals, dataWindow)

            curvesForPoint.append(popt)
        allCurves.append(curvesForPoint)
    
    return allCurves

def fitSingleCurves(data, derivCurves=None):
    '''Utilizes the objective function and the data to find a best curve fit.

    Args:
        data:           The input array.
        derivCurves:    Optional. The idea is that the derivative of a sine wave 
                        is a cosine wave, so they will have the same frequency. 
                        The derivative curve could be smoother and better determine an approximate oscillation frequency.
    '''
    numFrames = data.shape[0]
    numPoints = data.shape[1]
    xVals = np.arange(numFrames)
    paramsList = np.empty((0, 3))

    # print("test")
    # plt.plot(data[0:200, 0])
    # print("test")

    if(derivCurves is not None):
        guesses = derivCurves[:, 1]
    else:
        guesses = np.ones(3)

    for i in range(numPoints):
        params, _ = curve_fit(objective, xVals, data[:, i], [20, int(guesses[1]), 1])
        paramsList = np.append(paramsList, [params], axis=0)

    # plt.plot(objective(xVals[0:200],*(paramsList[0])))
    # plt.show()
    
    return paramsList
