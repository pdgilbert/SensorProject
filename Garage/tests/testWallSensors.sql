# Tests below are to check wall temperature and humidity sensors. They need SensorData.

# NOT YET RESRICTED TO WALL ONLY
# WORK IN PROGRESS. NOT YET DOING MUCH. COMPARE testFloor Sensors.sql

# These test for failing sensors. 
# Known failures will be in the _result file so only new failures will give a diff.
# Tests which produce different results with a new dataset (like COUNT(*)) FROM SensorData)
# should be in sql_test0.sql and are commented out when shown below.

#  sqlite3 target/SensorReadings.db  <tests/testWallSensors.sql  >tmp/testWallSensors_out.txt
#  diff     tests/testWallSensors_out.txt_result  tmp/testWallSensors_out.txt


#.tables
#show table
PRAGMA table_info(Sensors);
PRAGMA table_info(Modules);
PRAGMA table_info(SensorData);

SELECT COUNT(DISTINCT(sensorData.id)) FROM SensorData; 


SELECT min(date(timeStamp)) FROM SensorData; -- 2026-04-01
SELECT max(date(timeStamp)) FROM SensorData; -- 2026-09-10  
SELECT min(datetime(timeStamp)) FROM SensorData; -- 2026-04-01 01:56:26
SELECT max(datetime(timeStamp)) FROM SensorData; -- 2026-09-10 14:55:38
SELECT COUNT(*) FROM SensorData WHERE timeStamp IS NULL ; -- 0
SELECT COUNT(*) FROM SensorData WHERE timeStamp IS ' ' ; -- 0

SELECT * FROM SensorData ORDER BY timestamp DESC LIMIT 1;
SELECT * FROM SensorData ORDER BY timestamp ASC  LIMIT 1;
# next is useful if timestamps are bad
SELECT printf('timestamp :%i:', timestamp)  FROM SensorData ORDER BY timestamp ASC  LIMIT 10;

