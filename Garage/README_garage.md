Data currently is from three recording basestations, so lots of duplication.
Duplicates are not exact because the time stamps created by different 
base stations differ very slightly. 
Also, errors in reception may occur on one base station and not on others.

Put everything in SQL db then we will see if it needs to be filtered to remove duplication.

- Edit SensorIdHash.txt   NEED TO ADD MORE SENSORS AND MODULES.
- Edit ModuleIdHash.txt  to add description for new modules.
- Extract new  sensorLocations.txt from .3dm drawing.

-    cat raw_data/SensorRecordOuput*.txt  \
         [  |  ../utils/SensorDataFreqFilter  30  ]  >tmp/All_data.txt

-    ./buildDB tmp/All_data.txt  SensorReadings.db

Tests need more work.
