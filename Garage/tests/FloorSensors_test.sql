# Tests check floor sensors. They need SensorData.
# See also testSensors.sql and testWallSensors.sql.

--  NOT YET RESRICTED TO FLOOR ONLY
--  NEED TO CHECK/FIX some  tests below

# These test for failing sensors. 
# Known failures will be in the _result file so only new failures will give a diff.
# Tests which produce different results with a new dataset (like COUNT(*)) FROM SensorData)
# should be in sql_test0.sql and are commented out when shown below.

#  sqlite3 target/SensorReadings.db  <tests/testFloorSensors.sql  >tmp/testFloorSensors_out.txt
#  diff     tests/testFloorSensors_out.txt_result  tmp/testFloorSensors_out.txt


#.tables
# show table
# PRAGMA table_info(Sensors);
# PRAGMA table_info(Modules);
# PRAGMA table_info(SensorData);

#There is now a field to identify sensorType, which should compare with this.
SELECT modID, description  FROM Modules WHERE description LIKE '%floor%';

-- NEED TO CHECK THESE
SELECT COUNT(*) FROM Modules WHERE sensorType IS 0;
SELECT COUNT(*) FROM Modules WHERE sensorType IS 1;
SELECT COUNT(*) FROM Modules WHERE sensorType IN (0, 1);
SELECT COUNT(*) FROM Modules WHERE sensorType NOT IN (0, 1);
SELECT COUNT(*) FROM Modules;

SELECT COUNT(*) FROM Sensors;
SELECT COUNT(*) FROM Sensors WHERE sensorType IS 0;
SELECT COUNT(*) FROM Sensors WHERE sensorType IS 1;
SELECT COUNT(*) FROM Sensors WHERE sensorType IN (0, 1);
SELECT COUNT(*) FROM Sensors WHERE sensorType NOT IN (0, 1);
SELECT COUNT(*) FROM Sensors WHERE sensorType IS NULL;  -- 8

# These should have sensorType rather than NULL
SELECT id, modID FROM Sensors WHERE sensorType IS NULL;  
SELECT COUNT(Sensors.id) FROM Sensors WHERE Sensors.modID = 'XX';


# These should be tested equal to above
SELECT COUNT(Sensors.id) FROM Sensors
    INNER JOIN Modules ON Sensors.modID = Modules.modID  
      WHERE Modules.sensorType IS 0;

SELECT COUNT(Sensors.id) FROM Sensors
    INNER JOIN Modules ON Sensors.modID = Modules.modID  
      WHERE Modules.sensorType IS 1;

SELECT COUNT(Sensors.id) FROM Sensors
    INNER JOIN Modules ON Sensors.modID = Modules.modID  
      WHERE Modules.sensorType IN (0, 1);

#above is 157 and next is 0, because of NULL XX. Total should be 165.

SELECT COUNT(Sensors.id) FROM Sensors
    INNER JOIN Modules ON Sensors.modID = Modules.modID  
      WHERE Modules.sensorType NOT IN (0, 1);

#this is also 157.   165 - 157  is sensors that have been removed  NULL XX.
SELECT COUNT(Sensors.id) FROM Sensors
    INNER JOIN Modules ON Sensors.modID = Modules.modID ;
 


SELECT COUNT(DISTINCT(sensorData.id)) FROM SensorData
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
      WHERE Sensors.sensorType IS 0;

# MAKE FOLLOWING SPECIFIC TO FLOOR, OR REMOVE

SELECT count(DISTINCT(sensorData.id)) FROM SensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE 40. < temperature
       AND   (timeStamp > '2026-09-01 00:00:0.0') ;  -- some

SELECT DISTINCT(Sensors.id) FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE 40. < temperature
       AND   (timeStamp > '2026-07-04 00:00:0.0') ;  -- empty

# Need to constain more or output file is very big
#SELECT Sensors.id, Sensors.modID, Sensors.socket, sensorData.temperature FROM Sensors 
#    INNER JOIN sensorData ON sensorData.id = Sensors.id  
#       WHERE 40. < temperature
#       AND   (timeStamp > '2026-07-04 00:00:0.0') ;
#
#SELECT Sensors.id, Sensors.modID, Sensors.socket, sensorData.temperature FROM Sensors 
#    INNER JOIN sensorData ON sensorData.id = Sensors.id  
#       WHERE 40. < temperature 
#       AND   (timeStamp > '2026-07-04 00:00:0.0')
#       AND Sensors.modID == "A" ;  

SELECT description  FROM Modules WHERE modID = "A" ; -- Floor...
SELECT description  FROM Modules WHERE modID = "C" ; -- Floor...

# REVIEW BELOW

SELECT COUNT(*) FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE 40. < temperature 
       AND   (timeStamp > '2026-07-15 00:00:0.0') 
       AND Sensors.modID == "C" ; 

SELECT COUNT(*) FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE 55. < temperature 
       AND   (timeStamp > '2026-07-15 00:00:0.0') 
       AND Sensors.modID == "C" 
       AND Sensors.id != "CG" ; 

SELECT Sensors.id, Sensors.modID, Sensors.socket, sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE 55. < temperature 
       AND   (timeStamp > '2026-07-15 00:00:0.0') 
       AND Sensors.modID == "C" 
       AND Sensors.id != "CG" ; 

#SELECT Sensors.id, Sensors.modID, Sensors.socket, sensorData.temperature FROM Sensors 
#    INNER JOIN sensorData ON sensorData.id = Sensors.id  
#       WHERE 40. < temperature 
#       AND   (timeStamp > '2026-07-15 00:00:0.0') 
#       AND Sensors.modID == "F" ;  -- empty
SELECT COUNT(*) FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE 40. < temperature 
       AND   (timeStamp > '2026-07-15 00:00:0.0') 
       AND Sensors.modID == "F" ;  
SELECT description  FROM Modules WHERE modID = "F" ; -- Floor...

SELECT COUNT(*) FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE 40. < temperature 
       AND   (timeStamp > '2026-07-15 00:00:0.0') 
       AND Sensors.modID == "I" ; 
#SELECT Sensors.id, Sensors.modID, Sensors.socket, sensorData.temperature FROM Sensors 
#    INNER JOIN sensorData ON sensorData.id = Sensors.id  
#       WHERE 40. < temperature 
#       AND   (timeStamp > '2026-07-15 00:00:0.0') 
#       AND Sensors.modID == "I" ;
SELECT description  FROM Modules WHERE modID = "I" ; -- Floor...


# WHAT IS THIS AND WHY 0
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

SELECT printf('number of sensor below 0.0: %i', COUNT(*)) FROM Sensors 
       WHERE (z <= 0.0) ; -- 141

SELECT printf('number of sensor below 0.0 and above insulation: %i', COUNT(*)) FROM Sensors 
       WHERE (-10. < z ) AND (z <= 0.0) ; -- 91

SELECT  printf('number of sensor in slab: %i', COUNT(*)) FROM Sensors 
       WHERE (-2. < z ) AND (z <= 0.0); -- 17

# why is next 22 and previous 17
SELECT  printf('number of sensor in slab: %i', COUNT(*)) FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE (-2. < z ) AND (z <= 0.0)  
       AND   (timeStamp > '2026-07-04 00:00:0.0')
       AND   (timeStamp < '2026-07-04 00:20:0.0');


SELECT  COUNT(*) FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE (-10. < z ) AND (z <= 0.0)  
       AND   (timeStamp > '2026-07-04 00:00:0.0')
       AND   (timeStamp < '2026-07-04 00:20:0.0');
SELECT timeStamp, Sensors.id,  sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE (-10. < z ) AND (z <= 0.0)  
       AND   (timeStamp > '2026-07-04 00:00:0.0')
       AND   (timeStamp < '2026-07-04 00:20:0.0');

SELECT  COUNT(*) FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE (-2. < z ) AND (z <= 0.0)  
       AND   (timeStamp > '2026-07-04 00:00:0.0')
       AND   (timeStamp < '2026-07-04 00:20:0.0');
SELECT timeStamp, Sensors.id,  sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE (-2. < z ) AND (z <= 0.0)  
       AND   (timeStamp > '2026-07-04 00:00:0.0')
       AND   (timeStamp < '2026-07-04 00:20:0.0');

SELECT COUNT(*) FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE (-1. < z ) AND (z <= 0.0)  
       AND   (timeStamp > '2026-09-05 12:00:0.0')
       AND   (timeStamp < '2026-09-05 12:20:0.0');
SELECT timeStamp, Sensors.id,  sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE (-1. < z ) AND (z <= 0.0)  
       AND   (timeStamp > '2026-09-05 12:00:0.0')
       AND   (timeStamp < '2026-09-05 12:20:0.0');

SELECT COUNT(*) FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE (-10. < z ) AND (z <= 1.0)  
       AND   (timeStamp > '2026-09-05 12:00:0.0')
       AND   (timeStamp < '2026-09-05 12:20:0.0');
SELECT timeStamp, Sensors.id,  sensorData.temperature FROM Sensors 
    INNER JOIN sensorData ON sensorData.id = Sensors.id  
       WHERE (-10. < z ) AND (z <= 1.0)  
       AND   (timeStamp > '2026-09-05 12:00:0.0')
       AND   (timeStamp < '2026-09-05 12:20:0.0');
