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

def load(i):
    xscale = 2
    yscale = 2
    img = cv2.imread('./assets/.picsCache/PIC' + str(i) + '.png', cv2.IMREAD_COLOR)
    if img is None:
        sys.exit("Could not read image.")
    img = cv2.resize(img, (0,0), fx=xscale, fy=yscale)
    return img

def write(img, i):
    cv2.imwrite('./assets/.picsCache/PIC' + str(i) + '.png', img)

def alignGlottis(p1, p2, NUM_FRAMES):
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

        

        
