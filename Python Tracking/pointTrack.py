################################################################################
#
#   Program Purpose: This program is the second of three programs necessary for 
#                    processing videos. This program does the actual point 
#                    selection and motion tracking.
#
#   Primary Author:  Ben Wurster
#
################################################################################

# necessary imports
import cv2
from src import *
import pandas as pd

METHOD = cv2.TM_CCORR_NORMED        # image comparison technique
TEMPLATE_SIZE = 10                  # size of template image

IMG_COLOR = images.load(0)          # returns color image
IMG_GRAY = cv2.cvtColor(IMG_COLOR, cv2.COLOR_BGR2GRAY)

midVal = int(IMG_COLOR.shape[1]/2)

window.init()
templates, initialLocations = window.selectPoints(IMG_COLOR, IMG_GRAY, TEMPLATE_SIZE, midVal)
window.kill()

################################################################################
# Motion Processing
################################################################################
print("Beginning tracking...\n" +
    "...please be patient at this time...")

# point tracking stage
locations = process.track(templates, initialLocations, METHOD, TEMPLATE_SIZE)

distanceData = process.calculateDistance(locations, midVal)

print("Tracking is done!")

df = pd.DataFrame()
for i in range(distanceData.shape[1]):
    df['Point ' + str(i)] = pd.Series(distanceData[:, i])

df.to_csv('./assets/motionData.csv', index=False)

window.init()
window.showMotion(locations, TEMPLATE_SIZE)
# window.markedMotion(locations, TEMPLATE_SIZE, p1, p2)

