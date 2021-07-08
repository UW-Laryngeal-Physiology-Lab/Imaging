################################################################################
#
#   Program Purpose: This program uses a three point sliding filter to smooth
#   data collected, and saves to a new csv file.
#
#   Primary Author:  Patrick Merchant
#
################################################################################

import pandas as pd

def smoothData():
    df = pd.read_csv('./assets/motionData.csv')
    data = df.to_numpy()
    cols = len(data[0])
    rows = len(data)
    for j in range(cols):
        for i in range(1, rows-1):
            # Three point sliding filter
            data[i][j] = (data[i-1][j] + data[i][j] + data[i+1][j]) / 3

    df.to_csv('./assets/motionDataSmooth.csv', index=False)
