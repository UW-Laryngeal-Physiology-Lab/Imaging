# This is a useful program to help when developing programs to just display all
# of the images in the picsCache folder.

import cv2
from src import *
import json
import math

i=0

while(True):
    image = images.load(i)
    if image is None:
        i = 0
        image = images.load(i)
    cv2.imshow("Image", image)
    i += 1
    if cv2.waitKey(20) & 0xFF == 13:    # 13 = ASCII ENTER
        break
cv2.destroyAllWindows()
