Data currently is from three recording basestations, so lots of duplication.
Duplicates are not exact because the time stamps created by different 
base stations differ very slightly. 
Also, errors in reception may occur on one base station and not on others.

Put everything in SQL db then we will see if it needs to be filtered to remove duplication.

- Optionally pipe SensorRecordOuput*.txt trough a filter 
     cat raw_data/SensorRecordOuput*.txt  \
         [  |  ../utils/SensorDataFreqFilter  30  ]  >tmp/All_data.txt

-  ../utils/buildDB  intermediate/All_data.txt   garage_sensors.3dm   target/SensorReadings.db

See the `buildDB` script in utils/` for more specific details.
Tests need more work.
