#  sqlite3 SensorReadings.db  <tests/FloorLayers_count.sql  >tmp/FloorLayers_count_out.txt
#  diff     tests/FloorLayers_count_out.txt_result  tmp/FloorLayers_count_out.txt

#print("database: ", dbName) 
#.databases

SELECT printf('number of sensors %i', COUNT(*)) FROM Sensors;

SELECT printf('sensors with z < -10.0  %i',  COUNT(*))  FROM Sensors 
       WHERE  (-15.0 < z ) AND (z < -10.0) ;

SELECT printf('Testing on time period 2026-08-03 00:12:00 to 2026-08-03 00:14:00');

SELECT  printf('total sensorData records %i',  COUNT(*)) FROM sensorData 
       WHERE (timeStamp > '2026-08-03 00:12:00')
         AND (timeStamp < '2026-08-03 00:14:00') ;   

SELECT printf('sensorData.id, timeStamp, temperature, x, y, z');
SELECT sensorData.id, timeStamp, temperature, x, y, z FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-08-03 00:12:00')
         AND (timeStamp < '2026-08-03 00:14:00') 
         AND (-15.0 < z ) AND (z < 0.0) ;



SELECT printf('Testing on time period 2026-01-01 00:12:00 to 2026-08-03 00:14:00');

SELECT   printf('sensors with z = -12.5 : %i',  COUNT(DISTINCT(sensorData.id))) FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-01-01 00:12:00')
         AND (timeStamp < '2026-08-03 00:14:00') 
         AND (-12.6 < z ) AND (z < -12.4) ;

SELECT  printf('sensors with z = -10.125 : %i',  COUNT(DISTINCT(sensorData.id))) FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-01-01 00:12:00')
         AND (timeStamp < '2026-08-03 00:14:00') 
         AND (-10.13 < z ) AND (z < -10.12) ;

SELECT printf('sensors with z = -3. : %i',   COUNT(DISTINCT(sensorData.id))) FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-01-01 00:12:00')
         AND (timeStamp < '2026-08-03 00:14:00') 
         AND (-3.1 < z ) AND (z < -2.9) ;

