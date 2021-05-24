################################################################################
#
#   Program Purpose: Load images for use in main program.
#
#   Primary Author:  Ben Wurster
#
################################################################################

import sys
import cv2

def load(i, xscale=2,yscale=2):
    img = cv2.imread('./assets/.rawPicsCache/PIC' + str(i) + '.png', cv2.IMREAD_COLOR)
    if img is None:
        sys.exit("Could not read image.")
    img = cv2.resize(img, (0,0), fx=xscale, fy=yscale)
    return img