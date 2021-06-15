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
from src import images

# Declaration of global mouse variables
xClick,yClick = -1,-1
xHover,yHover = -1,-1
mouseRelease = True

# mouse callback function
def mouseEvent(event,xPos,yPos,flags,param):
    global xClick,yClick,xHover,yHover,mouseRelease
    if (event==cv2.EVENT_LBUTTONDOWN and mouseRelease==True):
        xClick,yClick = xPos,yPos
        mouseRelease = False
    if (event==cv2.EVENT_LBUTTONUP and mouseRelease==False):
        mouseRelease = True
    if (event==cv2.EVENT_MOUSEMOVE):
        xHover = xPos
        yHover = yPos   

def init():
    cv2.namedWindow('Point Tracker')
    cv2.setMouseCallback('Point Tracker', mouseEvent)

def kill():
    cv2.destroyWindow('Point Tracker')

def display(img):
    cv2.imshow('Point Tracker', img)

def drawMidline(image):
    """Function to draw a midline on input frame. Is called by rotate function.

    Args:
        image:  the color image to draw the midline on

    Returns:
        image:  a copy of the image argument with the midline drawn on
        p1:     the first midline point selected
        p2:     the second midline point selected
    """
    print('Draw midline---click to place each endpoint')

    global xClick, yClick, xHover, yHover

    p1 = (None, None)
    p2 = (None, None)

    baseImageSave = image.copy()
    while True:
        frameCpy = image.copy()

        if(xClick >= 0 and yClick >= 0):
            if(p1[0] == None and p1[1] == None):
                p1 = (xClick, yClick)
                frameCpy = cv2.circle(frameCpy, (xClick, yClick), 3, (0,255,0), -1)

            elif(p2[0] == None and p2[1] == None):
                p2 = (xClick, yClick)
                frameCpy = cv2.line(frameCpy, p1, p2, (0,255,0), 2)
                frameCpy = cv2.circle(frameCpy, (xClick, yClick), 3, (0,255,0), -1)
            else:
                frameCpy = baseImageSave.copy()
                p1 = (None, None)
                p2 = (None, None)
            xClick, yClick = -1, -1
            image = frameCpy.copy()
        elif(xHover >= 0 and yHover >= 0):
            if (p2[0] == None and p2[1] == None):
                frameCpy = cv2.circle(frameCpy, (xHover, yHover), 3, (0,0,255), -1)
            if (p1[0] != None and p1[1] != None and p2[0] == None and p2[1] == None):
                frameCpy = cv2.line(frameCpy, p1, (xHover, yHover), (0,0,255), 2)
                frameCpy = cv2.circle(frameCpy, p1, 3, (0,255,0), -1)

        display(frameCpy)

        # Exit with ENTER
        if( cv2.waitKey(20) & 0xFF == 13    # 13 = ASCII ENTER
            and p1[0] != None
            and p1[1] != None
            and p2[0] != None
            and p2[1] != None ):
            break

    return p1, p2


def selectPoints(displayImage, processingImage, TEMPLATE_SIZE, midVal):
    """Point selection function to pick out distinct points, savinging their
    location and image of surrounding area

    Args:
        displayImage:       color image for use in window
        processing image:   grayscale image for computational purposes
                            (template generation)
        TEMPLATE_SIZE:      constant for template generation

    Returns:
        templates:          list of template images
        initialLocations:   parallel list of locations for templates. Covention 
                            adopted is center of template.
    """
    print('Please select points to track')

    global xClick,yClick

    # list for holding values
    templates = []

    # array for location data
    initialLocations = []

    displayImage = cv2.line(displayImage, (midVal, 0),
        (midVal, displayImage.shape[0]-1), (0,255,0), 1)

    # point selection stage
    while True:
        if(xClick >= 0 and yClick >= 0):
            pointPic = processingImage[
                (yClick-TEMPLATE_SIZE):(yClick+TEMPLATE_SIZE),
                (xClick-TEMPLATE_SIZE):(xClick+TEMPLATE_SIZE)]

            # add template images and initial locations to parallel lists
            templates.append(pointPic)
            initialLocations.append((xClick,yClick))

            # draw rectangle around selected point
            cv2.rectangle(displayImage, 
                (xClick-TEMPLATE_SIZE,yClick-TEMPLATE_SIZE),
                (xClick+TEMPLATE_SIZE,yClick+TEMPLATE_SIZE), 
                (0,255,0), 1)

            xClick,yClick = -1,-1

        display(displayImage)

        # Exit with ENTER
        if cv2.waitKey(20) & 0xFF == 13:    # 13 = ASCII ENTER
            break
    
    return templates, initialLocations

def showMotion(locations, TEMPLATE_SIZE):
    i=0
    while(True):
        frame = images.load(i)

        for j in range(len(locations[i])):
            cv2.rectangle(frame, 
                (locations[i][j][0]-TEMPLATE_SIZE,locations[i][j][1]-TEMPLATE_SIZE),
                (locations[i][j][0]+TEMPLATE_SIZE,locations[i][j][1]+TEMPLATE_SIZE), 
                (0,255,0), 1)
            cv2.putText(frame, str(j), 
                (locations[i][j][0]+TEMPLATE_SIZE,locations[i][j][1]+TEMPLATE_SIZE),
                cv2.FONT_HERSHEY_PLAIN, 1, (0,255,0), 1)

        display(frame)
        
        i += 1
        if(i >= len(locations)):
            i=0
        
        if(cv2.waitKey(10) & 0xFF == 27):
            break

def markedMotion(locations, TEMPLATE_SIZE, p1, p2):
    A = p2[1] - p1[1]   # y2 - y1
    B = p1[0] - p2[0]   # x1 - x2
    C = (p2[0] - p1[0])*p1[1] + (p1[1] - p2[1])*p1[0]
    
    i=0
    while(True):
        frame = images.load(i)

        frame = cv2.line(frame, p1, p2, (200, 0, 0), 2)

        for j in range(len(locations[i])):
            x = locations[i][j][0] + TEMPLATE_SIZE
            y = locations[i][j][1] + TEMPLATE_SIZE
            midlineX = int((B*(B*x - A*y) - A*C)/(A*A + B*B))
            midlineY = int((A*(A*y - B*x) - B*C)/(A*A + B*B))

            frame = cv2.line(frame, (x,y), (midlineX, midlineY), (255, 100, 100), 1)

            frame = cv2.rectangle(frame, (x - TEMPLATE_SIZE, y - TEMPLATE_SIZE), 
                (x + TEMPLATE_SIZE, y + TEMPLATE_SIZE), 
                (0,255,0), 1)

        display(frame)

        cv2.waitKey(1)
        
        i += 1
        if(i >= len(locations)):
            i=0
        
        if(cv2.waitKey(10) & 0xFF == 27):   # ascii ESC
            break