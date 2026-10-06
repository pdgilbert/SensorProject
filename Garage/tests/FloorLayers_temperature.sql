#  sqlite3 target/SensorReadings.db  <tests/FloorLayers_temperature.sql  >tmp/FloorLayers_temperature_out.txt
#  diff     tests/FloorLayers_temperature_out.txt_result  tmp/FloorLayers_temperature_out.txt

#  CLEAN UP OVERLAP WITH SUSPECT

#show table
PRAGMA table_info(Sensors);

SELECT printf('number of sensors %i', COUNT(*)) FROM Sensors;
SELECT printf('number of sensors with null modID: %i', COUNT(*)) FROM Sensors WHERE modID IS NULL ;
SELECT * FROM Sensors;

SELECT * FROM Sensors WHERE id = 'HG';  -- modID="M", socket="J8"
SELECT * FROM Sensors WHERE id = 'CD';  -- modID="I", socket="J1"
SELECT * FROM Sensors WHERE id = 'ID';  -- modID="I", socket="J5"

 
SELECT printf('earliest timestamp:') ;
SELECT min(datetime(timeStamp)) FROM sensorData ; -- 2026-04-01 01:56:26
SELECT printf('lastest  timestamp:') ;
SELECT max(datetime(timeStamp)) FROM sensorData ; -- 2026-09-10 14:55:38

#this also usually works:
#SELECT max(timeStamp) FROM sensorData ;

#SELECT min(date(timeStamp)) FROM SensorData; -- 2026-04-01
#SELECT max(date(timeStamp)) FROM SensorData; -- 2026-09-10  

SELECT printf('number of sensors %i', COUNT(*)) FROM Sensors;

SELECT printf('number of sensors with -12.6 < z < -12.4: %i', COUNT(*)) FROM Sensors 
                       WHERE (-12.6 < z ) AND (z < -12.4) ;
SELECT printf('sensors with   -12.6 < z < -12.4:'); 
SELECT * FROM Sensors  WHERE (-12.6 < z ) AND (z < -12.4) ;
  
SELECT printf('number of sensors with -15.0 < z < -10.0: %i', COUNT(*)) FROM Sensors 
                       WHERE (-15.0 < z ) AND (z < -10.0) ;
SELECT printf('sensors with   -15.0 < z < -10.0:'); 
SELECT * FROM Sensors  WHERE (-15.0 < z ) AND (z < -10.0) ;



SELECT COUNT(DISTINCT(sensorData.id)) FROM SensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE 40. > temperature ;    --134 
#  WHY ARE THESE DIFFERENT
SELECT COUNT(DISTINCT(sensorData.id)) FROM SensorData 
       WHERE 40. > temperature ;    --135



SELECT printf('Testing on time period 2026-08-03 00:00:00 to 2026-08-03 00:14:00');

SELECT  printf('total sensorData records %i',  COUNT(*)) FROM sensorData 
       WHERE (timeStamp > '2026-08-03 00:00:00')
         AND (timeStamp < '2026-08-03 00:14:00') ;   


SELECT  printf('sensorData records in (-15.0 < z < 0.0) %i',  COUNT(*)) FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-08-03 00:00:00')
         AND (timeStamp < '2026-08-03 00:14:00')  
         AND (-15.0 < z ) AND (z < 0.0) ;
SELECT printf('sensorData.id, timeStamp, temperature, x, y, z');
SELECT sensorData.id, timeStamp, temperature, x, y, z FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-08-03 00:00:00')
         AND (timeStamp < '2026-08-03 00:14:00') 
         AND (-15.0 < z ) AND (z < 0.0) ;


SELECT   printf('sensorData records with z = -12.5 : %i',  COUNT(*)) FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-08-03 00:00:00')
         AND (timeStamp < '2026-08-03 00:14:00') 
         AND (-12.6 < z ) AND (z < -12.4) ;
SELECT printf('sensorData.id, timeStamp, temperature, x, y, z');
SELECT sensorData.id, timeStamp, temperature, x, y, z FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-08-03 00:00:00')
         AND (timeStamp < '2026-08-03 00:14:00') 
         AND (-12.6 < z ) AND (z < -12.4) ;


SELECT  printf('sensorData records with z = -10.125 : %i',  COUNT(*)) FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-08-03 00:00:00')
         AND (timeStamp < '2026-08-03 00:14:00') 
         AND (-10.13 < z ) AND (z < -10.12) ;
SELECT printf('sensorData.id, timeStamp, temperature, x, y, z');
SELECT sensorData.id, timeStamp, temperature, x, y, z FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-08-03 00:00:00')
         AND (timeStamp < '2026-08-03 00:14:00') 
         AND (-10.13 < z ) AND (z < -10.12) ;


SELECT printf('sensorData records with z = -3. : %i',   COUNT(*)) FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-08-03 00:00:00')
         AND (timeStamp < '2026-08-03 00:14:00') 
         AND (-3.1 < z ) AND (z < -2.9) ;
SELECT printf('sensorData.id, timeStamp, temperature, x, y, z');
SELECT sensorData.id, timeStamp, temperature, x, y, z FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-08-03 00:00:00')
         AND (timeStamp < '2026-08-03 00:14:00') 
         AND (-3.1 < z ) AND (z < -2.9) ;


