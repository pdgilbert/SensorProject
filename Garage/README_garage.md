Data currently is from three recording basestations, so lots of duplication.
Duplicates are not exact because the time stamps created by different 
base stations differ very slightly. 
Also, errors in reception may occur on one base station and not on others.

Put everything in SQL db then we will see if it needs to be filtered to remove duplication.
Also consider piping data through a filter like `utils/SensorDataFreqFilter`.

See script `utils/buildDB` for details about data preparation, filtering, and loading the
database.

Tests need more work.
