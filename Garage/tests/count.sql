#  sqlite3 target/SensorReadings.db  <tests/count.sql  >tmp/count_out.txt
#  diff     tests/count_out.txt_result  tmp/count_out.txt

# These results will depend on which and how many basestations are in the data
# old tests using
#       WHERE (timeStamp > '2026-01-03 00:12:00')
#         AND (timeStamp < '2026-01-03 00:14:00') ;
#  sqlite3 target/SensorReadings_2026-01-19.db  <tests/count.sql  >tmp/sql_test1_out.txt
#  diff     tests/sql_test1_out.txt_result  tmp/sql_test1_out.txt
#  diff     tests/sql_test1_out.txt_result  tmp/count_out.txt

# count records in a know historic time frame

#print("database: ", dbName) 
#.databases

SELECT printf('Testing on time period 2026-08-03 00:12:00 to 2026-08-03 00:14:00');

SELECT  printf('total sensorData records %i',  COUNT(*)) FROM sensorData 
       WHERE (timeStamp > '2026-08-03 00:12:00')
         AND (timeStamp < '2026-08-03 00:14:00') ;

SELECT printf('distinct timeStamps ) %.i',  COUNT(DISTINCT timeStamp )) FROM sensorData 
       WHERE (timeStamp > '2026-08-03 00:12:00')
         AND (timeStamp < '2026-08-03 00:14:00') ;

SELECT printf('distinct ids  %i',  COUNT(DISTINCT id )) FROM sensorData 
       WHERE (timeStamp > '2026-08-03 00:12:00')
         AND (timeStamp < '2026-08-03 00:14:00') ;


SELECT printf('sensorData.id, timeStamp, temperature, x, y, z');
SELECT sensorData.id, timeStamp, temperature, x, y, z FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-08-03 00:12:00')
         AND (timeStamp < '2026-08-03 00:14:00') ;

SELECT printf('min temperature %.2f', MIN(temperature)) FROM sensorData 
       WHERE (timeStamp > '2026-08-03 00:12:00')
         AND (timeStamp < '2026-08-03 00:14:00') ;

SELECT printf('max temperature %.2f', MAX(temperature)) FROM sensorData 
       WHERE (timeStamp > '2026-08-03 00:12:00')
         AND (timeStamp < '2026-08-03 00:14:00') ;

