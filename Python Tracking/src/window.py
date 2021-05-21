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
    global xClick,yClick,xHover,yHover,mouseRelease
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



def drawMidline(image):
    """Function to draw a midline on input video. Allows for footage taken at
    any angle and will give rise to a vectoring function and the midline is
    center of oscillation.

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

    while True:
        frameCpy = image.copy()

        if(xClick >= 0 and yClick >= 0):
            if(p1[0] == None and p1[1] == None):
                p1 = (xClick, yClick)
            elif(p2[0] == None and p2[1] == None):
                p2 = (xClick, yClick)
                frameCpy = cv2.line(frameCpy, p1, p2, (255,0,0), 2)
            frameCpy = cv2.circle(frameCpy, (xClick, yClick), 3, (255,0,0), -1)
            xClick, yClick = -1, -1
            image = frameCpy
        elif(xHover >= 0 and yHover >= 0):
            frameCpy = cv2.circle(frameCpy, (xHover, yHover), 3, (0,0,255), -1)
            if (p1[0] != None and p1[1] != None):
                frameCpy = cv2.line(frameCpy, p1, (xHover, yHover), (0,0,255), 2)
                frameCpy = cv2.circle(frameCpy, p1, 3, (255,0,0), -1)
        
        display(frameCpy)

        cv2.waitKey(20)
        if(p1[0] != None and p1[1] != None and p2[0] != None and p2[1] != None):
            break

    return image, p1, p2

def selectPoints(displayImage, processingImage, TEMPLATE_SIZE):
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
        if cv2.waitKey(20) & 0xFF == 13:    # 49 = ASCII ENTER
            break
    
    return templates, initialLocations

def showMotion(locations, TEMPLATE_SIZE):
    i=0
    while(True):
        frame = cv2.imread('./assets/pics/PIC' + str(i) 
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
