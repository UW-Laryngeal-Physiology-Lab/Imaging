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

def track(templates, initialLocations, NUM_FRAMES, SEARCH_MARGIN, METHOD):
    # array for all locations over all frames
    # indexing is [frame, point, x and y]
    locations = np.empty((0, len(initialLocations), 2))

    for i in range(NUM_FRAMES):
        # import fresh frame
        frame = cv2.cvtColor(images.load(i), cv2.COLOR_BGR2GRAY)
        
        # row array
        frameLocations = []

        # iterate over all points
        for j in range(len(templates)):

            # crop result to specific range
            minY = 0
            minX = 0
            maxX = 0
            maxY = 0
            if(locations.shape[0] > 0):
                minY = initialLocations[j][1]-SEARCH_MARGIN
                maxY = initialLocations[j][1]+SEARCH_MARGIN
                minX = initialLocations[j][0]-SEARCH_MARGIN
                maxX = initialLocations[j][0]+SEARCH_MARGIN
                if(minY < 0):
                    minY = 0
                if(maxY > frame.shape[0]):
                    maxY = frame.shape[0]
                if(minX < 0):
                    minX = 0
                if(maxX > frame.shape[1]):
                    maxX = frame.shape[1]
                croppedFrame = frame[minY:maxY, minX:maxX]
            else:
                croppedFrame = frame

            # match template to cropped frame
            result = cv2.matchTemplate(croppedFrame, templates[j], METHOD)

            # pull match from cropped result
            min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(result)
            
            # byproduct of other image comparision techniques. They have different 
            # rules for output.
            if METHOD in [cv2.TM_SQDIFF, cv2.TM_SQDIFF_NORMED]:
                location = min_loc
            else:
                location = max_loc

            location = (location[0] + minX, location[1] + minY)

            frameLocations.append(location)

        # push new row to locations array
        frameLocations = np.array([frameLocations]).astype(int)
        locations = np.append(locations, frameLocations, axis=0).astype(int)
    
    return locations