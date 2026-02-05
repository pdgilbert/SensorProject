#  sqlite3 SensorReadings_2026-01-19.db  <tests/sql_test2.sql  >tmp/sql_test2_out.txt
#  diff     tests/sql_test2_out.txt_result  tmp/sql_test2_out.txt

#print("database: ", dbName) 
#.databases

SELECT  printf('COUNT(*) %i',  COUNT(*)) FROM sensorData 
       WHERE (timeStamp > '2026-01-03 00:12:00')
         AND (timeStamp < '2026-01-03 00:14:00') ;


SELECT printf('COUNT(*) %i', COUNT(*)) FROM Sensors;
   

SELECT sensorData.id, timeStamp, temperature, x, y, z FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-01-03 00:12:00')
         AND (timeStamp < '2026-01-03 00:14:00') 
         AND (-15.0 < z ) AND (z < 0.0) ;

SELECT printf('z < -10.0 COUNT(*) %i',  COUNT(*))  FROM Sensors 
       WHERE  (-15.0 < z ) AND (z < -10.0) ;

SELECT   printf('z = -12.5 : %i',  COUNT(DISTINCT(sensorData.id))) FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-01-01 00:12:00')
         AND (timeStamp < '2026-01-03 00:14:00') 
         AND (-12.6 < z ) AND (z < -12.4) ;

SELECT  printf('z = -10.125 : %i',  COUNT(DISTINCT(sensorData.id))) FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-01-01 00:12:00')
         AND (timeStamp < '2026-01-03 00:14:00') 
         AND (-10.13 < z ) AND (z < -10.12) ;

SELECT printf('z = -3. : %i',   COUNT(DISTINCT(sensorData.id))) FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-01-01 00:12:00')
         AND (timeStamp < '2026-01-03 00:14:00') 
         AND (-3.1 < z ) AND (z < -2.9) ;

