Data currently is from three recording basestations, so lots of duplication.
Duplicates are not exact because the time stamps created by different 
base stations differ very slightly. 
Also, errors in reception may occur on one base station and not on others.

Put everything in SQL db then we will see if it needs to be filtered to remove duplication.

1/ Edit SensorIdHash.txt as necessary for any new sensors installed.
    NEED TO ADD MORE MODULES TO SensorIdHash.txt

2/ Put all files from `SensorRecord` into one file: 
     rm tmp/All_data.txt   #if it exists
     cat raw_data/SensorRecordOuput*.txt >>tmp/All_data.txt  # or eg   tmp/All_data_2026-01-19.txt

3/ Filter and convert module Id & J# to sensor ID: In dir Garage do
     ../utils/SensorDataReformat  --SensorHash='SensorIdHash.txt'  \
         --infile='tmp/All_data.txt'  --outfile='tmp/All_data.csv' 

    test file STILL USING THIS???
     ../utils/SensorDataReformat --infile='test_data_2026-01-19.txt' \
            --SensorHash='SensorIdHash.txt' --outfile='tmp/test_data_2026-01-19.csv'  --debug=True 

4/ Load csv files into SQLite db:
     ../utils/loadReadings --infile='tmp/All_data.csv' --outdb='target/SensorReadings.db'

     ../utils/loadSensors  --sensorLocations='sensorLocations.txt' \
         --SensorIdHash='SensorIdHash.txt'  --outdb='target/SensorReadings.db'

    test file STILL USING THIS???
     ../utils/loadReadings --infile='test_data_2026-01-19.csv' --outdb='test_2026-01-19.db'


5/ ./runTests
