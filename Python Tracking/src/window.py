################################################################################
#
#   Program Purpose: This program implements the graphic functionality of the
#                    point tracking program.
#
#                    xClick, yClick, xHover, yHover are properties of mouse
#                    conditions. They are referenced often by other modules.
#
#   Primary Author:  Ben Wurster
#
################################################################################

import sys
import cv2

# Declaration of global mouse variables
xClick,yClick = -1,-1
xHover,yHover = -1,-1
mouseRelease = True

# mouse callback function
def mouseEvent(event,xPos,yPos,flags,param):
    global xClick,yClick,mouseRelease
    if (event==cv2.EVENT_LBUTTONDOWN and mouseRelease==True):
        xClick,yClick = xPos,yPos
        mouseRelease = False
    if (event==cv2.EVENT_LBUTTONUP and mouseRelease==False):
        mouseRelease = True
    if (event==cv2.EVENT_MOUSEMOVE):
        xHover = xPos
        yHover = yPos

# window setup
cv2.namedWindow('Point Tracker')
cv2.setMouseCallback('Point Tracker', mouseEvent)

def display(img):
    cv2.imshow('Point Tracker', img)

def selectPoints(IMG, TEMPLATE_SIZE):
    global xClick,yClick

    colorCpy = cv2.cvtColor(IMG, cv2.COLOR_GRAY2BGR)

    # list for holding values
    templates = []

    # array for location data
    initialLocations = []

    # point selection stage
    while(1):
        if(xClick >= 0 and yClick >= 0):
            pointPic = IMG[
                (yClick-TEMPLATE_SIZE):(yClick+TEMPLATE_SIZE),
                (xClick-TEMPLATE_SIZE):(xClick+TEMPLATE_SIZE)]

            # add template images and initial locations to parallel lists
            templates.append(pointPic)
            initialLocations.append((xClick,yClick))

            # draw rectangle around selected point
            cv2.rectangle(colorCpy, 
                (xClick-TEMPLATE_SIZE,yClick-TEMPLATE_SIZE),
                (xClick+TEMPLATE_SIZE,yClick+TEMPLATE_SIZE), 
                (0,255,0), 1)

            xClick,yClick = -1,-1

        display(colorCpy)

        # Exit with ENTER
        if cv2.waitKey(20) & 0xFF == 13:    # 49 = ASCII ENTER
            break
    
    return templates, initialLocations

def showMotion(locations, TEMPLATE_SIZE):
    i=0
    while(True):
        frame = cv2.imread('./assets/pics/PIC' + str(i+1) 
            + '.png', cv2.IMREAD_COLOR)
        if frame is None:
            sys.exit("Could not read image.")
        frame = cv2.resize(frame, (0,0), fx=2, fy=2)

        for j in range(len(locations[i])):
            cv2.rectangle(frame, tuple(locations[i][j]), 
                (locations[i][j][0] + 2*TEMPLATE_SIZE,
                locations[i][j][1] + 2*TEMPLATE_SIZE), 
                (0,255,0), 1)

        display(frame)

        cv2.waitKey(1)
        
        i += 1
        if(i >= len(locations)):
            i=0
        
        if(cv2.waitKey(10) & 0xFF == 27):
            break
