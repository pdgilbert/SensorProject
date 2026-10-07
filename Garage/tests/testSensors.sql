# These are mostly now in other files, but check and then remove this.

# Tests below check sensors. They need SensorData.
# Tests check floor sensors. They need SensorData.

# These test for failing sensors. 
# Known failures will be in the _result file so only new failures will give a diff.
# Tests which produce different results with a new dataset (like COUNT(*)) FROM SensorData)
# should be in sql_test0.sql and are commented out when shown below.

#  sqlite3 target/SensorReadings.db  <tests/testFloorSensors.sql  >tmp/testFloorSensors_out.txt
#  diff     tests/testFloorSensors_out.txt_result  tmp/testFloorSensors_out.txt


#.tables
#show table
PRAGMA table_info(Sensors);
PRAGMA table_info(Modules);
PRAGMA table_info(SensorData);

SELECT COUNT(DISTINCT(sensorData.id)) FROM SensorData;  -- NEED TO CHECK, 108 (or 92) VS 165


SELECT min(date(timeStamp)) FROM SensorData; -- 2026-04-01
SELECT max(date(timeStamp)) FROM SensorData; -- 2026-09-10  
SELECT min(datetime(timeStamp)) FROM SensorData; -- 2026-04-01 01:56:26
SELECT max(datetime(timeStamp)) FROM SensorData; -- 2026-09-10 14:55:38
SELECT COUNT(*) FROM SensorData WHERE timeStamp IS NULL ; -- 0
SELECT COUNT(*) FROM SensorData WHERE timeStamp IS ' ' ; -- 0

SELECT * FROM SensorData ORDER BY timestamp DESC LIMIT 1;
SELECT * FROM SensorData ORDER BY timestamp ASC  LIMIT 1;
-- next is useful if timestamps are bad
SELECT printf('first 10 timestamps:') ;
SELECT timestamp  FROM SensorData ORDER BY timestamp ASC  LIMIT 10;

# changed by newer data

# SELECT count(*) FROM SensorData ;
# SELECT count(*) FROM SensorData WHERE (datetime(timeStamp)  > '2026-07-12 20:50:0.0');
# SELECT count(*) FROM SensorData WHERE (datetime(timeStamp) <= '2026-07-12 20:50:0.0') ; 

# SELECT printf('total number of sensor readings %i', COUNT(*)) FROM SensorData;  
# SELECT count(*) FROM SensorData
#          WHERE (datetime(timeStamp) >= '2026-07-12 20:50:0.0')
#          AND   (datetime(timeStamp) <= '2026-07-12 21:08:0.0') ; -- 206
# SELECT count(*) FROM SensorData
#          WHERE (timeStamp >= '2026-07-12 20:50:0.0')
#          AND   (timeStamp <= '2026-07-12 21:08:0.0') ; -- 206
# SELECT count(DISTINCT(sensorData.id)) FROM SensorData
#         WHERE (timeStamp >= '2026-07-12 20:50:0.0')
#         AND   (timeStamp <= '2026-07-12 21:08:0.0') ; -- 119

# these are historic, so will not change when data is added, but will change if filtered, eg hourly
# SELECT count(*) FROM SensorData WHERE (timeStamp <= '2026-06-08 21:08:00.47') ; -- 2418698
# SELECT count(*) FROM SensorData WHERE (timeStamp > '2026-06-08 21:08:00.47') ; -- 57787
# SELECT count(*) FROM SensorData WHERE (timeStamp > '2026-07-15 00:00:0.0') ; -- 16
# SELECT count(*) FROM SensorData
#          WHERE (timeStamp < '2026-07-12 20:50:0.0')
#          OR    (timeStamp > '2026-07-12 21:08:0.0') ; -- 2476485


# TEMPERATURE ABOVE 40 C IS PROBABLY DEFECTIVE AND NEEDS SOCKET CONNECTION CHECKED.
#   but there were some pretty hot days

# early data had several unconnected sensors.
# SELECT DISTINCT(sensorData.id) FROM SensorData 
#     INNER JOIN Sensors ON sensorData.id = Sensors.id  
#        WHERE 40. < temperature;


# All sensors connected and some fault sensors removed by '2026-07-04 00:00:0.0'  NOT
# Some empty results below were used to isolate faulty sensors
SELECT count(DISTINCT(sensorData.id)) FROM SensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE 40. < temperature
       AND   (timeStamp > '2026-09-01 00:00:0.0') ;  -- some

SELECT DISTINCT(Sensors.id) FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE 40. < temperature
       AND   (timeStamp > '2026-07-04 00:00:0.0') ; 

#SELECT Sensors.id, Sensors.modID, Sensors.socket, sensorData.temperature FROM Sensors 
#    INNER JOIN sensorData ON sensorData.id = Sensors.id  
#       WHERE 40. < temperature
#       AND   (timeStamp > '2026-07-04 00:00:0.0') ; 

SELECT Sensors.id, Sensors.modID, Sensors.socket, sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE 40. < temperature 
       AND   (timeStamp > '2026-07-04 00:00:0.0')
       AND Sensors.modID == "A" ;  

SELECT description  FROM Modules WHERE modID = "A" ; -- Floor...


SELECT Sensors.id, Sensors.modID, Sensors.socket, sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE 40. < temperature 
       AND   (timeStamp > '2026-07-15 00:00:0.0') 
       AND Sensors.modID == "C" ;  -- empty
SELECT description  FROM Modules WHERE modID = "C" ; -- Floor...

SELECT Sensors.id, Sensors.modID, Sensors.socket, sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE 40. < temperature 
       AND   (timeStamp > '2026-07-15 00:00:0.0') 
       AND Sensors.modID == "F" ; 
SELECT description  FROM Modules WHERE modID = "F" ; -- Floor...

SELECT Sensors.id, Sensors.modID, Sensors.socket, sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE 40. < temperature 
       AND   (timeStamp > '2026-07-15 00:00:0.0') 
       AND Sensors.modID == "I" ;  -- empty
SELECT description  FROM Modules WHERE modID = "I" ; -- Floor...


SELECT count(DISTINCT(Sensors.id)) FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE  Sensors.modID == "A"
       AND   (timeStamp > '2026-07-15 00:00:0.0') ; 


# TEMPERATURE below -30 C would need to be investigated.

# changed by newer data
# SELECT COUNT(DISTINCT(sensorData.id)) FROM SensorData 
#     INNER JOIN Sensors ON sensorData.id = Sensors.id  
#        WHERE -4. > temperature ;  -- 92

#  INVESTIGATE FAULTY READINGS
SELECT Sensors.id, Sensors.modID, Sensors.socket, sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE -30. > temperature ;

#  WHAT IS THIS
#SELECT count(Sensors.id) FROM Sensors, sensorData WHERE instr(Sensors.id, sensorData.id) > 0;


# REFINE BELOW     ALSO CHECK  DEFECTIVE WALL SENSORS


SELECT sensorData.id, timeStamp, temperature, x, y, z FROM sensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE (timeStamp > '2026-01-03 00:12:00')
         AND (timeStamp < '2026-01-03 00:14:00') 
         AND (-15.0 < z ) AND (z < 0.0) ;


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




# TEMPERATURE BELOW -10 C IN JULY IS PROBABLY DEFECTIVE AND NEEDS SOCKET CONNECTION CHECKED.

SELECT count(DISTINCT(sensorData.id)) FROM SensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE temperature < -10
       AND   (timeStamp > '2026-07-04 00:00:0.0') ;
SELECT count(sensorData.id) FROM SensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE temperature < -10
       AND   (timeStamp > '2026-07-04 00:00:0.0') ;

SELECT count(DISTINCT(sensorData.id)) FROM SensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE temperature < 5
       AND   (timeStamp > '2026-07-04 00:00:0.0') ;

SELECT count(sensorData.id) FROM SensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE temperature < 5
       AND   (timeStamp > '2026-07-04 00:00:0.0') ;

SELECT timeStamp, Sensors.id, Sensors.modID, Sensors.socket, sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE temperature < 3 
       AND   (timeStamp > '2026-07-04 00:00:0.0');


# Temperature of all slab sensors for 20 min  CONSTAINS SOME OUTSIDE

SELECT printf('number of sensor in slab: %i', COUNT(*)) FROM Sensors 
       WHERE (-10. < z ) AND (z <= 0.0) ; -- 91

#SELECT COUNT(*) FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE (-2. < z ) AND (z <= 0.0)  
       AND   (timeStamp > '2026-07-04 00:00:0.0')
       AND   (timeStamp < '2026-07-04 00:20:0.0');


SELECT timeStamp, Sensors.id,  sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE (-10. < z ) AND (z <= 0.0)  
       AND   (timeStamp > '2026-07-04 00:00:0.0')
       AND   (timeStamp < '2026-07-04 00:20:0.0');

SELECT timeStamp, Sensors.id,  sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE (-2. < z ) AND (z <= 0.0)  
       AND   (timeStamp > '2026-07-04 00:00:0.0')
       AND   (timeStamp < '2026-07-04 00:20:0.0');

SELECT timeStamp, Sensors.id,  sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE (-1. < z ) AND (z <= 0.0)  
       AND   (timeStamp > '2026-09-05 12:00:0.0')
       AND   (timeStamp < '2026-09-05 12:20:0.0');
SELECT timeStamp, Sensors.id,  sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE (-10. < z ) AND (z <= 1.0)  
       AND   (timeStamp > '2026-09-05 12:00:0.0')
       AND   (timeStamp < '2026-09-05 12:20:0.0');
