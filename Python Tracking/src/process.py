################################################################################
#
#   Program Purpose: This program is what computes point motion.
#
#   Primary Author:  Ben Wurster
#
################################################################################

import sys
import numpy as np
import cv2
from src import images
import math

def track(templates, initialLocations, METHOD, TEMPLATE_SIZE):
    NUM_POINTS = len(initialLocations)
    # array for all locations over all frames
    # indexing is [frame, point, x and y]
    locations = np.empty((0, NUM_POINTS, 2))

    i=0
    colorImage = images.load(i)
    while(colorImage is not None):
        # import fresh frame
        frame = cv2.cvtColor(colorImage, cv2.COLOR_BGR2GRAY)
        
        # row array
        frameLocations = []

        # iterate over all points
        for j in range(NUM_POINTS):
            # hard boundaries prevent stray
            minY = initialLocations[j][1]-TEMPLATE_SIZE-3
            maxY = initialLocations[j][1]+TEMPLATE_SIZE+3
            hardMinX = initialLocations[j][0]-TEMPLATE_SIZE-30
            hardMaxX = initialLocations[j][0]+TEMPLATE_SIZE+30

            # soft boundary restricts position delta
            maxFrameMotion = 3
            if(i > 0):
                previousLocation = locations[-1, j, 0]
                softMinX = previousLocation - TEMPLATE_SIZE - maxFrameMotion
                softMaxX = previousLocation + TEMPLATE_SIZE + maxFrameMotion
            else:
                softMinX = hardMinX
                softMaxX = hardMaxX

            # maxDeviation = 2
            # if(i > 1):
            #     locSub1 = locations[-1, j, 0]
            #     locSub2 = locations[-2, j, 0]
            #     predictedLoc = locSub1 - (locSub2 - locSub1)
            #     softMinX = predictedLoc - TEMPLATE_SIZE - maxDeviation
            #     softMaxX = predictedLoc + TEMPLATE_SIZE + maxDeviation
            # else:
            #     softMinX = hardMinX
            #     softMaxX = hardMaxX

            # decides which boundary to use
            if(softMinX > hardMinX):
                minX = softMinX
            else:
                minX = hardMinX
            if(softMaxX < hardMaxX):
                maxX = softMaxX
            else:
                maxX = hardMaxX

            croppedFrame = frame[minY:maxY, minX:maxX]

            result = cv2.matchTemplate(croppedFrame, templates[j], METHOD)

            min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(result)

            # byproduct of other image comparision techniques. They have different 
            # rules for output.
            if METHOD in [cv2.TM_SQDIFF, cv2.TM_SQDIFF_NORMED]:
                location = min_loc
            else:
                location = max_loc

            location = (location[0] + minX + TEMPLATE_SIZE, location[1] + minY + TEMPLATE_SIZE)

            frameLocations.append(location)

        # push new row to locations array
        frameLocations = np.array([frameLocations]).astype(int)
        locations = np.append(locations, frameLocations, axis=0).astype(int)
        i += 1
        colorImage = images.load(i)

    return locations


def calculateDistance(locations, midVal):
    numFrames = locations.shape[0]
    numPoints = locations.shape[1]
    data = np.empty((numFrames, numPoints))
    for i in range(numFrames):
        for j in range(numPoints):
            data[i,j] = abs( locations[i,j,0] - midVal )
    return data

def averageAndNormalize(data):
    pointMean = np.mean(data, 0)
    pointStd = np.std(data, 0)
    normalizedArray = (data - pointMean) / pointStd
    normalizedAndAveraged = np.mean(normalizedArray, 1)
    return normalizedAndAveraged

# This value should be the number of frames between 1 and 2 motion cycles to 
# capture the next maximum but not the one after
REACH_CONSTANT = 30

def getMaxIndices(data):
    numFrames = data.shape[0]
    numPoints = data.shape[1]

    maxIndices = []

    for i in range(numPoints):
        max = np.amax(data[0:25, i], 0)
        maxIndex = np.argmax(data[0:25, i], 0)

        pointMaximumLocs = []
        pointMaximumLocs.append(maxIndex)

        j = maxIndex + 5
        while(j < numFrames - REACH_CONSTANT):
            max = np.amax(data[j:j+REACH_CONSTANT, i], 0)
            maxIndex = j + np.argmax(data[j:j+REACH_CONSTANT, i], 0)
            pointMaximumLocs.append(maxIndex)
            j = maxIndex + 5

        maxIndices.append(pointMaximumLocs)
    
    return maxIndices


