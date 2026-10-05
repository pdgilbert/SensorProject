#  sqlite3 target/SensorReadings.db  <../utils/setSensorTypes.sql

# Add  Sensors.type and Modules.type  with 0 for temperature only, 1 for temperature & Humid
# This uses LIKE '%floor%' in description but 
# a better way would be to put a field in ModuleIdHash.txt.

# PRAGMA table_info(Sensors);
# PRAGMA table_info(Modules);

ALTER TABLE Modules ADD COLUMN sensorType INTEGER default -1;
UPDATE Modules SET sensorType = 0 WHERE Modules.description LIKE '%floor%';
UPDATE Modules SET sensorType = 1 WHERE Modules.description NOT LIKE '%floor%';

ALTER TABLE Sensors ADD COLUMN sensorType INTEGER default -1;
UPDATE Sensors SET sensorType = 
    (SELECT Modules.sensorType FROM Modules WHERE Sensors.modID = Modules.modID );

# Consider doing some simple checks here, as done in some tests/.
# They need to be generic to work for different buildings.
