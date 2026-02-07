Data currently is from three recording basestations, so lots of duplication.
Duplicates are not exact because the time stamps created by different 
base stations differ very slightly. 
Also, errors in reception may occur on one base station and not on others.

Put everything in SQL db then we will see if it needs to be filtered to remove duplication.

- Edit SensorIdHash.txt   NEED TO ADD MORE SENSORS AND MODULES.
- Edit ModuleIdHash.txt  to add description for new modules.
- Extract new  sensorLocations.txt from .3dm drawing.

 ../buildDB

Bash script does

1/ Put files in raw_data/  from basestation `SensorRecord` into one file.

2/ Filter and convert module Id & J# to sensor ID.
    test file STILL USING test_data_2026-01-19.txt??
     ../utils/SensorDataReformat --infile='test_data_2026-01-19.txt' \
            --SensorHash='SensorIdHash.txt' --outfile='tmp/test_data_2026-01-19.csv'  --debug=True 

3/ Load readings and sensor information files into db.

    test file STILL USING THIS???
     ../utils/loadReadings --infile='test_data_2026-01-19.csv' --outdb='test_2026-01-19.db'

4/ ./runTests   MORE TESTS CAN BE ADDED HERE AND UPDATED.
