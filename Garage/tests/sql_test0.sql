#  sqlite3 SensorReadings_2026-01-19.db  <tests/sql_test3.sql  >tmp/sql_test3_out.txt
#  diff     tests/sql_test3_out.txt_result  tmp/sql_test3_out.txt

#print("database: ", dbName) 
#.databases
.sha3sum
#02bb911b737fc0bac8fffe8507affe363e9135cae4e87a6b2ee39192
#for SensorReadings_2026-01-19.db with raw_data to 2026-01-19

SELECT printf('Sensors COUNT(*) %i', COUNT(*)) FROM Sensors;
SELECT printf('sensorData COUNT(*) %i', COUNT(*)) FROM sensorData ;

SELECT DISTINCT(sensorData.id) FROM SensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE 40. < temperature ;

SELECT COUNT(DISTINCT(sensorData.id)) FROM SensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE  Sensors.modID IS NOT NULL
       AND    40. < temperature ;

#these are the same if modID has been set for all working sensors ?? hA ? CHECK
SELECT COUNT(DISTINCT(sensorData.id)) FROM SensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE  40. < temperature ;
   

SELECT COUNT(DISTINCT(Sensors.id)) FROM SensorData 
    INNER JOIN Sensors ON sensorData.id = Sensors.id  
       WHERE 40. < sensorData.temperature ;
