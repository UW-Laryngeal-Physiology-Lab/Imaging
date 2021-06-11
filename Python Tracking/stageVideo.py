################################################################################
#
#   Program Purpose: This program is the first of three programs necessary for 
#                    processing videos. This program does frame extraction and 
#                    rotational adjustment for easier tracking.
#
#   Primary Author:  Ben Wurster
#
################################################################################

# necessary imports
import cv2
from src import *
import json
import math


metaFile = open('./assets/metadata.json', 'r+')

json.dump({}, metaFile)
metaFile.truncate()
metaFile.seek(0)

vidData = json.load(metaFile)

NUM_FRAMES, FPS = video.load('motion.avi')

vidData["fps"] = FPS
vidData["frameCount"] = NUM_FRAMES

window.init()
imageWithMidline, p1, p2 = window.drawMidline(images.load(0))
window.kill()

print("Beginning automatic image alignment...\n" +
    "...please be patient at this time...")

def verticalAlignGlottis(p1, p2, NUM_FRAMES):
    midpoint = (p1[0] + (p2[0] - p1[0])/2, p1[1] + (p2[1] - p1[1])/2)
    inverseSlope = (p1[0] - p2[0]) / (p1[1] - p2[1])
    angleFromVertAxis = -math.tan(inverseSlope) * 180 / math.pi
    rotationMatrix = cv2.getRotationMatrix2D(midpoint, angleFromVertAxis, 1)

    midlineLength = math.sqrt((p1[0] - p2[0])*(p1[0] - p2[0]) + (p1[1] - p2[1])*(p1[1] - p2[1]))

    for i in range(NUM_FRAMES):
        img = images.load(i)
        cols,rows,p = img.shape
        img = cv2.warpAffine(img, rotationMatrix, (cols, rows))

        bottom = int(midpoint[1] + midlineLength * 3/4)
        top = int(midpoint[1] - midlineLength * 3/4)
        left = int(midpoint[0] - midlineLength)
        right = int(midpoint[0] + midlineLength)
        if(top < 0): bottom = 0
        if(left < 0): left = 0
        if(bottom >= rows): bottom = rows - 1
        if(right >= cols): right = cols - 1

        img = img[top:bottom, left:right, :]

        images.write(img, i)

verticalAlignGlottis(p1, p2, NUM_FRAMES)

print("Alignment is complete!")
metaFile.seek(0)
json.dump(vidData, metaFile)
metaFile.truncate()
metaFile.close()