This application as a whole is segmented into 3 parts for ease of development and data extraction: 

    1. staging('stageVideo.py')
        The video frames are staged for processing after being adjusted to be optimal for tracking.
    2. tracking('pointTrack.py')
        This is the algorithm that tracks motion from frame to frame. It creates a file 'motionData.csv' when finished with x-coordinate motion data.
    3. analysis('analyzeOutput.py') 
        This program generates graphs and will eventually output any other data we want to extract from the motion data.

They should be ran in this order; there is no check for the prior one having been run, so it could cause some unexpected errors.

There is also a 'cleanup.py' file that is very good practice to run before pushing to GitHub to avoid large amounts of data being stored on GitHub. 

The program should be robust enough to not need to be reset before each run, but once again: make sure you run these three programs in order to achieve desireable results.

There is a Makefile that can be of use in running and developing the program if you are on Linux. I(Ben) am on Windows and tried to use it through WSL Ubuntu, but OpenCV graphics is really unforgiving with the system interface and I could not get it to work.