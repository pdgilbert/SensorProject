#  sqlite3 SensorReadings_2026-01-19.db  <tests/test1.sql  >tmp/sql_test1_out.txt
#  diff     tests/sql_test1_out.txt_result  tmp/sql_test1_out.txt

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
    INNER JOIN sensorLocation ON sensorData.id = sensorLocation.id  
       WHERE (timeStamp > '2026-01-03 00:12:00')
         AND (timeStamp < '2026-01-03 00:14:00') ;
    

SELECT printf('sensorData.id, timeStamp, temperature, x, y, z');

SELECT sensorData.id, timeStamp, temperature, x, y, z FROM sensorData 
    INNER JOIN sensorLocation ON sensorData.id = sensorLocation.id  
       WHERE (timeStamp > '2026-01-03 00:12:00')
         AND (timeStamp < '2026-01-03 00:14:00') ;

SELECT printf('min temperature %.2f', MIN(temperature)) FROM sensorData 
       WHERE (timeStamp > '2026-01-03 00:12:00')
         AND (timeStamp < '2026-01-03 00:14:00') ;

SELECT printf('max temperature %.2f', MAX(temperature)) FROM sensorData 
       WHERE (timeStamp > '2026-01-03 00:12:00')
         AND (timeStamp < '2026-01-03 00:14:00') ;

