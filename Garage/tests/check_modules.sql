# Tests below are to check sensors modules and sensor locations.
# They do not require SensorData. (There is limited testing that can be done without data.)

#  sqlite3 target/SensorReadings.db  <tests/check_modules.sql  >tmp/check_modules_out.txt
#  diff     tests/check_modules_out.txt_result  tmp/check_modules_out.txt


#.tables
#show table
PRAGMA table_info(Sensors);
PRAGMA table_info(Modules);

SELECT printf('COUNT(*) %i', COUNT(*)) FROM Modules;  -- 12
SELECT modID, description FROM Modules; 

SELECT modID, description  FROM Modules WHERE modID = "A" ; -- Floor...
SELECT modID, description  FROM Modules WHERE description LIKE '%S%corner%';  -- F
SELECT modID, description  FROM Modules WHERE description LIKE '%SW%';  -- G, L, M

# temperature only sensor modules in floor:
SELECT modID, description  FROM Modules WHERE description LIKE '%floor%';
SELECT printf('number of floor sensor modules: %i', COUNT(modID))  FROM Modules WHERE description LIKE '%floor%';

# temperature and humidity sensor modules in walls and roof:
SELECT modID, description  FROM Modules WHERE description NOT LIKE '%floor%';  -- 9
SELECT printf('number of wall and roof sensor modules: %i', COUNT(modID))  FROM Modules 
       WHERE description NOT LIKE '%floor%'; -- 3


SELECT printf('number of sensor: %i', COUNT(*)) FROM Sensors;  -- 165
SELECT printf('number of sensor in walls and roof: %i',  COUNT(*))  FROM Sensors 
       WHERE  z > 0.0 ; -- 24
SELECT printf('number of sensor in and below slab: %i',  COUNT(*))  FROM Sensors 
       WHERE  z <= 0.0 ; -- 141

SELECT count(*) FROM Sensors WHERE modID="G"; -- 16

# This will differ if sensorType has not been generated
SELECT * FROM Sensors WHERE modID="G";

SELECT COUNT(*) FROM Sensors WHERE modID IS NULL ; -- 0
SELECT COUNT(*) FROM Sensors WHERE modID IS NOT NULL ; -- 165
 
SELECT min(z) FROM Sensors; --  -12.5
 
SELECT printf('number of sensor in and below slab: %i',  COUNT(*))  FROM Sensors 
       WHERE  z <= 0.0 ; -- 141

SELECT printf('number of sensor in slab: %i', COUNT(*)) FROM Sensors 
       WHERE (-10. < z ) AND (z <= 0.0) ; -- 91

SELECT printf('number of sensor below slab: %i',  COUNT(*))  FROM Sensors 
       WHERE  z < -10.0 ; -- 50
       
SELECT printf('number of sensor below foam: %i', COUNT(*)) FROM Sensors 
       WHERE (-12.6 < z ) AND (z <= -12.4) ;  -- 36
 
SELECT printf('number of sensor just above lowest foam: %i', COUNT(*)) FROM Sensors 
       WHERE (-12.4 < z ) AND (z <= -10.) ; -- 14

