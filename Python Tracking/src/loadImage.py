################################################################################
#
#   Program Purpose: Load images for use in main program.
#
#   Primary Author:  Ben Wurster
#
################################################################################

import sys
import cv2

def loadFirstFrame(xscale=2,yscale=2):
    img = cv2.imread('./assets/pics/PIC1.png', cv2.IMREAD_GRAYSCALE)
    if img is None:
        sys.exit("Could not read image.")
    img = cv2.resize(img, (0,0), fx=xscale, fy=yscale)
    return img