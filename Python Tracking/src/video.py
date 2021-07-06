################################################################################
#
#   Program Purpose: handles video capture
#
#   Primary Author:  Ben Wurster
#
################################################################################

import sys
import os
import cv2

def load(file):
    print('Beginning loading of ' + './assets/' + file)

    cap = cv2.VideoCapture('./assets/' + file)
    ret, frame = cap.read()
    FPS = int(cap.get(cv2.CAP_PROP_FPS))

    if(not ret):
        sys.exit("Could not read first frame.")

    counter = 0
    while ret:
        cv2.imwrite('./assets/picsCache/PIC' + str(counter) + '.png', frame)
        counter += 1
        ret, frame = cap.read()

    print('Finished loading ' + './assets/' + file)
    return counter, FPS
