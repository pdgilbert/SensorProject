# This is for a grasshopper script to read sensor data.
# See loadSensorReadingsSQLite  to load sensor readings to the db.
# See loadIDlocationsSQLite to load sensor locations to the db.

# Inputs:
#   dbName     eg 'SensorReadings.sqlite.db' selected with path browser
#   previously sliceStart   a string representing a datetime, eg '2025-08-03 18:18:30'
#      but does not work well with slider.
#   sliceStartYear   a number indicating start year   eg 2025
#   sliceStartMonth  a number indicating start month  eg 8
#   sliceStartDay    a number indicating start day    eg 3
#   sliceStartHour   a number indicating start hour   eg 18
#   sliceStartMinute a number indicating start minute (often 0)
#   sliceStartSecond a number indicating start second (normally 0)

#   sliceDays  an number indicating days for timedelta slice period (normally 0).
#   sliceHours an number indicating hours for timedelta slice period (often 0).
#   sliceMinutes an number indicating minutes for timedelta slice period.
#   sliceSeconds an number indicating seconds for timedelta slice period.

# Outputs:
# timeStamp, x,y,z, temperature, minTemp, maxTemp, IDtemperature

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
#dbName = "SensorReadings_2026-01-19.db"
#
# slice for first test data
# previously sliceStart ='2025-08-03 18:18:30'
#sliceStartYear  = 2025
#sliceStartMonth = 8
#sliceStartDay   = 3
#sliceStartHour   = 18
#sliceStartMinute = 18
#sliceStartSecond = 30
#
#sliceDays = 0
#sliceHours = 0
#sliceMinutes = 12
#sliceSeconds = 0
#
#
# previously sliceStart ='2026-01-03 00:12:00'
# previously SliceStart  = datetime.strptime(sliceStart, fmt)

#sliceStartYear  = 2026
#sliceStartMonth = 1
#sliceStartDay   = 3
#sliceStartHour   =  0
#sliceStartMinute = 12
#sliceStartSecond =  0
#
#sliceDays = 0
#sliceHours = 2
#sliceMinutes = 0
#sliceSeconds = 0

SliceStart  = datetime(year=sliceStartYear, month=sliceStartMonth, day=sliceStartDay,
                hour=sliceStartHour, minute=sliceStartMinute, second=sliceStartSecond )

SliceEnd = SliceStart + timedelta(days=sliceDays, 
                      hours=sliceHours, minutes=sliceMinutes, seconds=sliceSeconds)
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
