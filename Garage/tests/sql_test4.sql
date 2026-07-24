#  sqlite3 SensorReadings.db  <tests/sql_test4.sql  >tmp/sql_test4_out.txt
#  diff     tests/sql_test4_out.txt_result  tmp/sql_test4_out.txt


#.tables
#show table
PRAGMA table_info(Sensors);
PRAGMA table_info(Modules);
PRAGMA table_info(SensorData);

SELECT printf('COUNT(*) %i', COUNT(*)) FROM Modules;  -- 12
SELECT printf('COUNT(*) %i', COUNT(*)) FROM Sensors;  -- 165
SELECT printf('COUNT(*) %i', COUNT(*)) FROM SensorData;  
SELECT COUNT(DISTINCT(sensorData.id)) FROM SensorData;  -- NEED TO CHECK, 108 (or 92) VS 165

SELECT description  FROM Modules WHERE description LIKE '%S%corner%';  -- F
SELECT description  FROM Modules WHERE description LIKE '%SW%';  -- G, L, M
SELECT description  FROM Modules WHERE description LIKE '%floor%';

SELECT count(*) FROM Sensors WHERE modID="G"; -- 16
SELECT * FROM Sensors WHERE modID="G";

SELECT COUNT(*) FROM Sensors WHERE modID IS NULL ;
SELECT COUNT(*) FROM Sensors WHERE modID IS NOT NULL ;
 
SELECT min(z) FROM Sensors; --  -12.5
 
SELECT printf('number of sensor below foam: %i', COUNT(*)) FROM Sensors 
       WHERE (-12.6 < z ) AND (z <= -12.4) ;
 
SELECT printf('number of sensor just above lowest foam: %i', COUNT(*)) FROM Sensors 
       WHERE (-12.4 < z ) AND (z <= -10.) ;

SELECT printf('number of sensor in slab: %i', COUNT(*)) FROM Sensors 
       WHERE (-10. < z ) AND (z <= 0.0) ;


SELECT count(*) FROM SensorData;  -- B gives 772  ??

SELECT min(timeStamp) FROM SensorData; -- 2026-03-31 15:51:51.246578    CHECK 4 ? in everything

SELECT max(timeStamp) FROM SensorData; -- 2026-04-01  ?? SHOULD HAVE JULY ??  FILTER PROBLEM <<<<<<<<<<<<<<


SELECT count(*) FROM SensorData;

SELECT count(*) FROM SensorData WHERE (timeStamp <= '2026-06-08 21:08:00.47') ;

SELECT count(*) FROM SensorData WHERE (timeStamp > '2026-06-08 21:08:00.47') ;

SELECT count(*) FROM SensorData WHERE (timeStamp > '2026-07-15 00:00:0.0') ;

SELECT count(*) FROM SensorData
         WHERE (timeStamp >= '2026-07-12 20:50:0.0')
         AND   (timeStamp <= '2026-07-12 21:08:0.0') ;

SELECT count(*) FROM SensorData
         WHERE (timeStamp < '2026-07-12 20:50:0.0')
         OR    (timeStamp > '2026-07-12 21:08:0.0') ;


SELECT count(DISTINCT(sensorData.id)) FROM SensorData
         WHERE (timeStamp >= '2026-07-12 20:50:0.0')
         AND   (timeStamp <= '2026-07-12 21:08:0.0') ;

SELECT id, timeStamp FROM SensorData
         WHERE (timeStamp >= '2026-07-12 20:50:0.0')
         AND   (timeStamp <= '2026-07-12 21:08:0.0') ;
  

# TEMPERATURE ABOVE 40 C IS PROBABLY DEFECTIVE AND NEEDS SOCKET CONNECTION CHECKED.

SELECT DISTINCT(sensorData.id) FROM SensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE 40. < temperature;

SELECT count(DISTINCT(sensorData.id)) FROM SensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE 40. < temperature
       AND   (timeStamp > '2026-07-04 00:00:0.0') ;

SELECT DISTINCT(Sensors.id) FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE 40. < temperature
       AND   (timeStamp > '2026-07-04 00:00:0.0') ;

SELECT Sensors.id, Sensors.modID, Sensors.socket, sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE 40. < temperature
       AND   (timeStamp > '2026-07-04 00:00:0.0') ;

SELECT Sensors.id, Sensors.modID, Sensors.socket, sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE 40. < temperature 
       AND   (timeStamp > '2026-07-04 00:00:0.0')
       AND Sensors.modID == "A" ;

SELECT Sensors.id, Sensors.modID, Sensors.socket, sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE 40. < temperature 
       AND   (timeStamp > '2026-07-15 00:00:0.0') 
       AND Sensors.modID == "A" ;
SELECT description  FROM Modules WHERE modID = "A" ;

SELECT Sensors.id, Sensors.modID, Sensors.socket, sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE 40. < temperature 
       AND   (timeStamp > '2026-07-15 00:00:0.0') 
       AND Sensors.modID == "C" ;
SELECT description  FROM Modules WHERE modID = "C" ;

SELECT Sensors.id, Sensors.modID, Sensors.socket, sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE 40. < temperature 
       AND   (timeStamp > '2026-07-15 00:00:0.0') 
       AND Sensors.modID == "F" ;
SELECT description  FROM Modules WHERE modID = "F" ;

SELECT Sensors.id, Sensors.modID, Sensors.socket, sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE 40. < temperature 
       AND   (timeStamp > '2026-07-15 00:00:0.0') 
       AND Sensors.modID == "I" ;
SELECT description  FROM Modules WHERE modID = "I" ;




SELECT count(DISTINCT(Sensors.id)) FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE 40. < temperature 
       AND Sensors.modID == "A"
       AND   (timeStamp > '2026-07-15 00:00:0.0') ;

SELECT count(DISTINCT(Sensors.id)) FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE  Sensors.modID == "A"
       AND   (timeStamp > '2026-07-15 00:00:0.0') ;


# TEMPERATURE below -30 C would need to be investigated.
SELECT COUNT(DISTINCT(sensorData.id)) FROM SensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE -4. > temperature ;

SELECT Sensors.id, Sensors.modID, Sensors.socket, sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE -30. > temperature ;


#SELECT count(Sensors.id) FROM Sensors, sensorData WHERE instr(Sensors.id, sensorData.id) > 0;





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

# sensors suspect because too hot  THIS NEEDS WORK
SELECT temperature, timeStamp, sensorData.id, modID, socket  FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-01-01 00:12:00')
         AND (timeStamp < '2026-01-03 00:14:00') 
         AND (-3.1 < z ) AND (z < -2.9)
         AND (temperature > 45.0) ;
