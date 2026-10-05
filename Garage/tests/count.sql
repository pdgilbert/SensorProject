#  sqlite3 target/SensorReadings.db  <tests/count.sql  >tmp/count_out.txt
#  diff     tests/count_out.txt_result  tmp/count_out.txt
#  diff     tests/sql_test1_out.txt_result  tmp/count_out.txt

# old tests using
#  sqlite3 target/SensorReadings_2026-01-19.db  <tests/count.sql  >tmp/sql_test1_out.txt
#  diff     tests/sql_test1_out.txt_result  tmp/sql_test1_out.txt

# count records in a know historic time frame

#print("database: ", dbName) 
#.databases

SELECT  printf('COUNT(*) %i',  COUNT(*)) FROM sensorData 
       WHERE (timeStamp > '2026-01-03 00:12:00')
         AND (timeStamp < '2026-01-03 00:14:00') ;

SELECT printf('COUNT(DISTINCT timeStamp ) %.i',  COUNT(DISTINCT timeStamp )) FROM sensorData 
       WHERE (timeStamp > '2026-01-03 00:12:00')
         AND (timeStamp < '2026-01-03 00:14:00') ;

SELECT printf('COUNT(DISTINCT id ) %i',  COUNT(DISTINCT id )) FROM sensorData 
       WHERE (timeStamp > '2026-01-03 00:12:00')
         AND (timeStamp < '2026-01-03 00:14:00') ;

SELECT printf('COUNT(*) %i', COUNT(*)) FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-01-03 00:12:00')
         AND (timeStamp < '2026-01-03 00:14:00') ;
    

SELECT printf('sensorData.id, timeStamp, temperature, x, y, z');

SELECT sensorData.id, timeStamp, temperature, x, y, z FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-01-03 00:12:00')
         AND (timeStamp < '2026-01-03 00:14:00') ;

SELECT printf('min temperature %.2f', MIN(temperature)) FROM sensorData 
       WHERE (timeStamp > '2026-01-03 00:12:00')
         AND (timeStamp < '2026-01-03 00:14:00') ;

SELECT printf('max temperature %.2f', MAX(temperature)) FROM sensorData 
       WHERE (timeStamp > '2026-01-03 00:12:00')
         AND (timeStamp < '2026-01-03 00:14:00') ;

