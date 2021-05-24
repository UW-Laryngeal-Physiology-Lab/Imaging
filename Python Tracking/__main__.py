################################################################################
#
#   Program Purpose: This is the root program for laryngeal point tracking
#
#   Primary Author:  Ben Wurster
#
################################################################################

# necessary imports
import sys
import os
import cv2
from src import *

# imports that may eventually go
import numpy as np
import time

################################################################################
# Initialization
################################################################################
NUM_FRAMES = video.load('motion.avi')
TEMPLATE_SIZE = 5                   # size of template image
METHOD = cv2.TM_CCORR_NORMED        # image comparison technique
SEARCH_MARGIN = 15                  # margin around known location to check
IMG_COLOR = images.load(0)    # returns color image
IMG_GRAY = cv2.cvtColor(IMG_COLOR, cv2.COLOR_BGR2GRAY)

################################################################################
# Point selection and midline
################################################################################
window.init()
imageWithMidline, p1, p2 = window.drawMidline(IMG_COLOR)
templates, initialLocations = window.selectPoints(imageWithMidline, IMG_GRAY, TEMPLATE_SIZE)

################################################################################
# Motion Processing
################################################################################
print("Beginning processing...\n" +
    "please be patient at this time...")

# point tracking stage
locations = process.track(templates, initialLocations, NUM_FRAMES, 
    SEARCH_MARGIN, METHOD)

print("Processing is done!")

################################################################################
# Graph generation and Motion display
################################################################################
graphs.plotMotion(locations)
window.showMotion(locations, TEMPLATE_SIZE)

################################################################################
# Program cleanup
################################################################################
for i in range(NUM_FRAMES):
    os.remove('./assets/.rawPicsCache/PIC' + str(i) + '.png')
cv2.destroyAllWindows()