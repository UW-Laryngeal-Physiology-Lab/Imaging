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
TEMPLATE_SIZE = 10                  # size of template image
METHOD = cv2.TM_CCORR_NORMED        # image comparison technique

################################################################################
# Midline, image adjustment, point selection
################################################################################
window.init()
imageWithMidline, p1, p2 = window.drawMidline(images.load(0))

window.kill()
print("Beginning automatic image alignment...\n" +
    "...please be patient at this time...")
images.alignGlottis(p1, p2, NUM_FRAMES)
print("Alignment is complete!")

IMG_COLOR = images.load(0)          # returns color image
IMG_GRAY = cv2.cvtColor(IMG_COLOR, cv2.COLOR_BGR2GRAY)

window.init()
templates, initialLocations = window.selectPoints(IMG_COLOR, IMG_GRAY, TEMPLATE_SIZE)
window.kill()

################################################################################
# Motion Processing
################################################################################
print("Beginning tracking...\n" +
    "...please be patient at this time...")

# point tracking stage
locations = process.track(templates, initialLocations, NUM_FRAMES, METHOD)

# data = process.calculate(locations)

print("Tracking is done!")

################################################################################
# Graph generation and Motion display
################################################################################
window.init()
graphs.plotMotion(locations)
window.showMotion(locations, TEMPLATE_SIZE)
# window.markedMotion(locations, TEMPLATE_SIZE, p1, p2)

################################################################################
# Program cleanup
################################################################################
for i in range(NUM_FRAMES):
    os.remove('./assets/.picsCache/PIC' + str(i) + '.png')
cv2.destroyAllWindows()