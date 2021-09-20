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

# image comparison technique
# can be tuned but I found cv2.TM_CCORR_NORMED to be the best performing one
METHOD = cv2.TM_CCORR_NORMED

# size of template image(box drawn around features)
TEMPLATE_SIZE = 10

# get first color image for display and convert to grey for processing
IMG_COLOR = images.load(0)
IMG_GRAY = cv2.cvtColor(IMG_COLOR, cv2.COLOR_BGR2GRAY)

# convention is vertically aligned glottis is in middle of screen
midVal = int(IMG_COLOR.shape[1]/2)

# point selection
window.init()
templates, initialLocations = window.selectPoints(IMG_COLOR, IMG_GRAY, TEMPLATE_SIZE, midVal)
window.kill()

print("Beginning tracking...\n" +
    "...please be patient at this time...")

# tracking
locations = process.track(templates, initialLocations, METHOD, TEMPLATE_SIZE)

# convert location data to distance from midline
distanceData = process.calculateDistance(locations, midVal)

print("Tracking is done!")

# onvert to dataframe
df = pd.DataFrame()
for i in range(distanceData.shape[1]):
    df['Point ' + str(i)] = pd.Series(distanceData[:, i])

# save to csv
df.to_csv('./assets/motionData.csv', index=False)

window.init()
window.showMotion(locations, TEMPLATE_SIZE)
# window.markedMotion(locations, TEMPLATE_SIZE, p1, p2)

cv2.destroyAllWindows()