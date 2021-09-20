################################################################################
#
#   Program Purpose: This program is the first of three programs necessary for 
#                    processing videos. This program does frame extraction and 
#                    vertical glottis alignment for easier tracking.
#
#                    Note: there is an glaring bug in this program that pertains
#                    to when the desired vertical alignment is close to 
#                    vertical. It may come down to some rounding for the 
#                    rotation matrix.
#
#   Primary Author:  Ben Wurster
#
################################################################################

# necessary imports
import cv2
from src import *
import json
import math

# metadata file for storing info related to video once segmented into images
metaFile = open('./assets/metadata.json', 'r+')
json.dump({}, metaFile)
metaFile.truncate()
metaFile.seek(0)
vidData = json.load(metaFile)

# load video as individual frames and return video info
#                            VV Can be changed to analyze different video
NUM_FRAMES, FPS = video.load('Normal.avi')

# add to the json
vidData["fps"] = FPS
vidData["frameCount"] = NUM_FRAMES

# display window to draw a desired midline
window.init()
p1, p2 = window.drawMidline(images.load(0))
window.kill()

print("Beginning automatic image alignment...\n" +
    "...please be patient at this time...")

# location of slight rotation bug
def verticalAlignGlottis(p1, p2, NUM_FRAMES):
    '''Overwrites existing images in cache with adjusted images to vertically 
    align the glottis.

    Args:
        p1:         2-tuple representing (x,y) position of one of the glottis ends
        p2:         2-tuple representing (x,y) position of the other glottis end
        NUM_FRAMES: number of frames stored in cache
    '''
    midpoint = (p1[0] + (p2[0] - p1[0])/2, p1[1] + (p2[1] - p1[1])/2)
    slope = (p2[1] - p1[1]) / (p1[0] - p2[0])
    angle = math.atan(slope) * 180 / math.pi

    rotationMatrix = cv2.getRotationMatrix2D(midpoint, 90 - angle, 1)

    midlineLength = math.sqrt((p1[0] - p2[0])*(p1[0] - p2[0]) + (p1[1] - p2[1])*(p1[1] - p2[1]))

    for i in range(NUM_FRAMES):
        img = images.load(i)
        cols,rows,p = img.shape
        img = cv2.warpAffine(img, rotationMatrix, (cols, rows))
        img = crop(img, midpoint, midlineLength)
        images.write(img, i)

def crop(img, midpoint, midlineLength):
    '''Crops image to desireable size for optimal viewing with glottal midline 
    centered.

    Args:
        img:            image to crop
        midpoint:       the desired midpoint of the unadjusted image
        midlineLength:  lenght of line drawn(length of glottis)

    Returns:
        img:    cropped image
    '''
    rows,cols,p = img.shape
    bottom = int(midpoint[1] + midlineLength * 3/4)
    top = int(midpoint[1] - midlineLength * 3/4)
    left = int(midpoint[0] - midlineLength)
    right = int(midpoint[0] + midlineLength)

    if(top < 0): 
        top = 0
    if(bottom >= rows): 
        bottom = rows - 1
    if(left < 0 or right >= cols):
        leftGap = midpoint[0]
        rightGap = cols - 1 - midpoint[0] 
        smallestGap = leftGap if leftGap < rightGap else rightGap
        left = int(midpoint[0] - smallestGap)
        right = int(midpoint[0] + smallestGap)

    img = img[top:bottom, left:right, :]
    return img

#
# return to standard program execution flow
#

if(p1[0] != p2[0]):
    verticalAlignGlottis(p1, p2, NUM_FRAMES)
else:
    midlineLength = abs(p1[1] - p2[1])
    midpoint = (p1[0], (p1[1] + p2[1])/2)
    for i in range(NUM_FRAMES):
        img = images.load(i)
        img = crop(img, midpoint, midlineLength)
        images.write(img, i)


print("Alignment is complete!")
metaFile.seek(0)
json.dump(vidData, metaFile)
metaFile.truncate()
metaFile.close()