################################################################################
#
#   Program Purpose: This program is what computes point motion.
#
#   Primary Author:  Ben Wurster
#
################################################################################

import sys
import numpy as np
import pandas as pd
import cv2
from src import images

def track(templates, initialLocations, NUM_FRAMES, METHOD, TEMPLATE_SIZE):
    NUM_POINTS = len(initialLocations)
    # array for all locations over all frames
    # indexing is [frame, point, x and y]
    locations = np.empty((0, NUM_POINTS, 2))

    for i in range(NUM_FRAMES):
        # import fresh frame
        frame = cv2.cvtColor(images.load(i), cv2.COLOR_BGR2GRAY)
        
        # row array
        frameLocations = []

        # iterate over all points
        for j in range(NUM_POINTS):
            # hard boundaries prevent stray
            minY = initialLocations[j][1]-TEMPLATE_SIZE-5
            maxY = initialLocations[j][1]+TEMPLATE_SIZE+5
            hardMinX = initialLocations[j][0]-TEMPLATE_SIZE-30
            hardMaxX = initialLocations[j][0]+TEMPLATE_SIZE+30

            # soft boundary restricts position delta
            maxFrameMotion = 4
            if(i > 0):
                previousLocation = locations[-1, j, 0]
                softMinX = previousLocation - TEMPLATE_SIZE - maxFrameMotion
                softMaxX = previousLocation + TEMPLATE_SIZE + maxFrameMotion
            else:
                softMinX = hardMinX
                softMaxX = hardMaxX

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


