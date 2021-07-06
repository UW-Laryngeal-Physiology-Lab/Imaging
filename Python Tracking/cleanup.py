################################################################################
#
#   Program Purpose: This program removes image storage overhead and resets 
#                    metadata. 
# 
#                    DO NOT RUN if any data that needs to be copied remains in 
#                    the './assets' folder
#
#   Primary Author:  Ben Wurster
#
################################################################################

import os
import cv2
from src import *
import json

# this is a VERY inefficent method of removing the images without passing extra 
# data in
i=0
image = images.load(i)
while(image is not None):
    os.remove('./assets/picsCache/PIC' + str(i) + '.png')
    i += 1
    image = images.load(i)

metaFile = open('./assets/metadata.json', 'w')
json.dump({}, metaFile)
metaFile.truncate()

try:
    os.remove('./assets/motionData.csv')
except:
    print("'motionData.csv' was not removed or does not exist")

cv2.destroyAllWindows()