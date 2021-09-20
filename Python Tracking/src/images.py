################################################################################
#
#   Program Purpose: Load images for use in main program.
#
#   Primary Author:  Ben Wurster
#
################################################################################

import sys
import cv2
import math
import numpy as np

MAX_WIDTH = 1000
MAX_HEIGHT = 600

def load(i):
    """Loads an image as array of pixel values

    Args:
        i   The image number as saved in picsCache folder

    Returns:
        img     the image array
    """
    img = cv2.imread('./assets/picsCache/PIC' + str(i) + '.png', cv2.IMREAD_COLOR)
    if img is not None:
        h, w = img.shape[0], img.shape[1]
        heightRatio = MAX_HEIGHT/h
        widthRatio = MAX_WIDTH/w
        dominantRatio = heightRatio if heightRatio < widthRatio else widthRatio
        img = cv2.resize(img, (0,0), fx=dominantRatio, fy=dominantRatio)
    return img

def write(img, i):
    """Writes an array of pixel values to an image

    Args:
        img     The array of pixel values
        i       The image number as saved in picsCache folder
    """
    cv2.imwrite('./assets/picsCache/PIC' + str(i) + '.png', img)

def alignGlottis(p1, p2, NUM_FRAMES):
    """Function to roate all images in picsCache

    Args:
        p1          one glottis endpoint
        p2          the other glottis endpoint
        NUM_FRAMES  number of frames to rotate

    """
    midpoint = (p1[0] + (p2[0] - p1[0])/2, p1[1] + (p2[1] - p1[1])/2)
    inverseSlope = (p1[0] - p2[0]) / (p1[1] - p2[1])
    angleFromVertAxis = -math.tan(inverseSlope) * 180 / math.pi
    rotationMatrix = cv2.getRotationMatrix2D(midpoint, angleFromVertAxis, 1)

    midlineLength = math.sqrt((p1[0] - p2[0])*(p1[0] - p2[0]) + (p1[1] - p2[1])*(p1[1] - p2[1]))

    for i in range(NUM_FRAMES):
        img = load(i)
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

        write(img, i)
    
    return int(midlineLength)

        

        
