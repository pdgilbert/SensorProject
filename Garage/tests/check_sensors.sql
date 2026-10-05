#  sqlite3 target/SensorReadings.db  <tests/check_sensors.sql  >tmp/check_sensors_out.txt
#  diff    tests/check_sensors_out.txt_result  tmp/check_sensors_out.txt

# It should be possible to run these with only tables Modules and SensorData.
# The Sensors table with locations is not needed (so 3dm file is not needed)

#.tables
#show table
PRAGMA table_info(SensorData);
PRAGMA table_info(Modules);

SELECT printf('COUNT(*) %i', COUNT(*)) FROM SensorData;

# THIS IS MISSING SOME? TH8 MODULES. CHECK NEWER DATA

SELECT COUNT(DISTINCT(sensorData.id)) FROM SensorData;  -- NEED TO CHECK, 108 (or 92) VS 165
SELECT DISTINCT(sensorData.id) FROM SensorData; 
SELECT printf('COUNT(*) %i', COUNT(*)) FROM Modules;  -- 12

SELECT count(*) FROM SensorData
         WHERE (timeStamp >= '2026-07-12 20:50:0.0')
         AND   (timeStamp <= '2026-07-12 21:08:0.0') ;

SELECT count(*) FROM SensorData WHERE (timeStamp >= '2026-07-12 20:50:0.0');
SELECT count(*) FROM SensorData WHERE (timeStamp <= '2026-07-12 21:08:0.0') ;


#  Check failing or missing sensors (Note  BR DQ removed ~Aug 1, 2026)

-- THIS SEEMS TO BE A BIT SENSITIVE TO THE MODULE TEMPERATURE
-- -24.8 indicates no sensor in t16 modules (NTC temperature only sensors) 
-- -25.7 in August
SELECT count(DISTINCT(sensorData.id)) FROM SensorData ;

SELECT count(DISTINCT(sensorData.id)) FROM SensorData WHERE temperature  < -24;
SELECT count(DISTINCT(sensorData.id)) FROM SensorData WHERE temperature == -24.8;
SELECT DISTINCT(sensorData.id) FROM SensorData WHERE temperature == -24.8; -- BR DQ

SELECT count(timeStamp) FROM SensorData WHERE id == "BR" AND temperature != -24.8;
SELECT count(timeStamp) FROM SensorData WHERE id == "BR" AND temperature == -24.8;

SELECT count(timeStamp) FROM SensorData WHERE id == "DQ" AND temperature != -24.8;
SELECT count(timeStamp) FROM SensorData WHERE id == "DQ" AND temperature == -24.8;

SELECT count(timeStamp) FROM SensorData WHERE temperature == -24.8 AND
              NOT (id == "BR" OR id == "DQ");

# needs work
# needs timestamp constaint or result will change
# needs Sensors
#SELECT count(timeStamp) FROM SensorData
#    INNER JOIN Sensors ON sensorData.id = Sensors.id WHERE modID == "K";

SELECT count(timeStamp) FROM SensorData WHERE id = "ML"; -- in module K
SELECT count(timeStamp) FROM SensorData WHERE id = "MN"; -- in module L

#SELECT max(temperature) FROM SensorData WHERE modID == "K";
#SELECT count(timeStamp) FROM SensorData WHERE modID == "L";
#SELECT max(temperature) FROM SensorData WHERE modID == "L";
#SELECT count(timeStamp) FROM SensorData WHERE modID == "L";
#SELECT max(temperature) FROM SensorData WHERE modID == "L";


SELECT count(DISTINCT(sensorData.id)) FROM SensorData WHERE temperature < -10;

SELECT count(DISTINCT(sensorData.id)) FROM SensorData 
       WHERE temperature < -10
       AND   (timeStamp > '2026-07-04 00:00:0.0') ;

# missing sensors give ??
SELECT count(DISTINCT(sensorData.id)) FROM SensorData 
       WHERE temperature < -24
       AND   (timeStamp > '2026-07-04 00:00:0.0') ;

# needs Sensors
#SELECT count(DISTINCT(sensorData.id)) FROM SensorData 
#    INNER JOIN Sensors ON sensorData.id = Sensors.id  
#       WHERE temperature < 5
#       AND   (timeStamp > '2026-07-04 00:00:0.0') ;
#
#SELECT Sensors.id, Sensors.modID, Sensors.socket, sensorData.temperature FROM Sensors 
#    INNER JOIN sensorData ON sensorData.id = Sensors.id  
#       WHERE temperature < 5 
#       AND   (timeStamp > '2026-07-04 00:00:0.0');
