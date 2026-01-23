# This is for a grasshopper script to read sensor data.
# See loadSensorReadingsSQLite  to load sensor readings to the db.
# See loadIDlocationsSQLite to load sensor locations to the db.

# Inputs:
#   dbName     eg 'SensorReadings.sqlite.db' selected with path browser
#   sliceStart   a string representing a datetime, eg '2025-08-03 18:18:30'
#   sliceMinutes an number indicating minutes for timedelta slice period (a day is 1440 minutes)
#   sliceSeconds an number indicating seconds for timedelta slice period.

# Outputs:
# timeStamp, x,y,z, temperature, minTemp, maxTemp

#  https://realpython.com/python-sql-libraries/
#  https://www.sqlitetutorial.net/sqlite-python/creating-tables
#  https://www.geeksforgeeks.org/python/python-convert-string-to-datetime-and-vice-versa/

#  This could all change if the db uses
#     detect_types=sqlite3.PARSE_DECLTYPES | sqlite3.PARSE_COLNAMES
#  which is possibly faster, but let's see.

# Slice is a short window used for a time period where most sensors will report.
# It might be 12 minutes if sensors report every 10 minutes.
# If there is more than one report for a sensor then the last one will get used.
# The term Window may get future use to indicate a longer period to scroll through.

import sqlite3
from datetime import datetime, timedelta # library and a module are both called datetime

fmt = '%Y-%m-%d %H:%M:%S'

# test values for grasshopper inputs
#dbName = "SensorReadings.db"

# slice for first test data
#sliceStart ='2025-08-03 18:18:30'
#sliceMinutes = 12
#sliceSeconds = 0

#sliceStart ='2026-01-03 00:12:00'
#sliceMinutes = 120
#sliceSeconds = 0

SliceStart  = datetime.strptime(sliceStart, fmt)
SliceEnd = SliceStart + timedelta(days=0, hours=0, minutes=sliceMinutes, seconds=sliceSeconds)
#print(SliceEnd)


con = sqlite3.connect(dbName)
#con = sqlite3.connect(dbName, mode="ro")  #CHECK READ ONLY MODE
#con = sqlite3.connect(dbName + '?mode=ro', uri=True)  CHECK READ ONLY MODE this creates new db

st = "(timeStamp > '" +SliceStart.strftime(fmt) + "')"
en = "(timeStamp < '" +   SliceEnd.strftime(fmt) + "')"

q = "SELECT sensorData.id, timeStamp, temperature, x, y, z FROM sensorData INNER JOIN \
    sensorLocation ON sensorData.id = sensorLocation.id  WHERE " + st + " AND " +  en 
    
zz = con.execute(q).fetchall()
print("records returned ", len(zz))

timeStamp   = [ v[1]  for v in zz ]
temperature = [ v[2]  for v in zz ]
x = [ v[3]  for v in zz ]
y = [ v[4]  for v in zz ]
z = [ v[5]  for v in zz ]

IDtemperature = [ [v[0],v[2]]  for v in zz ]

minTemp = min(temperature)
maxTemp = max(temperature)

con.close() 
