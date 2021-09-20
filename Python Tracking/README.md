# "Intructions for Use" by Ben Wurster:

1. Put video to load filename in stageVideo.py
2. Run stageVideo.py
    1. Wait for images to be loaded from video.
    2. Draw midline by clicking on the 2 glottis endpoints.
    3. If you messed that up, don't worry! Just click again to clear the line and go again. Just remember "green means good".
    4. Click enter to proceed. The images will now be automatially rotated.
3. Run pointTrack.py
    1. Wait for images to load
    2. Select unique, distinguishable points to track. Large veins are best for this. A green box will appear around where you selected.
    3. Click enter to begin point tracking.
    4. Wait until program is complete.
4. Run analyzeOutput.py
    1. Observe features in graphs that are displayed.
5. Clean up after self
    1. Use cleanup.py to clear any generated data after copying away anything that is important

# "Other Notes" also by Ben Wurster:

This application as a whole is segmented into 3 parts for ease of development and data extraction: 

1. ### staging ('stageVideo.py')
    The video frames are staged for processing after being adjusted to be optimal for tracking.
2. ### tracking ('pointTrack.py')
    This is the algorithm that tracks motion from frame to frame. It creates a file 'motionData.csv' when finished with x-coordinate motion data.
3. ### analysis ('analyzeOutput.py') 
    This program generates graphs and will eventually output any other data we want to extract from the motion data.
    This is the only subpart that is still a work in progress. What kind of data do we want to extract from accurate point tracking?

They should be ran in this order; there is no check for the prior one having been run, so it could cause some unexpected errors.

There is also a 'cleanup.py' file that is very good practice to run before pushing to GitHub to avoid large amounts of data being stored on GitHub. Not running cleanup and recklessly pushing all changes to GitHub WILL result in a very large push that may render your computer very slow for some time.

The program should be robust enough to not need to be reset before each run, but once again: make sure you run these three programs in order to achieve desireable results.

There is a Makefile that can be of use in running and developing the program if you are on Linux. I(Ben) am on Windows and tried to use it through WSL Ubuntu, but OpenCV graphics is really unforgiving with the system interface and I could not get it to work.

Issues that I have ran into:
1. ### Roughly-vertical midline bug. 
    For some images, when the midline is not exactly vertical, but very close, the use of the rotation matrix on the images results in program errors. 
2. ### Incomplete third stage
    I have no clue exactly what the tracking data should be used for. The motion data could be very useful if used well by someone who understands exactly what algorithm determines the mucosal waves from surface points. Such ideas are beyond my understanding.