#  sqlite3 SensorReadings_2026-01-19.db  <tests/test3.sql  >tmp/sql_test3_out.txt
#  diff     tests/sql_test3_out.txt_result  tmp/sql_test3_out.txt

#print("database: ", dbName) 
#.databases
.sha3sum

PRAGMA table_info(Sensors);   #SHOW TABLE 

SELECT * FROM Sensors;
SELECT printf('COUNT(*) %i', COUNT(*)) FROM Sensors;
SELECT printf('COUNT(*) %i', COUNT(*)) FROM sensorData ;

SELECT COUNT(*) FROM Sensors WHERE modID IS NOT NULL ;
 
SELECT printf('COUNT(*) %i', COUNT(*)) FROM Sensors 
       WHERE (-12.6 < z ) AND (z < -12.4) ;
 
SELECT * FROM Sensors
       WHERE (-12.6 < z ) AND (z < -12.4) ;
  
SELECT COUNT(DISTINCT(sensorData.id)) FROM SensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE  Sensors.modID IS NOT NULL
       AND    40. < temperature ;
these are the same if modID has been set for all working sensors ?? hA ?
SELECT COUNT(DISTINCT(sensorData.id)) FROM SensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE  40. < temperature ;
   
SELECT DISTINCT(sensorData.id) FROM SensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE 40. < temperature ;

SELECT COUNT(DISTINCT(Sensors.id)) FROM SensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE 40. < sensorData.temperature ;

SELECT COUNT(DISTINCT(sensorData.id)) FROM SensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE 40. > temperature ;

SELECT COUNT(DISTINCT(Sensors.id, Sensors.modID)) FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE 40. < sensorData.temperature ;

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

# sensors suspect because too hot
SELECT temperature, timeStamp, sensorData.id,  FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-01-01 00:12:00')
         AND (timeStamp < '2026-01-03 00:14:00') 
         AND (-3.1 < z ) AND (z < -2.9) ;
